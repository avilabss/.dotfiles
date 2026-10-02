# Whitebox SBC testing

Read this reference only for an explicit request to test or deploy Whitebox work
on an SBC. It is a pushed-Git-ref workflow in the device's `/whitebox` checkout,
not a remote-compute snapshot workflow. The architect plans and delegates; only
an executing role with the relevant authority performs operations. Reading this
reference or preparing a plan grants no operational authority.

## Allocate and establish authority

1. Resolve the canonical local feature worktree, branch, affected repositories,
   SSH username/destination, and the user's explicit allocation of this SBC to
   that worktree. Ask only for missing or ambiguous information. An SSH address
   alone is not allocation.
2. Detect active remote-compute mode before proceeding. Its requirement to execute
   in a snapshot child conflicts with remote Git updates and `/whitebox` deployment.
   Stop for explicit suspension/re-scoping or an appropriately separate execution
   context; never silently override that mode, sync a snapshot to `/whitebox`, or
   treat the SBC as a disposable whole-host worker. Merely using SSH is not mode
   activation. Do not migrate or tear down an existing deployment automatically.
3. A request for this complete workflow includes draft branch/MR publication and
   deployment, not merge approval. A narrower request retains its narrower scope;
   ask if publication authority is unclear. Never publish unrelated pending work.
4. Explicit allocation authorizes **one initial host-wide Docker reset** on the
   verified device. Do not ask for redundant wipe confirmation. This destroys
   local Docker data, including database, recordings/media, and provisioned map
   data; it is not a backup or a recoverable reset. It does not authorize deleting
   arbitrary host files or touching external/shared systems.

Carry the worktree/branch, repository and pushed-commit inventory, SSH destination,
trusted host-key identity, verified machine identity, allocation, and reset state
in task/session context and any authorized handoff. Record reset state as not
started, in progress/failed, or verified complete, with sanitized evidence. Do not
put device identifiers or task refs in permanent dotfiles or a device registry.
After lost context, use [interruption recovery](#interruption-and-failure), not
another wipe.

## Complete publication before device operations

From the canonical local worktrees, read and follow
[the MR and ticket workflow](merge-request-workflow.md) and
[push preparation](../SKILL.md#prepare-a-push). Publish touched dependencies before
consumers; replace editable overrides with pushed Git refs and refresh the core
lockfile's resolved commits. Record the exact pushed core/dependency revisions.

Create/update real MRs and complete their required relationships before connecting
for the reset/deployment phase. An unresolved core `PARENT` link or another required
relationship blocks that phase. Resolve it through the canonical protocol; never
invent a URL, relax this gate, or create a competing publication order here.
Clearly label draft publication, missing checks, CI failures, and pending manual
testing. Do not wait for CI to turn green, but do not bypass a known security,
data-loss, or deployment blocker.

## Preflight the device before deletion

Use ordinary SSH host-key checks and existing credentials. Resolve first-contact
host-key trust with the user when not already known; do not bypass checking,
silently replace keys, or put passwords on command lines. Quote/validate supplied
destinations and refs; never interpolate untrusted input into remote shell code.

- Verify the allocated machine against its trusted/accepted host key and recorded
  machine identity, such as machine-id or board serial when available. Record the
  identifier at verified allocation and compare on reconnect. Hostname/default
  login alone is insufficient; a newly observed identifier does not prove this is
  the intended device. Stop if identity or allocation is uncertain or mismatched.
- Inspect `/whitebox` repository/remote identity, owner/group, tracked and untracked
  changes, and the existing deployment user. The installer can clone as root but
  run Compose as `WHITEBOX_USER`; inspect the installed stack unit, not just a
  template. Use appropriate existing accounts/privileges for Git and deployment.
  Missing privileges require escalation, not chown, blanket `safe.directory`,
  user/group changes, automatic stashing, or weakened Git/SSH protections.
- In **each effective account/context** used for cleanup or deployment, inspect
  Docker context, endpoint, relevant `DOCKER_HOST`/context overrides, and daemon
  identity. Confirm commands address a daemon local to this SBC, not a remote
  daemon hidden behind a context or socket. Keep Docker running during cleanup.
- Inspect resource inventories and selected mount/driver fields: all containers,
  images, volumes, networks, and build caches/builders. Stop on external/shared
  backing, including remote volume storage or builders. A `local` volume driver
  alone does not establish local storage. Preserve bind-mounted host files.
- Inspect installed service managers/recreators and device prerequisites: Docker/
  Compose capabilities, disk space, registry/Git access, network access for data
  provisioning, existing host services and device configuration. Do not install
  dependencies or rerun the full installer to force this workflow through.
- Read deployment instructions and configuration at the intended pushed branch
  before resetting; confirm it can use this device's prerequisites. Check required
  `.env` keys without dumping their values, credentials, or rendered Compose
  secrets. Preserve the file; missing prerequisites are a stop before deletion.

Inventory commands must succeed, not merely print nothing. Examples are
`docker container ls -a`, `docker image ls`, `docker volume ls`,
`docker network ls`, and `docker system df`; inspect supported builder cache
inventories as well. Retain only sanitized evidence, not full environment or
credential-bearing inspect output.

## First deployment: reset Docker once

Proceed only after allocation, identity, preflight, and publication checks pass,
and only when reset state is known to be not started. Record it as in progress
before deleting anything. These are ordered operations on the verified SBC daemon,
using the inspected accounts/privileges, not a blind copy/paste cleanup script:

1. Stop relevant managers/recreators before removing containers. If the installed
   `whitebox-stack.service` is active, stop it before switching branches: its
   `ExecStop` runs Compose down from `/whitebox`. Record which service state was
   suspended. Do not disable unrelated units or stop Docker itself.
2. Successfully list all containers, then force-remove the returned IDs with
   `docker container rm -f`. This includes stopped containers. An empty successful
   list needs no removal command; do not confuse a failed list with an empty one.
3. Remove all images from a successful, deduplicated image-ID inventory with
   `docker image rm -f`. Check results and remaining inventory.
4. Remove **local named and anonymous volumes** after their container references
   are gone. Check server API/CLI capabilities: `docker volume prune -af` includes
   named volumes only with supported `--all` (API 1.42+). Otherwise use
   `docker volume rm` on the successfully inventoried, verified-local names.
   Do not infer success from unsupported flags or silently ignore a removal error.
5. Remove unused user networks with `docker network prune -f`; retain expected
   built-ins (`bridge`, `host`, `none`). Clear all build cache with the supported
   builder prune operation (`docker builder prune -af` when supported), including
   any other inventoried local builders; never prune a remote/shared builder.
   Finish with `docker system prune -af`.
6. Recheck all inventories and command results. Containers, images, local volumes,
   user networks, and build cache should be gone; name every residual resource,
   including built-in networks. Unexplained residuals/errors block deployment.
   Only then record reset as verified complete.

Compose-only cleanup misses the deliberate host-wide clean-device reset.
[System prune](https://docs.docker.com/reference/cli/docker/system/prune/) removes
unused images/cache/networks but no volumes by default; its `--volumes` only
covers anonymous volumes. [Volume prune](https://docs.docker.com/reference/cli/docker/volume/prune/)
needs separate named-volume handling. Never delete `/whitebox`, `.git`, `.env`,
bind-mounted host files, logs, or arbitrary `/var/lib/docker` contents. Do not
repeat this reset during subsequent testing.

## Select the pushed branch and deploy

In SBC `/whitebox`, using the inspected Git account/privileges:

1. Recheck repository/remote identity and clean tracked state. Inspect untracked
   files for checkout collisions; preserve ignored device configuration. Stop on
   dirt, divergence, wrong remote, or ownership problems; no `reset --hard`,
   `git clean`, force checkout, or automatic stash.
2. Fetch the intended remote, select the exact feature branch (create a tracking
   branch from that remote if absent), and use `git pull --ff-only` against the
   verified upstream. Stop if it cannot fast-forward. Confirm HEAD equals the
   recorded intended pushed core commit, not merely a branch label. If the remote
   moved, reconcile the intended revision before deploying.
3. Reinspect this branch's supported deployment procedure and dependencies.
   For feature plugin overrides, check/set `TEMPORARY_DEPENDENCIES=1` by key in
   the device `.env` before building; report this persistent device-config change
   without exposing other values. Confirm core's Git overrides/lock commits match
   the pushed dependencies and are accessible to the build. Do not insert secrets
   into Git URLs, tracked files, images, or build logs to make access work.

Run the branch's supported production build/start procedure as the inspected
deployment user, in `/whitebox` and the verified local Docker context. The inspected
source uses these commands, not a hypothetical `make deploy` or a full reinstall:

```bash
docker compose build &&
  docker compose up -d --no-build
```

Run the start command **only if the build succeeds**. Execute builds/checks in the
foreground with a sufficient timeout. Restore only service state needed for this
intended deployment if preflight suspended it; do not restart an old stack. Report
the resulting stack-unit state as well as container state.

Verify built images and running container image IDs, and check installed dependency
metadata/resolved Git commits against the core lockfile and pushed inventory.
Branch names or a successful Docker start do not prove the feature code was used.
Run relevant service/application health checks and report expected versus actual
results. After a wipe, base images and map/airport data need fetching/provisioning;
backend waits for successful map initialization. Distinguish normal provisioning,
failed provisioning, healthy services, deployed revision, and manual feature
acceptance. Do not invent an endpoint or declare feature acceptance for the user.

## Repeat the manual testing loop

Keep the same allocation and verified-complete reset state. For each iteration:

1. Run focused checks needed for credible safe testing. Push touched dependencies
   first, refresh core Git overrides **and lock-resolved commits**, then push core
   and update real MR relationships through the canonical workflow. A dependency
   branch push alone leaves core's locked commit stale.
2. Reverify host/allocation/effective daemon after reconnect. Pull the intended
   core revision fast-forward-only in `/whitebox`; verify exact core and dependency
   commits, then rebuild, redeploy, and check actual installed/running revisions
   and health as above. If switching branches with an active stack unit, stop it
   using its current branch before checkout; do not use volume-deleting teardown.
3. Report sanitized deployment/test evidence and known CI failures. **Do not wait
   for CI** or chase unrelated CI failures during this loop. Do not repeat the
   initial wipe, prune the new test data, or tear down the user's testing deployment.

## Interruption and failure

After reconnect/resume, reverify host-key/machine identity, allocation, account and
daemon before continuing. Carry reset-completed evidence forward. If completion
is unknown or reset failed partway, stop and reconcile available evidence with the
user; never restart the whole wipe because context was lost. A new allocation or
an additional reset needs explicit scope, not an assumed retry.

On cleanup, fetch, build, provisioning, deployment, or health failure, stop the
sequence and report sanitized errors, exact attempted revisions, actual running
state, and suspended services. Do not claim deployment or reset succeeded, hide
errors, or assume rollback after deleted data or schema migrations. Agree on a
recovery action before taking new destructive steps.

## Manual green flag and handoff

The user's manual green flag ends the fast loop and starts CI cleanup plus the
normal [validation](../SKILL.md#validate) and
[project review/merge gates](merge-request-workflow.md#merge-and-verify-publication).
Resolve CI failures and required missing evidence; manual success is not merge
approval, CI-bypass authority, or a substitute for code/product review. Keep
implemented/validated, AI-reviewed, author-reviewed/understood, and ready for
project review separate. Final merge actions still need their own authority.

Retain the deployment for the user's testing; identify the device/worktree,
deployed core/dependency commits, reset state, device-config/service changes,
health/manual/CI evidence and open blockers. Provide exact account/context-aware
inspection and stop guidance for the actual retained stack. For the inspected
Compose deployment, inspection is `docker compose ps -a` from `/whitebox`;
stopping an active stack unit uses `systemctl stop whitebox-stack.service` with
existing privileges, otherwise `docker compose stop` as the deployment user.
These stop operations are not automatic completion cleanup and do not authorize
volume deletion. Do not reuse remote-compute whole-worker teardown authority.

## Source basis

Inspected Whitebox core revision: `5148ee47f2252acde1a1fb44aba0292a6e8d17bc`.
These paths are in **Whitebox core**, not this dotfiles checkout. They establish
the procedure's basis, not any future SBC's state; reinspect the deployment's
actual branch and installed device services before acting.

| Contract | Source |
|---|---|
| Temporary production dependencies | `docs/development_guide.md`, "Adding temporary dependencies to CI"; `compose.yml` backend-base build args; `packaging/docker/backend.base.Dockerfile` conditional Poetry install |
| Persistent data and provisioning prerequisites | `compose.yml` volumes, map-data-init, airport-data-provisioner, backend dependencies and required environment keys |
| Git/deployment privileges and build/start order | `bin/install.sh` root checkout and `WHITEBOX_USER` Compose commands; `packaging/systemd/whitebox-stack.service` |
| Final project checks | `.gitlab/merge_request_templates/default.md`, "Before Merge Checklist"; canonical MR workflow linked above |

The installer also changes packages, users, networking, and systemd configuration;
rerunning it is not an ordinary redeploy. This device's allocation covers the
specified Docker reset and deployment, not unrestricted host administration.
