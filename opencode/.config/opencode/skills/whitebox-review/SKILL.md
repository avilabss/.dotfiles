---
name: whitebox-review
description: Reviews Whitebox.aero merge requests across core, kernel, plugins, and shared architecture boundaries. Use when reviewing Whitebox code changes or merge requests.
---

# Whitebox Architecture-Aware Review Skill

Use this skill when reviewing Whitebox.aero merge requests or code changes that
may affect core, kernel, plugins, frontend module federation, events, data
models, APIs, deployment, or hardware-facing workflows.

## Review stance

- Review the product-state transition, not just the visible diff.
- Resolve the full cross-repository context before making final judgments.
- Prefer precise, actionable findings over generic lint or style comments.
- Separate merge blockers from acceptable follow-up work, and ask for linked
  follow-up issues/MRs when risk is deferred.
- Ground every comment in the relevant code, contract, test evidence, or
  Whitebox architecture boundary.

## Resolve the ReviewBundle first

A Whitebox change may span the core repository, plugin repositories, support
libraries, work items, and temporary plugin overrides. Before detailed review,
build a ReviewBundle containing:

- the parent/core MR in `whitebox-aero/whitebox`, or core `main` when no parent
  MR exists after discovery;
- related plugin/library MRs;
- work items or issue references;
- the kernel/core branch used by plugin CI;
- `backend/pyproject.toml` `plugins-temporary` dependency overrides;
- inferred architecture edges through capabilities, plugin models, class
  registries, events, URLs, JSX slots/components, state stores, sockets, and
  lifecycle hooks.

### Bundle resolution procedure

1. Read the MR metadata: project, source/target branch, draft state,
   description, labels, reviewers, discussions, and changed files.
2. Parse explicit modern links:
   - Core/parent MRs should list child MRs under `Related MRs` or equivalent
     obvious wording.
   - Plugin/child MRs should include `PARENT: <core MR URL>` when they are
     part of a core-led bundle.
   - Plugin MRs that need a non-default kernel should include a case-sensitive
     `KERNEL:` line, for example `KERNEL: #feature/whitebox-123` or
     `KERNEL: https://gitlab.com/whitebox-aero/whitebox.git#feature/whitebox-123`.
     Treat `KERNAL:` as a discovery clue for the same ref, but request correction
     to `KERNEL:` because plugin CI recognizes only the case-sensitive spelling.
3. For a core MR, treat it as the likely source of truth. Inspect
   `backend/pyproject.toml` changes in
   `[tool.poetry.group.plugins-temporary.dependencies]`; git dependencies there
   identify plugin repos and branch/rev refs that must be reconciled with
   related plugin MRs.
4. For a plugin-only MR, prefer explicit `PARENT:` and `KERNEL:`. If no core
   parent is found, use core `main` only after checking explicit links, work
   item context, branch correlation, reverse links from other MRs, and
   `plugins-temporary` evidence.
5. Treat old or loose linking patterns only as discovery clues. If you infer a
   relation that is missing from descriptions, request a description update with
   exact suggested `PARENT:`, `KERNEL:`, or `Related MRs` lines.
6. If associated MRs are still draft or inconsistent, make the bundle/readiness
   issue clear before doing or trusting a full review unless an early pass was
   explicitly requested.

## Whitebox architecture model for review

Whitebox is a plugin-first, event-driven system:

- **Kernel**: the plugin system. It discovers and manages plugins, handles JSX
  transpilation/module federation, and exposes plugin APIs.
- **Core**: the kernel plus the default/core plugin set and platform layers that
  Whitebox needs to run.
- **Plugins**: first-class packages that may own backend behavior, Django app
  behavior, frontend components, state stores, URL/API surfaces, events, models,
  assets, and hardware integrations.

Review implication: moving behavior across core/plugin boundaries or changing a
shared plugin contract can affect repositories that are not in the current diff.
Check consumers and providers across the whole ReviewBundle.

## Architecture-aware checks

### Plugin discovery and dependency ordering

- Whitebox plugin packages are discovered from installed distributions named
  `whitebox-plugin-*`, mapped to modules such as
  `whitebox_plugin_device_manager`, and must expose `plugin_class`.
- Django app plugins are discovered via `whitebox.plugin` entry points.
- Hybrid plugins participate in both paths.
- Plugins are dependency-sorted by `requires_capabilities` and
  `provides_capabilities`; check for missing providers, accidental cycles,
  capability renames/removals, or changed load ordering.
- For executable validation, use Whitebox core's existing
  `PluginDependencyHelper.sort_plugins_by_dependencies`, which detects missing
  capabilities and cycles, or its `verify_plugin_dependencies` boolean wrapper.
  Do not propose a duplicate dependency-analysis utility.

### Backend contracts

- **Model registry**: changes to `[tool.whitebox-plugin.plugin-models]`,
  `plugin_model_classes_map`, migrations, or `whitebox.db.get_model(...)` / registry
  consumers are cross-plugin data-contract changes.
- **Global class registry**: changes to `plugin_plugin_classes_map` or
  `get_class(...)` identifiers affect a global namespace. Renames/removals need
  coordinated consumers. Inheritance requires `get_class(..., proxy=False)`.
- **Plugin-local classes**: changes to `plugin_local_classes_map` affect
  lifecycle-based discovery such as device-provider classes consumed on
  `plugin.load` / `plugin.unload`; confirm local names remain scoped to the
  owning plugin and consumers handle unload.
- **Events**: changes to `plugin_event_map`, event names, payload shapes,
  handler context return shapes, callback registration, callback timing, or
  WebSocket message `type` values are shared contracts.
- **URLs/APIs**: changes to `plugin_url_map`, Django/DRF routes, route names,
  plugin URL namespaces, serializers, or frontend API consumers need compatibility
  checks across core and plugins.
- **Security/request context**: trace authentication, tenant scope, and request
  context across plugin routes, event handlers/callbacks, and WebSocket consumers.
  Verify identity and tenant data are preserved from the originating request or
  socket scope, authorization is enforced at each boundary, and no context can be
  dropped, spoofed, or reused across tenants.
- **Sync/async boundaries**: inspect the complete execution path through call
  sites, wrappers, handlers, callbacks, and lifecycle cleanup. Confirm every
  coroutine is awaited exactly once, sync/async bridges are deliberate, and
  background work has explicit lifetime and error handling; do not judge only the
  line that creates a coroutine.
- **Lifecycle**: verify `on_load` and `on_unload` register/unregister callbacks,
  resources, and local classes safely and idempotently.

### Frontend and module federation contracts

- JSX files under plugin `jsx/` directories are transpiled and exposed through
  module federation.
- `slot_component_map` and `exposed_component_map` define shared component names;
  check renames, prop-shape changes, missing slots, and capability alignment.
- `state_store_map` exposes shared state stores; check store key stability,
  initialization order, and consumers using `withStateStore` or async imports.
- Review uses of global `Whitebox` helpers such as `SlotLoader`,
  `importWhiteboxComponent`, sockets, and `Whitebox.apiUrl` for contract and
  runtime compatibility.
- Frontend changes that affect flight, map, camera, device, recording, or mobile
  flows should include realistic cross-device or integration evidence when risk
  is meaningful.

### `plugins-temporary` and CI/sandbox coherence

- In core `backend/pyproject.toml`, `[tool.poetry.group.plugins-temporary]` is
  reserved for temporary plugin replacements during core/plugin co-development.
- Dependencies added under
  `[tool.poetry.group.plugins-temporary.dependencies]` override normal plugin
  versions when CI/sandbox installs with `--with plugins-temporary`.
- Map each git dependency package to its GitLab repo and branch/rev, then verify:
  - the core MR lists the matching plugin MR;
  - each plugin MR points back to the parent with `PARENT:`;
  - plugin MRs that require the branch use the correct `KERNEL:` value;
  - stale temporary refs are removed or intentionally retained before merge.

## Per-review output expectations

When reporting findings:

- Start with bundle status: parent/core, related MRs, kernel ref, draft/readiness,
  and description hygiene issues if relevant.
- Call out architecture-level risks before smaller per-file comments.
- For each finding, state severity, exact location, why it matters in Whitebox,
  and the concrete change requested.
- Ask for tests or manual evidence only when tied to a specific risk: migrations,
  plugin loading/unloading, capability ordering, event payloads, WebSocket flows,
  module federation, API compatibility, install/sandbox paths, hardware, or mobile
  behavior.
- Avoid approving a bundle as complete if related MRs, `plugins-temporary` refs,
  kernel branch expectations, or cross-plugin contract changes remain unresolved.
