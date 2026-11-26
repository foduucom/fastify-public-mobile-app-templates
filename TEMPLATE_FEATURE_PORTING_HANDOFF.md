# Template Feature Porting Handoff

**Prepared:** 2026-11-26  
**Purpose:** Give Claude or another engineer a reliable handoff for comparing the senior/reference Flutter template with a second template, then improving the second template without turning it into the reference website.

## 1. The two projects and the rule that governs this work

| Role | Project | Website currently configured |
| --- | --- | --- |
| Senior/reference template | `/Users/flutterdev/Desktop/fastify-public-mobile-app-templates` | `foduu-electronics-store.foduu.store` |
| Template to improve | `/Users/flutterdev/Desktop/fastify-public-mobile-app-templates-2` | `daksh-store.foduu.store` |

These projects serve **different websites**. The senior project is a source of implementation patterns and feature behavior. It is not a source of the target website's brand, copy, CMS data, credentials, theme, payment configuration, or unverified backend contract.

The porting goal is:

> Identify the reusable capability that makes the reference feature work, then implement that capability using the target app's routes, services, API contract, CMS configuration, and visual design.

Do not copy a screen or controller wholesale just because it works against the other website. First trace its route, binding, controller, provider, request/response shape, state updates, and success/error navigation. Verify every API assumption against the **target** website.

## 2. Work and findings captured from this chat

This chat has covered a broad parity review, including the reference search module, checkout and payment flow, order success/details, and site-specific CMS-driven screens. The target retained its own visual system and site data while receiving compatible behavior and robustness changes.

### Search and product discovery

The target search implementation is a three-state flow in `lib/app/modules/search/controllers/search_controller.dart`:

1. **Browse:** CMS search layout and pre-hydrated product content.
2. **Autocomplete:** debounced predictive products, categories, and blog results, with local content fallback.
3. **Submitted results:** CMS-aware entity tabs and server-backed results.

The controller uses request sequence tokens to prevent old search, autocomplete, or pagination responses from overwriting newer state. It supports recent-search persistence, brands, sorting, product pagination, category/blog results, empty/error states, and CMS-controlled entity visibility. `ProductService` builds query parameters, and the target keeps its own search screen rather than copying the senior website's look.

Related files:

- `lib/app/modules/search/controllers/search_controller.dart`
- `lib/app/modules/search/services/product_service.dart`
- `lib/app/modules/search/views/search_view.dart`
- `lib/app/modules/search/views/filter_view.dart`
- `lib/app/data/category_filter_service.dart`

### Checkout, payment methods, and order creation

The target checkout flow is in `lib/app/modules/checkout/controllers/checkout_controllers.dart` and the active route binds `CheckOutController` to `CheckoutViews`.

The work recorded in `PAYMENT_CASH_FLOW_SUMMARY.md` includes:

- Explicit payment-method loading state and a completed empty state, so an empty methods response does not leave a permanent shimmer.
- Parsing payment configuration wrappers and normalizing `cash`/`cod` aliases.
- Refreshing the server cart before checkout, resolving the selected address ID from live address state, and guarding repeated submission.
- Cash orders use the target website's `POST /checkout/place-order`; online gateways continue through the API order path.
- Cash requests omit populated cart objects so the target server can resolve the customer's stored cart and avoid malformed nested variant IDs.
- CSRF bootstrap for the target website's protected browser checkout route.
- Order success navigation only after an order response, with COD prepayment and online gateway completion handled as separate flows.
- Order success accepts internal order IDs and human order numbers, refreshes order details, and preserves cash-order status.
- The duplicate `OrderSuccessController` type lookup in the shared bottom button was corrected to use the active order-response controller.

**Latest checkout hardening in this chat:**

- The CSRF bootstrap now forwards the complete cookie set from the same response, not only `_csrf`, because deployments can bind the CSRF secret to a session cookie too.
- CSRF meta tag parsing accepts either order of `name` and `content` attributes.
- Checkout logs now identify the safe request phase, elapsed time, endpoint path, response shape, and HTTP status when available. They avoid logging address IDs, CSRF values, auth tokens, or payment secrets.
- Failures preserve API error messages where available. If the order POST times out or its result is uncertain, the message tells the customer to check Orders before retrying.
- The changed checkout controller passed targeted Dart analysis with no errors; `git diff --check` passed. Analyzer infos remain in pre-existing imports/debug prints. No payment/order test was run.

The target checkout implementation is **not** the senior website's checkout implementation. The senior template currently points at `foduu-electronics-store.foduu.store` and posts COD through `/api/order/create` with its own form fields. The target is `daksh-store.foduu.store`, whose project notes document a CSRF-protected website route and a previous `201` response from `/checkout/place-order`. Do not replace the target route with the senior route without target-server evidence.

Related files:

- `lib/app/modules/checkout/controllers/checkout_controllers.dart`
- `lib/app/modules/checkout/views/checkout_views.dart`
- `lib/app/data/basic_provider.dart`
- `lib/app/modules/orderResponse/controllers/ordersucess_controller.dart`
- `lib/app/modules/orderResponse/views/ordersucess_view.dart`
- `lib/components/buttons/bottombutton.dart`
- `PAYMENT_CASH_FLOW_SUMMARY.md`

### Latest iOS checkout log: evidence and limits

The pasted run showed:

- The iOS build completed.
- The target's `/api/payment-methods`, cart, and customer-address requests returned `200`.
- A saved address was selected and the app prepared a cash order request.
- The pasted output did **not** contain a checkout POST response or HTTP status. It later showed Studio Socket.IO `502` errors and `Lost connection to device`.

That log does not establish whether CSRF initialization stalled, the POST was rejected, the server created an order but the app lost the response, or the debug device disconnected for another reason. The Socket.IO errors are not evidence by themselves that checkout failed. A prior project note records a target-site `/checkout/place-order` `201`, so do not assume the route is invalid based only on this newer, incomplete trace.

No live order was submitted during the latest hardening work. Run the target-site COD flow and inspect the new phase logs before claiming the issue is fixed. Check Orders before retrying if the app loses connection after starting the POST, to avoid accidental duplicate orders.

### Order and checkout behavior

The order-success flow in `lib/app/modules/orderResponse/` accepts the immediate order response, uses the internal database ID to request details, and handles cash copy/status separately from card or wallet payment status. It retains the order number for display and supports image resolution in order cards/details.

The flow should be evaluated as one transaction path:

`cart refresh → address validation → payment selection → server order creation → gateway confirmation if applicable → cart refresh → order details`

Do not show success merely because a payment SDK returned a local callback; use the target backend's confirmation response and order status.

### CMS, content, account, and shared reliability

The target already has website-specific CMS-backed implementations for home, blog, about, contact, FAQ/support, and related sections. It should keep the Daksh store's CMS content and its established design system. Generic behaviors can be compared to the reference, but senior-site editorial text and visuals must not be copied.

The broader work reviewed or carried across target modules includes:

- Category tree parsing/hydration for category, material, and style filters, with depth/batch bounds and duplicate prevention.
- Address resolution and checkout selection using live target address data rather than a hard-coded address ID.
- Wishlist and notification behavior in the target app's existing routes and service conventions.
- API resilience in `BasicProvider`: bounded retries for transient GET failures, coalesced in-flight GETs, cache fallback for eligible reads, and no automatic retries for writes.
- Session expiry cleanup and cache clearing through the target session service.
- Order product image resolution shared by order lists/details.
- FAQ search added to the target help screen, covering FAQ questions, answers, and nested details while preserving target styling.

These are target-side features and patterns to verify during future work; do not infer that every screen has received a fresh live-server acceptance test.

### Password recovery status

The target's forgot-password screen now validates the email, requests an OTP using the existing `auth/resend-otp` endpoint, and opens the OTP route in forgot-password context. Forgot-password OTP verification no longer follows the normal login path, so it cannot silently authenticate the user.

The final password update remains **blocked by the target backend contract**. The codebase documents only authenticated password change (`public/customer/change/password`), which requires the current password. No unauthenticated reset endpoint or reset-token contract was found. The app does not fake a successful reset. Claude must not guess an endpoint or reuse login OTP as password-reset authorization.

## 3. Current completion ledger

| Area | Current state | Evidence / next action |
| --- | --- | --- |
| Target CMS/home presentation | Implemented for the Daksh site | Existing `HOME_AND_PARENT_WEB_IMPLEMENTATION_SUMMARY.md`; preserve brand/CMS data. |
| Search behavior | Strong target-side behavior present | Inspect the complete request/UI path before proposing further parity work. |
| Target cash checkout route | Implemented with CSRF bootstrap and order/success flow | Latest CSRF cookie/logging hardening is not yet live-verified; rerun target COD safely. |
| Online gateways | Existing target integrations remain separate from COD | Verify each only in the target site's sandbox/configuration. |
| Order details/success | Implemented in target route/controller | Reconfirm after a successful target order; earlier captured details request returned `200`. |
| FAQ search | Implemented in target support screen | Static analysis previously reported no errors in the touched files. |
| Password recovery | Partially wired; final update unavailable | Backend team must provide reset endpoint, token/OTP semantics, payload, and success response. |
| Full runtime acceptance | Not complete | Do not claim all planned work is verified until target-site flows are exercised. |

## 4. Recommended process for the next template port

Use one feature slice at a time. Each slice should end with a reviewable change and evidence.

### Phase 0 — Establish a safe baseline

- Confirm which directory is the **reference** and which is the **target**.
- Record each configured website domain, app identifier, API base URL, access key source, payment-provider configuration, and CMS ownership. Keep secrets out of documentation and logs.
- Read `AGENTS.md`, project README, route definitions, dependency configuration, and the target's existing implementation notes.
- Record existing working-tree changes before editing; do not revert or reformat unrelated user files.
- Identify the active route/binding/controller. This repo has legacy/duplicate checkout controllers; the routed screen must be traced rather than guessed from a filename.

### Phase 1 — Build a feature evidence matrix

For each requested capability, compare:

1. User entry point and route.
2. Binding/controller ownership and state transitions.
3. Provider/service and exact target-specific endpoint.
4. Request fields and types, headers, auth, CSRF/session behavior.
5. Success, failure, empty, loading, cancellation, and retry behavior.
6. Downstream navigation and data refresh.
7. Site-specific theme, copy, CMS fields, asset URLs, and payment settings.

Label every finding **verified from code**, **verified by runtime/server response**, **inferred**, or **unknown**. Do not turn an inference into a contract.

### Phase 2 — Separate reusable behavior from website identity

- Port state handling, validation, race protection, pagination, error handling, and response normalization where they solve the same problem.
- Keep the target's brand colors, layout, copy, CMS content, route names, asset conventions, payment keys, and backend endpoint contracts.
- If the same feature uses different APIs in the two sites, write an adapter for the target contract rather than importing the reference request verbatim.
- Never embed production secrets or log bearer tokens, CSRF values, full customer addresses, card data, or unredacted provider responses.

### Phase 3 — Implement narrow vertical slices

Recommended order:

1. **Search/discovery:** autocomplete, submitted results, filters, sorting, pagination, stale-response guards, and empty/error states.
2. **Checkout prerequisites:** current cart refresh, selected address resolution, payment-method configuration, coupon/shipping totals, and submission guard.
3. **Order creation:** target route/payload, auth/CSRF requirements, idempotency behavior, and clear server error mapping.
4. **Payment and completion:** gateway-specific create/confirm/cancel/failure paths, then order-success and order-detail refresh.
5. **Account and post-purchase:** address, profile, order history/details, wishlist, notifications, reviews, and support.
6. **CMS/editorial pages:** preserve the target's site content and visual design while making data handling robust.

Keep each slice small enough to inspect. Do not mix a visual redesign with a transaction-contract change unless the user specifically requests both.

### Phase 4 — Validate by risk

- Run formatting and static analysis on changed files.
- Add/update focused unit or widget tests when authorized and suitable; cover response-shape variants, stale request races, duplicate taps, and success/failure transitions.
- For checkout, first validate request construction without charging a real instrument. Use a target-site sandbox/test account and inspect server logs.
- Verify the complete target-specific flow: one order created, no duplicate on retry, correct payment state, cart state refreshed, and order details loaded by internal order ID.
- Record which checks were run and which were not. A compile success is not evidence of a successful backend transaction.

### Phase 5 — Review and handoff

- Summarize changed files and behavior, the evidence supporting the API contract, validation results, and remaining backend dependencies.
- Update the relevant implementation summary so future work does not repeat investigations.
- Ask the user to review the concrete result at the agreed section boundary before starting a new feature slice.

## 5. Ready-to-use instruction for Claude

```text
Compare the senior/reference Flutter template at
/Users/flutterdev/Desktop/fastify-public-mobile-app-templates
with the target template at
/Users/flutterdev/Desktop/fastify-public-mobile-app-templates-2.

They serve different websites. Use the senior project only to identify reusable
behavior and engineering patterns. Preserve the target website's own routes,
API contract, access-key source, payment configuration, CMS data, branding,
copy, and visual design. Do not copy credentials or assume that an endpoint
working on the senior website is valid on the target website.

Read TEMPLATE_FEATURE_PORTING_HANDOFF.md and the target's relevant implementation
summaries first. Trace the active route -> binding -> controller/service -> API
provider -> response -> UI/navigation for the feature being considered. The
target repo contains legacy/duplicate modules, so confirm which controller is
actually routed before editing.

For each feature, create an evidence-based matrix: reference behavior, target
behavior, concrete gap, target-specific contract, proposed change, and validation
plan. Mark claims as code-verified, runtime/server-verified, inferred, or unknown.
Keep user data and secrets out of logs. Make changes only in the target project.

First report the findings and a staged implementation plan for review. Do not
start a different feature or redesign the target website while the current slice
is under review. For checkout, do not place a live order or charge a real payment
method without explicit authorization; inspect the target request/response and
server evidence first. Never report a backend-dependent flow as complete until
the target backend confirms it.
```

## 6. Source notes

- `PAYMENT_CASH_FLOW_SUMMARY.md` records the target's cash checkout investigation, the `/checkout/place-order` contract evidence, prior CSRF failure and resolution, and order-success handling.
- `HOME_AND_PARENT_WEB_IMPLEMENTATION_SUMMARY.md` records target-specific CMS/home presentation work. Its website examples belong to the target site and must not be copied into another template's branding.
- The latest iOS console text was supplied in chat as an attachment. It showed a prepared cash-order payload but no checkout HTTP result before the device connection was lost.
- The current CSRF cookie forwarding and phase diagnostics have not yet been confirmed by another target-site runtime checkout.

## 7. Expanded activity log and engineering decisions

This section records why the comparison changed direction during the conversation. It is meant to prevent the next engineer from repeating earlier shallow comparisons or treating the reference app as a package to copy.

### A. Project identity and scope corrections

The user repeatedly clarified that the senior project and the target project belong to different websites. That changes the meaning of “port”:

- **Carry over:** reliable state transitions, race protection, pagination, validation, error handling, and useful flow sequencing.
- **Re-evaluate per target:** API paths, request payloads, auth/CSRF, payment gateway settings, order status semantics, address schemas, CMS data shapes, and delivery/coupon rules.
- **Keep target-owned:** page composition, typography, colors, imagery, copy, CMS sections, route naming, and the target website's account/payment behavior.

The user also called out that the search module's strength should be reviewed directly, not dismissed because an entry point or route was unclear. Route registration, real navigation entry points, and controller capability are separate questions. The current source has search route declarations; future reviews should check the actual running app's entry point as well as the module implementation.

The user later emphasized order checkout and order details, asking that accuracy be compared as a transaction flow. This is why checkout is documented by endpoint, payload, status handling, and downstream order lookup—not merely by whether the payment screen renders.

### B. Search: what “strong search” means in this target

The target's search is more than a text field plus a product query:

| Behavior | Implementation detail |
| --- | --- |
| Browse before typing | Search CMS layout can pre-hydrate products. The visible search bar is owned by the page, so the duplicate CMS search section is excluded. |
| Predictive typing | A short debounce requests autocomplete across product, category, and blog entities. |
| Local fallback | Pre-hydrated content can still produce suggestions when the remote autocomplete is empty or unavailable. |
| Submitted results | A separate results state loads configured entity types and displays only tabs allowed by CMS layout. |
| Stale-response safety | Search, autocomplete, and pagination sequence tokens invalidate outdated in-flight responses when the query or mode changes. |
| Recent searches | Entries are de-duplicated, capped, persisted, removable, and clearable. |
| Product controls | Brand filtering and relevance/price/newest sort options are added to the product query. |
| Pagination | The controller loads more products near the scroll end, tracks `hasNextPage`, blocks duplicate loads, and exposes a retryable pagination error. |
| Non-product entities | Categories are searched from the target API; blogs are loaded/matched through the target blog model and cache path. |
| Failure UX | Search and pagination expose separate error state instead of leaving results in a permanent loading state. |

The supporting shared helper is `lib/services/product_pagination.dart`; the shop and category-search flows also use pagination metadata. Search filter state is represented in `lib/app/modules/search/models/filter_model.dart`. A new template should reuse these concepts only after checking its own API's filter keys and pagination response shape.

### C. Checkout: differences found between the two apps

The active target checkout is `CheckOutController` in `lib/app/modules/checkout/controllers/checkout_controllers.dart`, bound to `CheckoutViews`. There are old/alternate classes in the same repository, including `CheckoutController` with a static address ID. That older controller is not proof of the live checkout behavior. Claude should confirm route and binding before modifying a similarly named file.

The target's documented cash-order history is:

1. `/api/payment-methods` returns configuration; the UI must distinguish loading from a completed empty result.
2. The cart and selected target-site address are refreshed/resolved.
3. COD/cash is normalized for display while using the target site's website checkout contract.
4. The app initializes CSRF state, sends the cash order, and waits for an authoritative response.
5. The app refreshes the cart and loads order details by database order ID.

The reference app's form and endpoint differ: it uses `/api/order/create`, `cod`, `payment_method`, `currency`, and COD flags. The target's project notes describe `/checkout/place-order`, literal `cash`, and a server-side saved-cart lookup. These contracts should not be merged just to make the payloads look similar.

The original target API-order attempt also exposed a separate cart serialization problem: a populated product variant map reached the backend as `"[object Object]"` where the mobile API expected a variant ID. The target's website checkout route avoids sending those populated cart objects and lets the server resolve its cart. This was a backend contract issue, not a visual/payment-SDK issue.

### D. Checkout: interpretation of the latest error log

The supplied run contains several messages that look alarming but belong to different subsystems:

| Log message | Current interpretation | Checkout evidence? |
| --- | --- | --- |
| iOS build succeeds | App compiles and launches. | No. |
| Splash image preload reports `MediaQuery` access during `initState` | Startup-widget lifecycle issue; should be tracked separately if still present. | No. |
| `/api/public/customer/profile` returns `404`, followed by `/api/auth/customer/profile` returning `200` | One profile endpoint is missing, but the fallback profile route succeeds. | Not the reported order POST. |
| `/api/payment-methods`, cart, and addresses return `200` | Checkout setup data is available. | Yes, prerequisites appear to load. |
| Order payload is printed with address ID and `primary_method: cash` | The app reached order-request preparation. | Yes, but this does not prove a POST completed. |
| No checkout response/status follows in the pasted excerpt | The checkout result is unknown. It may be during CSRF bootstrap, POST, response handling, or device/debug disconnection. | This is the key missing evidence. |
| Firebase/APNs token messages | Notification registration is not ready in the simulator. | No. |
| `studio.foduu.store` Socket.IO `502`/ping timeout | Studio live-layout socket had a transport problem. | Not evidence that the store checkout POST failed. |
| `Lost connection to device` | Flutter's debug connection ended. It does not state whether the server created an order. | Inconclusive. |

This is why checkout hardening added explicit phase timing and stopped logging the full order form. The next run should show whether the CSRF page returned, which target path was submitted, whether the API returned a status, or whether the app lost the device before that point. Because a timed-out POST can still create an order on the server, check order history before tapping Place Order again.

### E. API and session reliability work

The shared target API layer in `lib/app/data/basic_provider.dart` includes read/write behavior that should be preserved when porting another feature:

- GET requests retry transient transport/server failures with bounded backoff; ordinary 4xx responses are not retried.
- Concurrent identical GETs can share an in-flight request.
- Eligible public/catalog GETs can use cache and fall back to stored data during transient outages.
- Writes are not blindly retried because a repeated POST can create duplicate orders or other side effects.
- API errors are converted into typed exceptions; session expiry cleanup is centralized instead of being independently implemented in each screen.

`lib/services/api_cache.dart`, `lib/app/data/services/session_service.dart`, and `lib/app/controllers/api_exception_handle_controller.dart` are part of that flow. New code should use these paths rather than adding a second cache, retry loop, or logout path inside one controller.

### F. Catalog, filters, and pagination

The target has a `CategoryFilterService` that reads category types and nested category trees. It handles API wrapper shapes, resolves ID-only child references in bounded batches, limits recursion depth and total hydrated nodes, de-duplicates IDs, and creates readable breadcrumbs. This is useful reusable behavior; endpoint names and category types still belong to each store.

Shared pagination logic is used by product discovery surfaces such as shop, search, and category search. The implementation reads server metadata where possible and guards against repeated load-more requests. When porting, preserve server `hasNextPage`/page values rather than assuming the senior site's fixed page size or response envelope.

### G. Order history and detail images

The target contains both a newer order-history flow (`lib/app/modules/ordre_history/`) and a legacy profile order flow (`lib/app/modules/profile_legacy/orders/`). The shared `OrderProductImageResolver` and `OrderProductImage` widget are used across order cards and detail views so populated product data, nested images, and fallback states are handled consistently.

The implementation paths called out during the comparison include:

- `lib/services/order_product_image_resolver.dart`
- `lib/components/order_product_image.dart`
- `lib/app/modules/ordre_history/view/order_history_view.dart`
- `lib/app/modules/ordre_history/order_detils/view/order_details_view.dart`
- `lib/app/modules/profile_legacy/orders/view/order_view.dart`
- `lib/app/modules/profile_legacy/orders/order_products/view/order_view.dart`
- `lib/app/modules/profile_legacy/orders/orders_details/view/orderdetails_view.dart`

The two history surfaces should not be assumed interchangeable. Before changing one, confirm which profile route is exposed and whether it shares a controller/model with the other.

### H. Address and region behavior

Address selection is part of checkout correctness, not just account UI. The active checkout resolves an ID from the current selected address and validates it before order creation. Address form/list controllers and the region picker use target responses for country/state/region options; do not restore fixed address IDs or copy a senior store's region data.

Relevant paths include `lib/app/modules/address/controllers/`, `lib/app/modules/address/views/`, `lib/app/modules/address/widgets/region_picker_sheet.dart`, and `lib/app/data/category_filter_service.dart` for the related tree-hydration pattern.

### I. CMS and site-owned presentation

The target's CMS renderer is a major part of the app's identity. Work documented in `HOME_AND_PARENT_WEB_IMPLEMENTATION_SUMMARY.md` includes:

- Dynamic CMS section parsing/registration and fallback handling for missing or differently shaped content.
- Target-specific “parent web” layouts for products, banners, categories, trust badges, rich text, partner logos, and other home sections.
- Target theme contrast handling, clean image placeholders, price formatting, and responsive card sizing.
- Home-only spacing and scroll clearance so CMS-authored sections compose as one feed.
- Target-specific bottom navigation ordering and selected-state behavior.

Additional reusable CMS components in the target include a schema-driven form builder (`lib/components/studio_widget/cms_form_builder_section.dart` and `lib/app/data/services/cms_form_service.dart`) and countdown rendering (`lib/components/studio_widget/cms_countdown_section.dart`). Preserve the target's CMS field names and content. A visually similar reference widget may receive different `content_json`.

### J. Support and account-adjacent screens

- The target's help/support controller fetches FAQ data from `frontend/faq`, normalizes supported wrapper shapes, and now filters parent and nested FAQ questions/answers locally. Search text is cleared/disposed with controller lifecycle; target styles remain intact.
- The target contact experience includes a website/CMS view and an API-backed contact controller path. There is also a legacy profile contact controller with placeholder behavior; trace the active route before assuming that legacy controller handles the current contact screen.
- About and blog sections are target-site content surfaces. Search, category selection, detail navigation, and CMS content can be compared as behaviors; never port senior article copy or brand assets.
- Wishlist and notification modules use their own route/service wiring. Notification registration can have iOS/APNs lifecycle messages independent of the UI list or checkout.

### K. Password recovery: precise boundary

The senior and target projects both contain incomplete recovery behavior. The available `auth/resend-otp` and `auth/verify-otp` paths establish that an OTP can be requested and verified, but they do not establish a password-reset capability. In the target's previous flow, forgot-password verification could pass through login/session success logic. That was separated so an OTP accepted during recovery does not create an authenticated session.

The target's current app now does the safe, known part: validate email → request OTP → verify in forgot-password context → tell the user recovery cannot finish until the backend supports it. The only documented password update endpoint requires the old password. The remaining work belongs to the backend/API contract and should specify:

1. Which endpoint starts recovery and how it avoids account enumeration.
2. Whether OTP or a signed reset token authorizes the operation, its expiry, and attempt limits.
3. Exact request fields and response/error shapes.
4. Password policy, token invalidation, and session behavior after reset.
5. Target-site server support and a safe acceptance test.

Do not remove the current honest failure state until that contract exists and is implemented end to end.

## 8. What Claude should report at each review boundary

For each feature slice, return a small table like this before claiming parity:

| Question | Evidence to report |
| --- | --- |
| What does the reference actually do? | File/route path and success/error state sequence. |
| What does the target currently do? | Active target route/binding/controller and API path. |
| What is the concrete gap? | User-visible or data-integrity behavior, not “the files look different.” |
| Is the contract confirmed? | Source/server/runtime evidence, or label the assumption unknown. |
| What changed? | Target files and why they fit the target website. |
| What was checked? | Formatter/analyzer/build/tests/runtime; list only what actually ran. |
| What remains? | Backend dependency, live test, or unresolved behavior. |

This makes it possible for the user to approve a real feature slice rather than a vague promise to “port everything.”
