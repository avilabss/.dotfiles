/**
 * Anthropic Subscription Auth Plugin for OpenCode
 *
 * Full Claude Pro/Max subscription support — OAuth login, token refresh,
 * and request transformation to match Claude Code's wire format.
 *
 * What Anthropic validates on subscription (OAuth) tokens:
 *   1. User-Agent must be claude-cli/<version>
 *   2. anthropic-beta must include claude-code-20250219 + oauth-2025-04-20
 *   3. x-app header must be "cli"
 *   4. System prompt must start with Claude Code identity string
 *   5. Tool names must match Claude Code's canonical casing
 *   6. Auth must be Bearer (not x-api-key)
 *
 * Without ALL of these, Anthropic aggressively rate-limits or rejects requests.
 *
 * References:
 *   - pi-ai anthropic provider: @mariozechner/pi-ai/dist/providers/anthropic.js
 *   - pi-ai anthropic oauth: @mariozechner/pi-ai/dist/utils/oauth/anthropic.js
 */

import type { Plugin } from "@opencode-ai/plugin";

// ─── Constants ──────────────────────────────────────────────────────────────

const CLIENT_ID = "9d1c250a-e61b-44d9-88ed-5944d1962f5e";
const TOKEN_URL = "https://platform.claude.com/v1/oauth/token";
const REDIRECT_URI = "https://platform.claude.com/oauth/code/callback";
const SCOPES =
  "org:create_api_key user:profile user:inference user:sessions:claude_code user:mcp_servers user:file_upload";

// Mimic Claude Code exactly — update this when Claude Code updates
const CLAUDE_CODE_VERSION = "2.1.75";
const USER_AGENT = `claude-cli/${CLAUDE_CODE_VERSION}`;

// Claude Code canonical tool names (case-sensitive)
// Source: https://cchistory.mariozechner.at/data/prompts-2.1.11.md
const CLAUDE_CODE_TOOLS: string[] = [
  "Read",
  "Write",
  "Edit",
  "Bash",
  "Grep",
  "Glob",
  "AskUserQuestion",
  "EnterPlanMode",
  "ExitPlanMode",
  "KillShell",
  "NotebookEdit",
  "Skill",
  "Task",
  "TaskOutput",
  "TodoWrite",
  "WebFetch",
  "WebSearch",
];

// Build lookup: lowercase → canonical casing
const CC_TOOL_LOOKUP = new Map(
  CLAUDE_CODE_TOOLS.map((t) => [t.toLowerCase(), t])
);

// For tools that don't match Claude Code names, prefix with mcp_
const MCP_PREFIX = "mcp_";

/**
 * Convert a tool name to Claude Code format.
 * If it matches a known CC tool (case-insensitive), use CC casing.
 * Otherwise, prefix with mcp_ (how Claude Code exposes MCP tools).
 */
function toClaudeCodeToolName(name: string): string {
  const ccName = CC_TOOL_LOOKUP.get(name.toLowerCase());
  if (ccName) return ccName;
  // Already prefixed? Don't double-prefix
  if (name.startsWith(MCP_PREFIX)) return name;
  return `${MCP_PREFIX}${name}`;
}

/**
 * Convert a tool name back from Claude Code format to OpenCode format.
 * Reverses the mcp_ prefix and CC casing.
 */
function fromClaudeCodeToolName(
  name: string,
  originalTools?: Array<{ name: string }>
): string {
  // If we have original tool list, find case-insensitive match
  if (originalTools?.length) {
    const lower = name.toLowerCase();
    const match = originalTools.find((t) => t.name.toLowerCase() === lower);
    if (match) return match.name;
  }
  // Strip mcp_ prefix
  if (name.startsWith(MCP_PREFIX)) {
    return name.slice(MCP_PREFIX.length);
  }
  return name;
}

// ─── PKCE ───────────────────────────────────────────────────────────────────

function base64urlEncode(buffer: Uint8Array): string {
  let binary = "";
  for (const byte of buffer) binary += String.fromCharCode(byte);
  return btoa(binary)
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
}

async function generatePKCE(
  length = 64
): Promise<{ verifier: string; challenge: string }> {
  const buffer = new Uint8Array(length);
  crypto.getRandomValues(buffer);
  const verifier = base64urlEncode(buffer);
  const hash = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(verifier)
  );
  const challenge = base64urlEncode(new Uint8Array(hash));
  return { verifier, challenge };
}

// ─── OAuth helpers ──────────────────────────────────────────────────────────

type OAuthStored = {
  type: "oauth";
  refresh: string;
  access: string;
  expires: number;
};

type OAuthSuccess = {
  type: "success";
  provider?: string;
  refresh: string;
  access: string;
  expires: number;
};

type ApiKeySuccess = {
  type: "success";
  provider?: string;
  key: string;
};

type FailedResult = { type: "failed" };
type AuthResult = OAuthSuccess | ApiKeySuccess | FailedResult;

async function buildAuthorizeUrl(mode: "max" | "console") {
  const pkce = await generatePKCE();
  const host = mode === "console" ? "console.anthropic.com" : "claude.ai";
  const url = new URL(`https://${host}/oauth/authorize`);
  url.searchParams.set("code", "true");
  url.searchParams.set("client_id", CLIENT_ID);
  url.searchParams.set("response_type", "code");
  url.searchParams.set("redirect_uri", REDIRECT_URI);
  url.searchParams.set("scope", SCOPES);
  url.searchParams.set("code_challenge", pkce.challenge);
  url.searchParams.set("code_challenge_method", "S256");
  url.searchParams.set("state", pkce.verifier);
  return { url: url.toString(), verifier: pkce.verifier };
}

async function exchangeCode(
  code: string,
  verifier: string
): Promise<OAuthSuccess | FailedResult> {
  const splits = code.split("#");
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      code: splits[0],
      state: splits[1],
      grant_type: "authorization_code",
      client_id: CLIENT_ID,
      redirect_uri: REDIRECT_URI,
      code_verifier: verifier,
    }),
  });
  if (!res.ok) return { type: "failed" };
  const json = (await res.json()) as {
    refresh_token: string;
    access_token: string;
    expires_in: number;
  };
  return {
    type: "success",
    refresh: json.refresh_token,
    access: json.access_token,
    // Expire 5 minutes early to avoid edge-case failures
    expires: Date.now() + json.expires_in * 1000 - 5 * 60 * 1000,
  };
}

async function refreshToken(
  refreshToken: string
): Promise<{
  refresh: string;
  access: string;
  expires: number;
}> {
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      grant_type: "refresh_token",
      client_id: CLIENT_ID,
      refresh_token: refreshToken,
      scope: SCOPES,
    }),
  });
  if (!res.ok) {
    const body = await res.text().catch(() => "");
    throw new Error(
      `Anthropic token refresh failed: ${res.status} ${res.statusText} — ${body}`
    );
  }
  const json = (await res.json()) as {
    refresh_token: string;
    access_token: string;
    expires_in: number;
  };
  return {
    refresh: json.refresh_token,
    access: json.access_token,
    expires: Date.now() + json.expires_in * 1000 - 5 * 60 * 1000,
  };
}

// ─── Request body transformation ────────────────────────────────────────────

const CLAUDE_CODE_IDENTITY =
  "You are Claude Code, Anthropic's official CLI for Claude.";

/**
 * Transform the API request body to match what Anthropic expects from Claude Code:
 * - Prepend Claude Code identity to system prompt
 * - Remap tool names to CC canonical casing or mcp_ prefix
 * - Remap tool_use blocks in messages
 */
function transformRequestBody(bodyStr: string): {
  body: string;
  originalTools?: Array<{ name: string }>;
} {
  let parsed: any;
  try {
    parsed = JSON.parse(bodyStr);
  } catch {
    return { body: bodyStr };
  }

  // Track original tool names for response remapping
  const originalTools: Array<{ name: string }> = [];

  // 1. System prompt — ensure Claude Code identity is first
  if (parsed.system) {
    if (typeof parsed.system === "string") {
      // Replace OpenCode identity if present, prepend CC identity
      let sys = parsed.system.replace(
        /You are OpenCode[^.]*/,
        CLAUDE_CODE_IDENTITY
      );
      if (!sys.startsWith(CLAUDE_CODE_IDENTITY)) {
        sys = CLAUDE_CODE_IDENTITY + "\n\n" + sys;
      }
      parsed.system = [{ type: "text", text: sys }];
    } else if (Array.isArray(parsed.system)) {
      // Replace OpenCode identity in text blocks
      let hasIdentity = false;
      parsed.system = parsed.system.map(
        (block: { type?: string; text?: string }) => {
          if (block.type === "text" && block.text) {
            let text = block.text.replace(
              /You are OpenCode[^.]*/,
              CLAUDE_CODE_IDENTITY
            );
            if (text.includes(CLAUDE_CODE_IDENTITY)) hasIdentity = true;
            return { ...block, text };
          }
          return block;
        }
      );
      // Prepend identity block if not already present
      if (!hasIdentity) {
        parsed.system.unshift({ type: "text", text: CLAUDE_CODE_IDENTITY });
      }
    }
  } else {
    // No system prompt at all — add one
    parsed.system = [{ type: "text", text: CLAUDE_CODE_IDENTITY }];
  }

  // 2. Remap tool definitions
  if (parsed.tools && Array.isArray(parsed.tools)) {
    parsed.tools = parsed.tools.map((tool: { name?: string }) => {
      if (tool.name) {
        originalTools.push({ name: tool.name });
        return { ...tool, name: toClaudeCodeToolName(tool.name) };
      }
      return tool;
    });
  }

  // 3. Remap tool_use blocks in messages
  if (parsed.messages && Array.isArray(parsed.messages)) {
    parsed.messages = parsed.messages.map(
      (msg: { content?: Array<{ type?: string; name?: string }> }) => {
        if (msg.content && Array.isArray(msg.content)) {
          msg.content = msg.content.map((block) => {
            if (block.type === "tool_use" && block.name) {
              return { ...block, name: toClaudeCodeToolName(block.name) };
            }
            return block;
          });
        }
        return msg;
      }
    );
  }

  return { body: JSON.stringify(parsed), originalTools };
}

/**
 * Transform streaming response to remap tool names back to OpenCode format.
 */
function transformResponseStream(
  response: Response,
  originalTools?: Array<{ name: string }>
): Response {
  if (!response.body) return response;

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  const encoder = new TextEncoder();

  const stream = new ReadableStream({
    async pull(controller) {
      const { done, value } = await reader.read();
      if (done) {
        controller.close();
        return;
      }

      let text = decoder.decode(value, { stream: true });

      // Remap CC tool names back. Handle both mcp_ prefixed and CC canonical names.
      // Pattern: "name": "mcp_something" → "name": "something"
      text = text.replace(
        /"name"\s*:\s*"mcp_([^"]+)"/g,
        '"name": "$1"'
      );

      // Also remap CC canonical names back if we have original tool list
      if (originalTools?.length) {
        for (const ccName of CLAUDE_CODE_TOOLS) {
          const original = originalTools.find(
            (t) => t.name.toLowerCase() === ccName.toLowerCase()
          );
          if (original && original.name !== ccName) {
            // Replace exact CC name with original
            const pattern = new RegExp(
              `"name"\\s*:\\s*"${ccName}"`,
              "g"
            );
            text = text.replace(pattern, `"name": "${original.name}"`);
          }
        }
      }

      controller.enqueue(encoder.encode(text));
    },
  });

  return new Response(stream, {
    status: response.status,
    statusText: response.statusText,
    headers: response.headers,
  });
}

// ─── Plugin ─────────────────────────────────────────────────────────────────

const AnthropicAuthPlugin: Plugin = async ({ client }) => {
  return {
    auth: {
      provider: "anthropic",

      async loader(
        getAuth: () => Promise<OAuthStored | { type: string }>,
        provider: { models: Record<string, { cost?: unknown }> }
      ) {
        const auth = await getAuth();

        if (auth.type === "oauth") {
          // Zero out cost display — Pro/Max subscription, no per-token cost
          for (const model of Object.values(provider.models)) {
            model.cost = {
              input: 0,
              output: 0,
              cache: { read: 0, write: 0 },
            };
          }

          return {
            apiKey: "",

            async fetch(
              input: Request | string | URL,
              init?: RequestInit
            ): Promise<Response> {
              let auth = (await getAuth()) as OAuthStored;
              if (auth.type !== "oauth") return fetch(input, init);

              // ── Refresh token if expired ─────────────────────────
              if (!auth.access || auth.expires < Date.now()) {
                const refreshed = await refreshToken(auth.refresh);
                await client.auth.set({
                  path: { id: "anthropic" },
                  body: {
                    type: "oauth",
                    refresh: refreshed.refresh,
                    access: refreshed.access,
                    expires: refreshed.expires,
                  },
                });
                auth = {
                  type: "oauth",
                  ...refreshed,
                };
              }

              // ── Build headers ────────────────────────────────────
              const headers = new Headers();

              // Copy existing headers from input/init
              if (input instanceof Request) {
                input.headers.forEach((v, k) => headers.set(k, v));
              }
              if (init?.headers) {
                const h = init.headers;
                if (h instanceof Headers) {
                  h.forEach((v, k) => headers.set(k, v));
                } else if (Array.isArray(h)) {
                  for (const [k, v] of h as [string, string][]) {
                    if (v !== undefined) headers.set(k, String(v));
                  }
                } else {
                  for (const [k, v] of Object.entries(h)) {
                    if (v !== undefined) headers.set(k, String(v));
                  }
                }
              }

              // Merge anthropic-beta: preserve existing + add required ones
              const existingBetas = (headers.get("anthropic-beta") || "")
                .split(",")
                .map((b) => b.trim())
                .filter(Boolean);
              const requiredBetas = [
                "claude-code-20250219",
                "oauth-2025-04-20",
                "interleaved-thinking-2025-05-14",
                "fine-grained-tool-streaming-2025-05-14",
              ];
              const mergedBetas = [
                ...new Set([...requiredBetas, ...existingBetas]),
              ].join(",");

              // Set all required headers
              headers.set("authorization", `Bearer ${auth.access}`);
              headers.set("anthropic-beta", mergedBetas);
              headers.set("user-agent", USER_AGENT);
              headers.set("x-app", "cli");
              headers.set("accept", "application/json");
              headers.delete("x-api-key"); // Must not send API key with OAuth

              // ── Transform request body ───────────────────────────
              let body = init?.body;
              let originalTools: Array<{ name: string }> | undefined;

              if (body && typeof body === "string") {
                const result = transformRequestBody(body);
                body = result.body;
                originalTools = result.originalTools;
              }

              // ── Add ?beta=true to /v1/messages ───────────────────
              let requestInput: Request | string | URL = input;
              try {
                const url = new URL(
                  typeof input === "string"
                    ? input
                    : input instanceof Request
                      ? input.url
                      : input.toString()
                );
                if (
                  url.pathname === "/v1/messages" &&
                  !url.searchParams.has("beta")
                ) {
                  url.searchParams.set("beta", "true");
                  requestInput =
                    input instanceof Request
                      ? new Request(url.toString(), input)
                      : url;
                }
              } catch {
                // URL parse failed, use as-is
              }

              // ── Make the request ─────────────────────────────────
              const response = await fetch(requestInput, {
                ...init,
                body,
                headers,
              });

              // ── Transform response (remap tool names back) ───────
              return transformResponseStream(response, originalTools);
            },
          };
        }

        // Not OAuth — no-op
        return {};
      },

      methods: [
        {
          label: "Claude Pro/Max (OAuth)",
          type: "oauth" as const,
          authorize: async () => {
            const { url, verifier } = await buildAuthorizeUrl("max");
            return {
              url,
              instructions:
                "Complete login in your browser, then paste the authorization code here:",
              method: "code" as const,
              callback: async (code: string): Promise<AuthResult> => {
                return exchangeCode(code, verifier);
              },
            };
          },
        },
        {
          label: "Create API Key (via Console OAuth)",
          type: "oauth" as const,
          authorize: async () => {
            const { url, verifier } = await buildAuthorizeUrl("console");
            return {
              url,
              instructions:
                "Complete login in your browser, then paste the authorization code here:",
              method: "code" as const,
              callback: async (code: string): Promise<AuthResult> => {
                const creds = await exchangeCode(code, verifier);
                if (creds.type === "failed") return creds;
                const res = await fetch(
                  "https://api.anthropic.com/api/oauth/claude_cli/create_api_key",
                  {
                    method: "POST",
                    headers: {
                      "Content-Type": "application/json",
                      authorization: `Bearer ${creds.access}`,
                    },
                  }
                );
                const json = (await res.json()) as { raw_key: string };
                return { type: "success", key: json.raw_key };
              },
            };
          },
        },
        {
          provider: "anthropic",
          label: "Manually enter API Key",
          type: "api" as const,
        },
      ],
    },
  };
};

export { AnthropicAuthPlugin };
