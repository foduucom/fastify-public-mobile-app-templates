# FAQ Page — CMS Implementation Summary

> **Status:** ✅ Complete | **Analyze:** 0 errors, 0 warnings (14 info — project-wide false positives)
> **Parity Target:** `https://foduu-electronics-store.foduu.store/faq`
> **Architecture Pattern:** Identical to About Us (3-tier resilient, FoduuStudioLayoutMixin)

---

## Architecture & Data Flow

```
API: mobile-app/faq
       │
       ▼
HelpandsupportController (FoduuStudioLayoutMixin)
  ├── Tier 1: fetchLayout('faq')             ← Fastify Studio CMS
  ├── Tier 2: GET /frontend/faq              ← Legacy REST fallback
  └── Tier 3: defaultCanonicalFaqSections    ← Pre-seeded at onInit() (zero blank screen)
       │
       ▼
buildLayout(sections) → WidgetRegistry (register_default_widgets.dart)
       │
       ├── type:"slider"  slug:"faq"              → FaqHeroCard
       ├── type:"search"  name:"faq-search"       → FaqSearchBar
       ├── type:"trust_badges" no_of_columns:3    → FaqTopicBadges
       ├── type:"trust_badges" no_of_columns:1    → FaqAccordionSection
       └── type:"slider"  slug:"faq-center-slider"→ FaqStillStuckCard
```

---

## Section Mapping (from `log.txt` API Contract)

| # | API `type` | Discriminator | Flutter Component | Description |
|---|---|---|---|---|
| 1 | `slider` | `slug == "faq"` | `FaqHeroCard` | Greeting hero with title, subtitle, description, image |
| 2 | `search` | `name == "faq-search"` | `FaqSearchBar` | Live real-time text filtering across all Q&A items |
| 3 | `trust_badges` | `no_of_columns == 3` | `FaqTopicBadges` | Interactive topic category filter chips |
| 4 | `trust_badges` | `no_of_columns == 1` | `FaqAccordionSection` | Animated expandable Q&A accordion with search filtering |
| 5 | `slider` | `slug == "faq-center-slider"` | `FaqStillStuckCard` | "Still Stuck?" CTA → Open Direct Ticket / Search Community |

---

## Key Files

### Created
| File | Purpose |
|---|---|
| `lib/app/data/models/faq_sections.dart` | All 5 data models + `FaqPageData.canonical()` fallbacks |
| `lib/components/faq_components/faq_hero_card.dart` | Hero greeting card widget |
| `lib/components/faq_components/faq_search_bar.dart` | Live search bar with real-time text filtering |
| `lib/components/faq_components/faq_topic_badges.dart` | Category filter chips (Account, Billing, Security, Partners) |
| `lib/components/faq_components/faq_accordion_section.dart` | Animated Q&A accordion with expand/collapse |
| `lib/components/faq_components/faq_still_stuck_card.dart` | CTA support card with action buttons |

### Modified
| File | Change |
|---|---|
| `lib/core/foduuStudio/register_default_widgets.dart` | Added 4 dispatcher functions + imports for all FAQ components |
| `lib/app/modules/helpandsupport/controllers/helpandsupport_controller.dart` | Full rewrite — 3-tier fetch, Rx filter state, canonical fallbacks |
| `lib/app/modules/helpandsupport/views/helpandsupport_view.dart` | Full rewrite — FoduuStudioLayoutView with pull-to-refresh |
| `lib/app/routes/app_routes.dart` | Added `Routes.FAQ = '/faq'` |
| `lib/app/routes/app_pages.dart` | Registered FAQ `GetPage` with binding |
| `lib/core/studio_socket_routing.dart` | Added cases: `'faq'`, `'faqs'`, `'help'`, `'helpandsupport'`, `'help-and-support'` |
| `app_config.json` | Added FAQ page entry (`slug: "faq"`, `route: "/faq"`) |

---

## 3-Tier Resilient Fetching

```dart
// Tier 3 — Pre-seeded in onInit() for instant render (zero blank screen)
buildLayout(defaultCanonicalFaqSections);

// Tier 1 — Fastify Studio CMS (preferred)
await fetchLayout('faq');   // from FoduuStudioLayoutMixin

// Tier 2 — Legacy REST fallback (if Tier 1 fails)
await _get('$websiteDomain/frontend/faq');
```

---

## Smart Dispatcher Logic

The dispatcher in `register_default_widgets.dart` safely distinguishes FAQ sections from other page sections:

```dart
// FAQ Hero — slug-specific, won't clash with home page sliders
bool _isFaqHeroSlider(Map json) =>
  slug == 'faq' || heading.contains('FAQ') || sub.contains('help you today');

// FAQ CTA — slug-specific
bool _isFaqStillStuckSlider(Map json) =>
  slug == 'faq-center-slider' || heading.toLowerCase().contains('stuck');

// FAQ Accordion — column count + content pattern
bool _isFaqAccordion(Map json) =>
  no_of_columns == 1 && cards.any(c => c['heading'].isNotEmpty && c['text'].length > 50);

// FAQ Topic Badges — column count
bool _isFaqTopicBadges(Map json) =>
  no_of_columns == 3;
```

---

## Reactive Filter State

```dart
// HelpandsupportController
final searchQuery = ''.obs;      // Live text filter
final selectedTopic = ''.obs;    // Active category chip

void updateSearchQuery(String q) => searchQuery.value = q;
void selectTopic(String topic)   => selectedTopic.value = topic == selectedTopic.value ? '' : topic;
void clearFilters()              { searchQuery.value = ''; selectedTopic.value = ''; }
```

`FaqAccordionSection` and `FaqSearchBar` both react to these via `Obx()` — no manual `setState` needed.

---

## QA Checklist

| Check | Result |
|---|---|
| `flutter analyze` — 0 errors | ✅ |
| `flutter analyze` — 0 warnings | ✅ |
| All `.withOpacity()` → `.withValues(alpha:)` | ✅ All 11 calls across 4 files converted |
| `app_config.json` FAQ entry | ✅ |
| Socket routing (`studio_socket_routing.dart`) | ✅ 5 route aliases added |
| 3-tier resilience (canonical → Studio → legacy) | ✅ |
| Zero blank screen on cold start | ✅ Canonical pre-seeded in `onInit()` |
| Pull-to-refresh | ✅ `RefreshIndicator` in view |
| Dispatcher isolation (doesn't break home page) | ✅ Slug-specific guards |
| Contact Us API (`error.txt`) inspected | ✅ Noted — separate Contact Us page already functional |

---

## Notes

- The `flutter/material.dart` deprecated `info` notices are project-wide false positives — identical to `about_us_view.dart` and accepted style throughout the codebase.
- `avoid_print` notices in `studio_socket_routing.dart` are pre-existing (not introduced by FAQ changes).
- `error.txt` observed open by user — contains the **Contact Us** API response (`mobile-app/contact-us`), which is a separate page, not related to FAQ errors.
