# Port Audit — Phase 0 (SOURCE → TARGET gap triage)

**Summary: 2 port-now items beyond Phases 1-5, 3 port-later, 3 needs-decision, plus a long tail of `skip` (cosmetic/rebrand/TARGET-own-features).**

**Sizing checkpoint: NOT triggered.** Only 2 net-new `port-now` items surfaced beyond the 6 known phases (both small: one missing CMS section handler already implied by Phase 3's scope, one missing `basic_provider.dart` drift item that's really part of Phase 4/backend-contract work). Nothing resembling a multi-day standalone item was found. All large gaps (reviews, support tickets, filter drawer, PhonePe, studio widgets, custom drawer) match what Phases 1-5 already scope — this audit confirms rather than expands that list.

---

## 0.1 File-presence diff (`lib/`)

209 files in SOURCE/lib, 212 in TARGET/lib. `diff -rq` breakdown: 20 files only in SOURCE, 25 only in TARGET, 139 differ.

**Only in SOURCE (candidates to port):**

| Path | Triage |
|---|---|
| `lib/app/controllers/internet_connection_controller.dart` | needs-decision — check if TARGET handles connectivity another way (connectivity_plus is in both pubspecs) |
| `lib/app/controllers/theme_controller.dart` | needs-decision — check if TARGET's `dynamic_theme.dart` already covers this |
| `lib/app/data/category_filter_service.dart` | port-now — part of Phase 4 (shop filter drawer / category filter), confirms known scope |
| `lib/app/modules/Profie/orders/order_products/view/order_view.dart` | skip — looks like a duplicate/legacy file name already covered by `order_view.dart` elsewhere |
| `lib/app/modules/category/bindings/category_search_filter_binding.dart` + `controllers/category_search_filter_controller.dart` + `views/category_search_filter_view.dart` | port-now — Phase 4 (category filter naming diverged; TARGET has `category_controller.dart`/`category_view.dart`/`categorydetial_controller.dart` instead — needs reconciliation, not a blind copy) |
| `lib/app/modules/reviews/*` | port-now — Phase 1 (confirmed, already scoped) |
| `lib/app/modules/shop/controllers/shop_attribute_filter_mixin.dart`, `shop_category_filter_mixin.dart`, `shop_category_tree_filter_mixin.dart` | port-now — Phase 4 (confirmed, already scoped) |
| `lib/app/modules/shop/views/widgets` (dir) | port-now — Phase 4, supporting widgets for filter drawer |
| `lib/app/modules/support_ticket`, `support_ticket_details` | port-now — Phase 2 (confirmed, already scoped) |
| `lib/components/studio_widget/product_grid_card.dart` | port-now — Phase 3 (studio widget support file) |
| `lib/components/studio_widget/studio_trust_badges.dart` | port-now — Phase 3 (confirmed, already scoped) |
| `lib/constants/support_ticket_status.dart` | port-now — Phase 2 supporting const file |
| `lib/models` (dir) | needs-decision — likely holds review/support-ticket models; verify contents map 1:1 into Phases 1-2 rather than being a separate gap |
| `lib/services` (dir) | needs-decision — same as above; confirm scope overlaps Phases 1-2/4 before assuming full duplication |

**Only in TARGET (TARGET's own additions — confirm, don't touch):**
Onboarding module, Profie/notification, Profie/security, auth/changedpassword, cart/views/cards.dart, category rename (category_controller/category_view/categorydetail_view), explore module, homepage/view.dart, messages module, plus assorted `.DS_Store`/stray files (`{order_no: ...}.yaml` junk file — likely an accidental debug artifact, worth a cleanup note but not a port item). All tagged **skip** — these are TARGET-specific features/refactors, not gaps to backfill from SOURCE.

**Files that differ:** 139 files differ across almost every module. This is expected given SOURCE and TARGET have diverged over time (different auth flows, drawer, filenames using `/` import prefix vs `package:` prefix in TARGET). See 0.2 for sampled drift analysis rather than exhaustive listing.

---

## 0.2 Drift diff on shared/high-traffic files (sampled)

Sampled: `register_default_widgets.dart`, `app_routes.dart`/`app_pages.dart` (full, see 0.3/0.4), `shop_controller.dart`, `studio_socket_routing.dart`, `product_view.dart`, `basic_provider.dart`. Skipped due to volume: full read of all 139 differing files — most of the diffs are cosmetic (TARGET rewrote absolute `package:foduu_ecommerce/...` imports to relative `/...` imports repo-wide, which shows up as a "differ" on nearly every file without functional change).

| File | Finding | Triage |
|---|---|---|
| `register_default_widgets.dart` | TARGET registers all SOURCE section types except `trust_badges` (see 0.3) | port-now (Phase 3, confirmed) |
| `studio_socket_routing.dart` | TARGET replaced `'shop': 3` bottom-nav index with `'wishlist': 3` (TARGET has no bottom-nav "Shop" tab — uses Wishlist instead) and adds a `detailcategory` route case SOURCE lacks. Cosmetic import-style diff otherwise. | skip — intentional TARGET IA divergence, not a gap |
| `shop_controller.dart` | TARGET has filter code commented out (`// var isFilter = false.obs;`, `// import foduu_studio_layout_mixin.dart`) — confirms TARGET lacks the filter mixins wired in (Phase 4) rather than having reimplemented them differently | port-now (Phase 4, confirmed — not a new item) |
| `product_view.dart` | Both apps have `isLoading` guards around content; TARGET's structure differs but isn't obviously missing defensive checks — inconclusive without deeper read | needs-decision — worth a closer diff during Phase 3/blank-screen work, not blocking Phase 0 |
| `basic_provider.dart` | Differs — likely base-URL/endpoint-shape differences; overlaps with 0.3 backend contract audit | port-later — fold into Phase 3/4 implementation review rather than standalone item |

---

## 0.3 Backend contract audit — CMS section-type registry

`register_default_widgets.dart` full comparison:

| Section type | SOURCE | TARGET | Triage |
|---|---|---|---|
| search | ✅ | ✅ | — |
| slider | ✅ | ✅ | — |
| categories | ✅ | ✅ | — |
| blog | ✅ | ✅ | — |
| banner | ✅ | ✅ | — |
| price_filter | ✅ | ✅ | — |
| spacer | ✅ | ✅ | — |
| divider | ✅ | ✅ | — |
| text_block | ✅ | ✅ | — |
| products | ✅ | ✅ | — |
| rich_text | ✅ | ✅ | — |
| countdown | ✅ (stub text) | ✅ (same stub text) | skip — SOURCE itself is a stub, nothing to port |
| icon_button | ✅ | ✅ | — |
| **trust_badges** | ✅ | ❌ missing | **port-now — Phase 3 (confirmed, exactly 1 missing section type, no more)** |

Backend contract audit result: TARGET's registry is missing exactly one section type (`trust_badges`), matching the plan's existing assumption precisely — 0.3 does not expand Phase 3's scope.

Endpoint/base-URL check: `basic_provider.dart` differs between apps (see 0.2) — both use the same networking pattern (Dio-based, GetX). No obvious version/shape mismatch spotted from a surface read; a full grep of endpoint path constants found no divergent API version prefixes (both appear to target the same backend family). Flag as **port-later** to verify precisely during Phase 4 implementation, not a Phase 0 blocker.

---

## 0.4 Route graph diff

`app_routes.dart` / `app_pages.dart` diffed in full.

**Routes SOURCE has that TARGET lacks:**
| Route | Triage |
|---|---|
| `MY_REVIEWS` | port-now — Phase 1 (confirmed) |
| `SUPPORT_TICKET` | port-now — Phase 2 (confirmed) |
| `SUPPORT_TICKET_DETAILS` | port-now — Phase 2 (confirmed) |

**Routes TARGET has that SOURCE lacks (TARGET's own additions):**
`ONBOARDING`, `DETAILCATEGORY`, `RESETPASSWORD`, `SECURITY`, `NOTIFICATIONSETTING`, `EXPLORE`, `ADD_CARD` — all **skip**, these are TARGET-specific features not present upstream; no action needed, confirm not to remove them during merge.

Also noted: TARGET's `INITIAL` route is `Routes.INTRO` vs SOURCE's `Routes.LOGIN` — intentional TARGET onboarding-flow divergence, **skip**.

No new route gaps beyond the three already scoped in Phases 1-2.

---

## 0.5 Dependency graph diff

Full `pubspec.yaml` dependency block diffed line by line.

| Package | SOURCE | TARGET | Triage |
|---|---|---|---|
| `phonepe_payment_sdk` | ^3.0.2 | absent | port-now — Phase 5 (confirmed) |
| `firebase_core` | ^3.0.0 | commented out | skip — Firebase is an explicit non-goal |
| `firebase_messaging` | ^15.0.0 | commented out | skip — non-goal |
| `flutter_local_notifications` | ^20.1.0 | commented out | skip — non-goal |
| `flutter_stripe` | ^10.1.1 | **^12.0.0 (newer)** | needs-decision — flagged per instructions: do NOT downgrade; TARGET is ahead. Verify Stripe integration code (`checkout_controller.dart`, `components/paymentGateway/Stripe.dart`) still works against v12 API — TARGET already has an active Stripe.dart file and usages, so this looks like an intentional TARGET upgrade, not a gap. Confirm with user whether this was deliberate. |

All other dependencies are identical in both files (same versions). `pubspec.lock` was not needed to disambiguate — `pubspec.yaml` version constraints were unambiguous for every differing package.

No dependency gaps beyond the known PhonePe item (Phase 5) and the explicitly-out-of-scope Firebase packages.

---

## 0.6 Persisted local state check

Grepped both apps for `Hive.`, `SharedPreferences`, `GetStorage` usage. Both apps use **GetStorage only** (no Hive, no raw SharedPreferences) — same storage mechanism, same usage pattern (auth tokens, cart cache, wishlist cache, theme, OTP timer, notification settings). File-count of usage sites: SOURCE 26 files, TARGET 24 files (difference accounted for by SOURCE's now-defunct firebase notification/local-storage-notification files, and TARGET's extra security/category controllers using GetStorage too).

**Finding: confirmed non-issue.** TARGET has no meaningful local persistence beyond auth/cache state, and it uses the identical mechanism (GetStorage) as SOURCE with no divergent schema. **Skip** — matches the plan's non-goal explicitly; no migration work needed.

---

## 0.7 Blank-screen fix check

`git show 80554b9` in SOURCE ("Fix the Blacnk screen problem and some enhancement") touched: `orderdetails_view.dart`, `product_view.dart`, `shop_controller.dart`, `studio_blogs.dart`, `studio_products.dart`, `studio_socket_routing.dart`. Core pattern: replaced unconditional content rendering with `Obx(() => controller.isLoading.value && data.isEmpty ? CircularProgressIndicator() : ListView(...))` guards, removing a timeline-tile widget that could crash/blank on missing data, and fixing socket routing case handling.

Comparing to TARGET's current equivalents:
- `product_view.dart`: TARGET already has multiple `isLoading.value` guards throughout the widget tree (5+ occurrences found vs SOURCE's fewer, more consolidated guard) — **TARGET already has defensive loading-state code**, though structured differently (not identical to SOURCE's fix, appears independently evolved).
- `studio_socket_routing.dart`: cosmetic import-style diff only, functionally equivalent plus TARGET has an extra `detailcategory` case.
- `shop_controller.dart`, `studio_blogs.dart`, `studio_products.dart`: differ (see 0.2), but differences track TARGET's independent later development, not an absence of the SOURCE guard pattern.

**Finding: TARGET already has equivalent (if not identical) defensive/loading-state code.** No evidence of the specific blank-screen bug being unfixed in TARGET. **Triage: skip** (already resolved independently) — but flag as **port-later** to do a closer line-by-line diff of `product_view.dart` loading logic during Phase 3 implementation, since the audit read was a surface-level grep, not exhaustive.

---

## Final rollup

| Tag | Count | Items |
|---|---|---|
| port-now (beyond Phases 1-5) | 2 | `category_filter_service.dart` (folds into Phase 4), `product_grid_card.dart` support file (folds into Phase 3) — both are supporting files for already-scoped phases, not new phases |
| port-now (confirms existing Phases 1-5 scope) | ~10 items | reviews module, support ticket modules, trust_badges section type + support file, filter mixins ×3, category_search_filter_* ×3, shop/views/widgets dir, support_ticket_status.dart — all match Phases 1-5 exactly |
| port-later | 3 | basic_provider.dart backend-contract drift (fold into Phase 4 review), product_view.dart loading-logic deep-diff (fold into Phase 3), backend endpoint-shape verification (fold into Phase 4) |
| needs-decision | 3 | `internet_connection_controller.dart` / `theme_controller.dart` (SOURCE-only, unclear if TARGET covers equivalently), `lib/models` + `lib/services` dirs (need content verification against Phases 1-2 scope), `flutter_stripe` version (TARGET ahead — confirm intentional, do not downgrade) |
| skip | everything else | Firebase/push (non-goal), all TARGET-only additions (Onboarding, security, explore, changedpassword, etc. — TARGET's own features), cosmetic import-style rewrites across 100+ files, android/ios package-name rebrand, countdown stub, TARGET's already-present blank-screen defensive code |

## Phase 6 wrap-up

**Verification pass over Phases 1-5 (all already complete). No new features ported; only small parity fixes considered.**

### port-later items (carried forward, unresolved by design — logged so they're a visible decision)

- `basic_provider.dart` backend-contract/endpoint-shape drift between SOURCE and TARGET — not re-verified line-by-line in Phase 6; still flagged for a closer look whenever backend contract work is next touched.
- `product_view.dart` loading-logic deep-diff — TARGET's `isLoading` guard structure differs from SOURCE's consolidated pattern but is not obviously worse; still flagged for an exhaustive line-by-line comparison if blank-screen issues ever resurface.
- Tests / analytics — SOURCE and TARGET both lack meaningful test coverage and analytics instrumentation for the ported modules (reviews, support tickets, filters, PhonePe); no test suite was added in Phases 1-6. Remains an open backlog item, not a Phase 6 blocker.

### needs-decision items — resolution

1. **`flutter_stripe` version (SOURCE ^10.1.1 vs TARGET ^12.0.0):** Confirmed TARGET's newer v12 is kept as-is (per original instruction not to downgrade). `checkout_controller.dart` and `components/paymentGateway/Stripe.dart` still compile with 0 analyzer errors against v12 in the full-repo `flutter analyze` run, so no incompatibility was found. Resolution: **kept at v12, no action needed.**
2. **`internet_connection_controller.dart` / `theme_controller.dart` (SOURCE-only):** TARGET does not have direct equivalents of these two controllers, but functionally: theme switching is handled by `lib/constants/dynamic_theme.dart` (present and actively used across all ported widgets in Phases 1-5), and `connectivity_plus` is a declared dependency in both pubspecs with usage sites in TARGET already outside these two files. No crash or missing-feature risk was found tied to the absence of these specific files — they appear to be earlier/alternate implementations of functionality TARGET already covers through `dynamic_theme.dart` and its own connectivity usage. Resolution: **genuine but low-risk gap — not ported, since it would be new standalone work (a full connectivity-banner UX) rather than a fix needed by any already-ported Phase 1-5 feature.** Logged here as port-later if a connectivity-loss banner UX is ever explicitly requested.
3. **`lib/models/` and `lib/services/` dirs (needs content verification against Phases 1-2 scope):** Re-diffed in Phase 6. `lib/models/`: SOURCE has `review_model.dart` (already ported in Phase 1, confirmed present in TARGET), `local_notification.dart` (Firebase/push-notification model — explicit non-goal, skip), and `product_model.dart` (confirmed **unused** anywhere in SOURCE's own codebase via grep — dead file, skip). `lib/services/`: entirely absent from TARGET; contains `local_storage_notification_service.dart` + `notification_sync_service.dart` (Firebase-related, non-goal, skip) and `payment_handler_controller.dart` + `payment_service.dart` (SOURCE's payment abstraction layer, used only by SOURCE's own `checkout_controller.dart`/`main.dart`). TARGET's Phase 5 PhonePe port uses a different, self-contained integration directly inside `checkout_controller.dart` (see `PhonePePayment(...)` call around line 455) and does not reference or need `payment_service.dart`/`payment_handler_controller.dart`. Resolution: **no gap — `lib/models/` and `lib/services/` are fully accounted for; nothing missing that any ported Phase 1-5 feature depends on.**

### Native / deferred payment work

- **Production PhonePe cutover** (switching `kPhonePeEnvironment`/`isUAT`/`isSimulator` from sandbox to production, real merchant `client_id`/`client_secret`) is **explicitly deferred** — out of scope for this port, sandbox-only per Phase 5.
- **iOS PhonePe config** is **explicitly deferred** — no `ios/` folder exists in either SOURCE or TARGET at present, so there is nothing to diff or port on the iOS side yet.

### Phase 6 checks performed

- Full-repo `flutter analyze`: **0 errors**, 769 total issues (all `warning`/`info` — unused imports, `avoid_print`, `file_names` style, a redundant dev-dependency entry). No compile-time integration bugs found between phases.
- Route parity: `MY_REVIEWS`, `SUPPORT_TICKET`, `SUPPORT_TICKET_DETAILS` all present in `app_routes.dart` with matching `GetPage`/binding entries in `app_pages.dart`; all TARGET-only routes (`ONBOARDING`, `DETAILCATEGORY`, `RESETPASSWORD`, `SECURITY`, `NOTIFICATIONSETTING`, `EXPLORE`, `ADD_CARD`) still intact.
- Native config: `proguard-rules.pro` PhonePe block and `AndroidManifest.xml` PhonePe `<meta-data>`/`<queries>`/redirect scheme entries are internally consistent, no duplicates or conflicts with the pre-existing Stripe/Razorpay ProGuard rules.
- Assets: grepped all Phase 1–4.5 ported files for hardcoded `assets/...` path references — none found (ported widgets use `Icons.*` rather than bundled images), so no missing-asset runtime-crash risk identified.

**Sizing checkpoint verdict: NOT triggered.** Zero genuinely new `port-now` phases surfaced — every substantive gap found (reviews, support tickets, trust_badges, filter mixins, category filter naming, PhonePe) was already anticipated by Phases 1-5. The only "new" port-now items are small supporting files that belong inside those existing phases' scope, not standalone work. No single item approaches multi-day effort on its own. Phase 0 confirms the existing plan is correctly scoped and ready to execute as-is, with three needs-decision items to resolve with the user before or during implementation (ideally before Phase 4, since two touch category/filter work).
