# Codex subscription speed tiers: observable facts

Research snapshot: **2026-11-05 UTC**. Scope: Pi's `openai-codex` provider with ChatGPT subscription authentication, **not OpenAI API-key billing**. This is evidence for later design, not a replacement-extension specification. No credentials were read, authenticated endpoints called, inference requests sent, packages installed, or configuration changed.

## Findings

- **Fast and Ultrafast exist for ChatGPT-authenticated Codex.** Ultrafast is not merely an API feature. Current subscription documentation names GPT-6 Astra and GPT-6.1 Sol and restricts access to Pro $500 and eligible Enterprise/Edu plans. Enterprise access is off by default and requires workspace-owner permission. Other self-serve plans lack access at launch, even with purchased credits. Enterprise eligibility requires credit-based or USD usage-based agreements; eligible Edu uses credits, not legacy rate-limit-only Enterprise arrangements. [O1]
- **`service_tier: "ultrafast"` is a real Codex request value**, not an invented extension convention. Official Codex accepts catalog tier IDs as strings, forwards supported IDs in both HTTP and WebSocket requests, and has ChatGPT-auth test fixtures exercising literal `ultrafast`. These are client/mock observations, not proof that any particular account's backend accepts it. [C1–C3]
- **A request, a plan, and a processing result are different evidence.** An outgoing tier proves intent. A fresh account/catalog response can report plan or advertised capability. A returned tier can report processing for that response. None alone guarantees future entitlement, billing, or speed. Missing response metadata means **unconfirmed**, not accepted or rejected.

## Subscription eligibility, without API assumptions

The subscription speed page advertises Fast for supported models, including GPT-6.1 Sol/Terra and GPT-6 Astra/Sol/Luna, "where available", in the desktop app, CLI, and IDE with ChatGPT sign-in. It does not provide a complete account-by-model eligibility matrix. The pricing page separately describes plan/model access; neither a model name nor an extension allowlist establishes workspace permission. [O1, O2]

Current published usage multipliers relative to Standard are Fast **2.5x included usage / 2x purchased credits or Enterprise pay-as-you-go**, and Ultrafast **8x / 6x**. These are subscription/credit rules, not Pi's API-dollar cost estimates. Current residency guidance allows GPT-6.1 Sol Ultrafast in the US and Europe (EEA + Switzerland), but GPT-6 Astra Ultrafast only in the US. [O1, O2]

### Discoverable signals in official source

These authenticated backend interfaces are **publicly visible in official source**, not established here as stable, supported third-party discovery APIs. None was called:

| Source/interface | Exact signal | What it does not establish |
| --- | --- | --- |
| `GET https://chatgpt.com/backend-api/codex/models?client_version=…` under default routing | `models[].slug`, `models[].service_tiers[].{id,name,description}`, `models[].default_service_tier`; deprecated `additional_speed_tiers` | Catalog advertisement is not proof of this request's processing. Bundled/cached data is not fresh account authorization. Backend/workspace routing can change the URL. [C1, C4] |
| `GET …/backend-api/wham/usage` | Top-level `plan_type`, `rate_limit`, `credits`, `spend_control`, `additional_rate_limits`; limits include usage availability/reset information | No dedicated Ultrafast entitlement boolean in the inspected payload schema. Credit availability is not speed permission. [C5] |
| `GET …/backend-api/wham/accounts/check` | ChatGPT map shape: `accounts[accountId].account.plan_type`; normalized `AccountEntry.plan_type` is optional and independent of token claims | General workspace/account access is not per-model speed entitlement. [C5] |
| Codex stream event `type: "codex.rate_limits"` | Top-level `plan_type`, `rate_limits.{primary,secondary}`, `credits`, `metered_limit_name`/`limit_name`; visible in Pi as `event.data.…` if sent | Plan/quota metadata, not the processing tier of a response. Header-derived rate-limit snapshots have no plan type in official parsing. [C6, P2] |
| Token schema, **not inspected credentials** | JWT claim `['https://api.openai.com/auth'].chatgpt_plan_type` | A token claim can age and is not a current entitlement check. Source recognizes distinct `pro`, `prolite`, `promax`, etc.; this research establishes no universal mapping from those strings to dollar plans. [C7] |

Official Codex filters tiers through model catalog support and feature requirements. `fast_mode` and `ultrafast_mode` are independently constrained; older servers can share the Fast gate. Catalog refresh can replace a now-unsupported saved `priority`/`ultrafast` choice with explicit Standard. This is **client-side normalization**, not an observable backend downgrade. Installed Pi's `openai-codex` provider uses bundled model definitions (with Pi's general catalog overlays), not this account-specific Codex discovery flow. [C1–C4, P1, P3]

No public subscription-specific endpoint guaranteeing "this user can use Ultrafast now" was identified. The catalog is the strongest inspected capability-advertisement mechanism, combined with account/workspace requirements, but its precise entitlement-filtering guarantee remains undocumented in the sources inspected.

## What the installed extension actually requests

Installed `@calesennett/pi-codex-fast` **0.1.13** registers `/codex-fast` and `/codex-ultrafast`. Its `before_provider_request` handler returns a replacement payload with:

- Fast: `service_tier: "priority"`.
- Ultrafast: `service_tier: "ultrafast"`.
- Off or unlisted model: no modification; it does **not** explicitly force `default` or remove another extension's tier.

It uses separate hard-coded provider/model allowlists covering both `openai` and `openai-codex`; its Ultrafast subscription entries include `gpt-6-astra` and `gpt-6.1-sol`. Its status shows the selected mode even on unlisted models. It neither reads response tiers nor discovers entitlements. It persists selection in global settings and reloads global/project settings and startup flags at `session_start`. Thus its indicator means **selected preference**, not backend acceptance. [P4]

## Pi transport and extension-hook trace

Installed Pi and Pi AI report version **1.0.0**. The inspected Codex implementation targets `https://chatgpt.com/backend-api/codex/responses`, with bearer authentication and `chatgpt-account-id`. [P1, P2]

| Stage | SSE | WebSocket |
| --- | --- | --- |
| Request | `buildRequestBody` → `options.onPayload` → serialized POST body (`service_tier` at top level); optionally zstd-compressed | Same payload hook → optional cached-input delta → JSON frame `{ type: "response.create", …requestBody }`; tier remains top level |
| HTTP visibility | `options.onResponse({status,headers})` before success/error body consumption | Installed implementation does **not** call `onResponse` for connection upgrade or each response |
| Earliest structured events | `parseSSE`: JSON from joined `data:` lines; frame labels/bytes are not exposed | `parseWebSocket`: decoded message JSON, without a browser-style `message` wrapper |
| Raw hook | Both feed `mapCodexEvents`, which awaits `onProviderStreamEvent(event, model)` **before** error/terminal normalization | Same |
| Normalization | `response.done`, `response.completed`, `response.incomplete` become `response.completed`; status is normalized; then shared response processing finalizes output/usage | Same |

The SDK bridges those callbacks to `before_provider_request`, `after_provider_response`, and `provider_stream_event`. Exact extension field paths: [P2, P5]

```text
before_provider_request: event.payload.service_tier   (unknown: inspect its shape)
after_provider_response: event.status, event.headers  (no body)
provider_stream_event:   event.provider, event.api, event.model, event.data
terminal raw event:      event.data.type
response identity:      event.data.response.id
reported tier:          event.data.response.service_tier
response outcome:       event.data.response.status
```

For subscription responses, inspect `event.provider === "openai-codex"` and `event.api === "openai-codex-responses"`. Raw terminal types to recognize are `response.done`, `response.completed`, and `response.incomplete`; Pi's hook sees their **original** types. `response.created` may also carry a response object, but initial metadata is not evidence of completed processing. Associate any observation with its response/model and outcome, not all subsequent turns. [P2, P5]

The request hook is a **pre-send payload transformation**, not a wire receipt: handlers compose in load/registration order, so a later extension can change the tier. Stream hooks are awaited and notification-only; handler failures are reported by the extension runner. Do not mutate raw events or retain/log entire responses merely to display a tier. [P5, P6]

### Fallback, missing metadata, and errors

- With unspecified transport, Pi uses `auto`: WebSocket first, SSE fallback on eligible transport failures **before** it marks the WebSocket stream started (first yielded provider event, not necessarily text), and session-scoped SSE fallback thereafter. It retries connection-limit and missing-continuation cases once. Backend/protocol errors normally propagate instead of causing transport fallback. After stream start, transport failure is an error. These mechanisms do not implement tier negotiation or explicitly retry at a lower tier. [P2]
- The raw hook exposes `type: "error"` before Pi extracts top-level `code`/`message` or nested `error.code`/`error.message`; `response.failed` exposes `response.error.{code,message}`. Non-2xx SSE bodies are read outside the stream hook; the HTTP hook gets only status/headers. Pi's final assistant error contains a formatted message, not a guaranteed structured error object. The SSE error parser recognizes `usage_limit_reached`, `usage_not_included`, `rate_limit_exceeded`, optional `error.plan_type`, and `error.resets_at`; these are not uniquely speed-entitlement errors. [P2]
- Missing/null `response.service_tier`, truncation, abort, malformed JSON, failure before terminal metadata, and successful responses without tier metadata leave processing **unconfirmed**. Even a terminal incomplete/failed response with a tier must retain its incomplete/failed outcome; it is not an unqualified successful acceptance. Pi's mock WebSocket regression fixture completes successfully with `response.done` and no tier, demonstrating that the client does not require the field—not how frequently the backend omits it. [P2, P7]
- Shared normalization does not preserve `service_tier` as a dedicated assistant-message property. Its pricing resolver uses response tier or `options.serviceTier`; specifically, response `default` plus option `priority`/`flex` substitutes the requested option. **Nuance:** the installed extension changes the payload, not `options.serviceTier`, so that fallback is not automatically populated by its injection. Either way, normalized cost is not independent acceptance evidence; Ultrafast also has no special multiplier in the inspected Codex pricing switch. [P2, P8]

## Response-tier meaning and documentation conflicts

The public Responses API reference says returned `service_tier` describes the processing mode actually used and can differ from the request. This supports the phrase **"backend reports priority/ultrafast"** when that raw field exists. It does **not** establish a subscription-backend guarantee that the field is always present, nor verify billing or physical performance. Official Codex's shared SSE/WebSocket parser does not require/preserve a processing-tier field in its normalized `ResponseCompleted` structure. [O3, C8]

Conflicts/limits remain explicit:

1. The generic API reference describes Ultrafast as access-controlled and available for `gpt-5.6-sol`; the dedicated API guide says GPT-6 Astra/GPT-6.1 Sol for all API users. Neither API availability statement grants ChatGPT subscription access. Current subscription guidance is the relevant product source. [O1, O3, O4]
2. The generic reference says both `fast` and `priority` return `priority`; the dedicated Fast guide limits that assertion to GPT-5.6 and earlier. Official Codex maps its Fast enum to request `priority`, while subscription docs show config `service_tier = "fast"`. Both spellings have source support, but returned-tier canonicalization for every newer subscription model is **not established**. Preserve the reported string rather than inventing a universal alias rule. [O1, O3, O5, C1]
3. A dated September 28–October 2, 2026 release note says Ultrafast excludes inference residency outside the US; current speed documentation adds European support for GPT-6.1 Sol. Treat the dated release note as historical, not a reason to discard newer model-specific guidance. [O1, O6]
4. The small official `ServiceTier` enum contains only Fast/Flex. That is **not** evidence that Ultrafast is invalid: current catalog/config/request paths use strings and explicitly handle `ultrafast`. [C1–C3]

HTTP success, WebSocket connection success, model availability, elapsed time, token rate, usage multipliers, and lack of an error cannot independently prove that a requested speed tier was used. No subscription-specific downgrade/error taxonomy or unconditional response-tier guarantee was found in the inspected sources.

## Feasible honest UI signals

Without choosing commands, placement, persistence, or retry policy, the evidence permits these separate signals:

| Signal | Honest meaning |
| --- | --- |
| `selected: Fast/Ultrafast` | Local preference only |
| `prepared: priority/ultrafast` | Value observed/set in the payload hook; later handlers may change it |
| `backend reports: <tier>` | Raw response field, tied to response identity and outcome |
| `different tier reported: <tier>` | Explicit mismatch; not an inferred downgrade reason |
| `processing tier unconfirmed` | No usable processing-tier metadata |
| `request failed / aborted / incomplete` | Outcome; quote only the specific backend reason actually available |
| `plan reported: <plan>` / `tier advertised by catalog` | Separate, timestamped eligibility evidence if obtained with authorization; not processing confirmation |

## Sources and verification

Web sources were fetched publicly on 2026-11-05; undated pages had no verified revision date. Prior `/tmp/pi-fast-alignment-research.txt` was used only as leads. Official Codex was independently shallow-cloned to `/tmp/codex-speed-source`, commit **`de6e72addd67d35e6bf83b7acac406116bf598a6`**, committed **2026-11-05T00:55:46Z**. Source links below pin that commit.

### Official documentation

- **O1:** [Subscription speed and requirements](https://learn.chatgpt.com/docs/agent-configuration/speed) (also reached from `developers.openai.com/codex/speed`).
- **O2:** [Codex subscription pricing](https://developers.openai.com/codex/pricing).
- **O3:** [Responses create reference, `service_tier`](https://developers.openai.com/api/reference/resources/responses/methods/create).
- **O4:** [API Ultrafast guide](https://developers.openai.com/api/docs/guides/ultrafast-mode), used only for protocol corroboration/conflict, not subscription eligibility.
- **O5:** [API Fast guide](https://developers.openai.com/api/docs/guides/fast-mode); explicitly dates Priority → Fast renaming to July 30, 2026.
- **O6:** [September 28–October 2, 2026 release note](https://learn.chatgpt.com/docs/whats-new/september-28-october-2-2026).

### Official Codex source

All paths below are relative to the pinned [Codex source tree](https://github.com/openai/codex/tree/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs):

- **C1:** [`protocol/src/config_types.rs:525–554`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/protocol/src/config_types.rs#L525), `protocol/src/openai_models.rs:240–280,1122–1150`: tier representation and request filtering.
- **C2:** [`core/src/client.rs:1128–1157`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/core/src/client.rs#L1128), `codex-api/src/common.rs:287–350`: HTTP/WS request fields; `tui/src/service_tier_resolution.rs`, `core/src/session/model_catalog_settings.rs`: feature/catalog normalization.
- **C3:** [`core/tests/suite/scenarios/catalog_settings.rs:27–100`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/core/tests/suite/scenarios/catalog_settings.rs#L27): mock catalog, dummy ChatGPT auth, `ultrafast` selection/refresh tests.
- **C4:** [`codex-api/src/endpoint/models.rs:33–121`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/codex-api/src/endpoint/models.rs#L33), `model-provider/src/models_endpoint.rs:125–258`, `models-manager/src/manager.rs`: authenticated discovery, identity/cache/fallback policy.
- **C5:** [`backend-client/src/client.rs:469–500`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/backend-client/src/client.rs#L469), `backend-client/src/client/rate_limit_resets.rs:22–80,128–134`, `backend-client/src/types.rs:131–239`, `codex-backend-openapi-models/src/models/rate_limit_status_payload.rs`: account/usage schemas (generated OpenAPI document version `0.0.1`).
- **C6:** [`codex-api/src/rate_limits.rs:53–168`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/codex-api/src/rate_limits.rs#L53): headers and `codex.rate_limits` fields.
- **C7:** [`login/src/token_data.rs:86–114`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/login/src/token_data.rs#L86), `protocol/src/auth.rs`: token claim schema and plan strings.
- **C8:** [`codex-api/src/sse/responses.rs:109–119,451–515`](https://github.com/openai/codex/blob/de6e72addd67d35e6bf83b7acac406116bf598a6/codex-rs/codex-api/src/sse/responses.rs#L109), `codex-api/src/endpoint/responses_websocket.rs:850–950`: shared response normalization.

### Installed Pi sources

Exact installed root **P**:
`/nix/store/4124kgrxxngakwm8nw2gkvzz7f6ad6cq-pi-coding-agent-1.0.0/lib/node_modules/pi-monorepo`.
Both `P/package.json` and `P/node_modules/@earendil-works/pi-ai/package.json` report `1.0.0`; no source commit was established. **A** below means `P/node_modules/@earendil-works/pi-ai`.

- **P1:** `A/src/providers/openai-codex.ts`: subscription provider, base URL, bundled models.
- **P2:** `A/src/api/openai-codex-responses.ts`: request/transport (`264–479`), pricing (`594–637`), raw mapping/SSE (`659–836`), WS parsing/requests (`1340–1585`), errors (`1593–1619`).
- **P3:** Complete `P/docs/{models,providers,custom-provider}.md`: catalog/auth/provider contracts.
- **P4:** `/home/ethan/.pi/agent/npm/node_modules/@calesennett/pi-codex-fast/{package.json,extensions/codex-fast.ts}`; version `0.1.13`, full source inspected.
- **P5:** `P/dist/core/sdk.js:213–241`, `P/dist/core/extensions/types.d.ts:663–694`; complete `P/docs/extensions.md` and `P/examples/extensions/debug-provider.ts`.
- **P6:** `P/dist/core/extensions/runner.js:807–833,1060–1088`; complete `P/docs/{tui,security}.md` also inspected for supported UI and data-handling boundaries.
- **P7:** `A/test/openai-codex-stream.test.ts:1290–1415`: mocked WS raw-event forwarding/missing tier; fixture inspected, not executed.
- **P8:** `A/src/api/openai-responses-shared.ts:552–599`, `A/src/types.ts`: normalized output and pricing.

Verification performed: public `web_search`/`fetch_content` plus passage retrieval; `git ls-remote https://github.com/openai/codex.git HEAD`; `git clone --depth 1 https://github.com/openai/codex.git /tmp/codex-speed-source`; `git -C /tmp/codex-speed-source log -1 --format='%H %cI %s'`; targeted `rg -n` searches and direct source reads at the locations above. Pinned-link checks resolved all nine cited GitHub source locations and line anchors against the clone; installed-source path checks passed. `git diff --no-index --check /dev/null specs/ai/research/codex-speed-tiers.md` passed. These establish documentation/client behavior, **not live subscription acceptance, this account's eligibility, metadata frequency, or actual billing**. Runtime/inference and flake checks were not run for this research-only change.
