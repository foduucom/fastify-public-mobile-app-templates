# Contact Us Module — Full Modernization & CMS Broadcasting Parity Summary

> **Last Updated:** 2026-11-27  
> **Parent Website:** [https://foduu-electro.foduu.store/contact](https://foduu-electro.foduu.store/contact)  
> **CMS API Endpoint:** `GET https://foduu-electro.foduu.store/api/mobile-app/contact-us`  
> **Form Schema API:** `GET https://foduu-electro.foduu.store/api/forms/contact`  
> **Form Submit API:** `POST https://foduu-electro.foduu.store/api/forms/contact/submit`  
> **Architecture Standard:** [CMS_Broadcasting_Parity_Summary.md](CMS_Broadcasting_Parity_Summary.md)

---

## 1. Executive Summary

The **Contact Us** module (`lib/app/modules/contact/`) was fully modernized from a hardcoded, static layout to a **100% server-driven (SDUI)** implementation, achieving complete CMS Broadcasting parity with:

1. **Parent Website** (`foduu-electro.foduu.store/contact`) — visual and structural alignment
2. **Live CMS API** (`log.txt`) — exact 4-section dynamic layout
3. **CMS Broadcasting & SDUI Standard** — `FoduuStudioLayoutMixin`, `FoduuStudioLayoutView`, `WidgetRegistry`, `StudioSocketRouting`, and GetX lifecycle hardening
4. **About Us module pattern** — consistent architecture across both CMS-driven pages

---

## 2. Problems Identified & Resolved

### 2.1 Hardcoded View Bypassing CMS (Critical)

| Aspect | Before | After |
|--------|--------|-------|
| **View** | Hardcoded `ListView` with 5 static sections (`ContactHeroBannerWidget`, `ContactFormCardWidget`, `ContactChannelsWidget`, `ContactFaqAccordionWidget`, `ContactFaqCtaWidget`) | Pure `FoduuStudioLayoutView` — 0 hardcoded sections |
| **Controller slug** | `fetchLayout('contact')` → returned `{"status":"success"}` with **no sections** | `fetchLayout('contact-us')` → returns all 4 live CMS sections |
| **Fallback sections** | Injected `Contact Information` and `contact_map` (not in CMS) | Exactly 4 sections matching `log.txt`: `slider`, `rich_text`, `text_block`, `formbuilder` |

### 2.2 `rich_text` Rendering Defect

| Aspect | Before | After |
|--------|--------|-------|
| **Appearance** | `"Let's ConnectSend Your Message"` shown as raw concatenated text inside a gray rounded pill box (generic `RichTextComponent`) | Parsed into → **"LET'S CONNECT"** primary-accent eyebrow pill + **"Send Your Message"** bold 22sp heading |
| **Widget** | Generic `RichTextComponent` | New **`ContactSectionHeaderWidget`** with intelligent parsing (HTML tags, concatenated strings, camelCase boundary) |

### 2.3 `text_block` Rendering Defect

| Aspect | Before | After |
|--------|--------|-------|
| **Appearance** | Oversized `16sp` hardcoded `#000000` text (broken in dark mode) | Clean `13.5sp` muted subtitle, theme-aware |
| **Widget** | Generic `TextBlockComponent` | New **`ContactIntroTextWidget`** + `TextBlockComponent` dark-mode fix |
| **Dark-mode fix** | `#000000` stayed black on dark backgrounds | `#000000` → `colorScheme.onSurface` when `isDark == true` |

### 2.4 `formbuilder` Title Defect

| Aspect | Before | After |
|--------|--------|-------|
| **Title** | CMS sends `"title": "HI"` → rendered as card header "▎ HI" | Short placeholder titles (< 3 chars or `"HI"`) are **suppressed**; `"Send Your Message"` from `rich_text` acts as the unified heading |

### 2.5 Form Schema Mismatch

| Aspect | Before | After |
|--------|--------|-------|
| **Fields** | `full_name`, `email`, `phone`, `message` + hardcoded privacy checkbox | `first-name`, `last-name`, `email_id`, `message` (matches `GET /api/forms/contact`) |
| **Layout** | Single-column stacked | 2-column First/Last Name row + single-column Email + Message |
| **Features** | None | `AutofillGroup`, `AutofillHints`, `TextInputAction.next/newline`, inline loading spinner, `GetStorage` user profile prefill |

### 2.6 GetX Lifecycle Re-Entrancy (Section 11.3 — Critical)

| Aspect | Before | After |
|--------|--------|-------|
| **Risk** | `register_default_widgets.dart` → `buildFormBuilder` called `Get.find<ContactController>()` synchronously during `WidgetRegistry.build()` → `StackOverflowError` from `lazyPut` re-entrancy during `onInit()` | `controller` parameter is **optional** on `ContactFormCardWidget`; resolution deferred to `build(BuildContext context)` via `_resolvedController` getter |
| **Imports** | `import 'contact_controller.dart'` and `import 'url_launcher'` in `register_default_widgets.dart` | Both **removed** |

---

## 3. Live CMS API Response Structure (`log.txt`)

The CMS endpoint `GET /api/mobile-app/contact-us` returns exactly **4 ordered sections**:

```
API: GET https://foduu-electro.foduu.store/api/mobile-app/contact-us
Header: access-key: d032b30cc2568579807cfca91ea7d85a99e099af2afe00cb
```

| Index | CMS `type` | Key Content | Mobile Widget |
|:-----:|:-----------|:------------|:--------------|
| **[0]** | `slider` (`contact-us-slider`) | `heading`: "Contact Us", `sub_heading`: "Get In Touch", `description`: "We are here for you! how can we help, We are here for you!", `filePath`: `2026/11/24/contact-us-2173b173.webp` | **`ContactHeroBannerWidget`** |
| **[1]** | `rich_text` | `html_content`: `"Let's ConnectSend Your Message"` | **`ContactSectionHeaderWidget`** |
| **[2]** | `text_block` | `text`: "Have questions or feedback? Fill out the form below and our team will get back to you shortly.", `color`: `#000000` | **`ContactIntroTextWidget`** |
| **[3]** | `formbuilder` | `form_id.slug`: `"contact"`, `form_id.label`: "Contact Us", `title`: "HI" | **`ContactFormCardWidget`** |

### Live Form Schema (`GET /api/forms/contact`)

| Field Name | Type | Label | Required |
|:-----------|:-----|:------|:--------:|
| `first-name` | `text` | First Name | ✅ |
| `last-name` | `text` | Last Name | ✅ |
| `email_id` | `email` | Email address | ✅ |
| `message` | `textarea` | Message | ✅ |

---

## 4. Architecture & Data Flow

```
┌────────────────────────────────────────────────────────────────────────┐
│ Foduu Studio Web Admin / CMS                                           │
│ - Reads app_config.json ("slug": "contact-us", "route": "/contact")    │
│ - Serves GET /api/mobile-app/contact-us (4 ordered sections)           │
│ - Serves GET /api/forms/contact (4 dynamic form fields)                │
│ - Broadcasts route & layout updates via Socket.IO                      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ ContactController (BaseController + FoduuStudioLayoutMixin)            │
│ - fetchLayout('contact-us') + 4-section canonical fallback             │
│ - fetchFormSchema('contact') & submitForm('contact', payload)          │
│ - FormApiService for schema + submission                               │
│ - User profile prefill (first/last name, email from GetStorage)        │
│ - buildLayout() override: detects formbuilder slug changes             │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ WidgetRegistry (register_default_widgets.dart) → ContactView           │
│ - [0] slider (contact-us-slider) → ContactHeroBannerWidget             │
│ - [1] rich_text                  → ContactSectionHeaderWidget          │
│ - [2] text_block                 → ContactIntroTextWidget              │
│ - [3] formbuilder (contact)      → ContactFormCardWidget               │
│ - Rendered in exact server order via FoduuStudioLayoutView             │
│ - No outer Obx wrapper (Section 11.2 compliant)                       │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Complete Inventory of Modified Files

### 5.1 Core Module Files

| File Path | Change | Description |
|:----------|:------:|:------------|
| `lib/app/modules/contact/controller/contact_controller.dart` | **[REWRITTEN]** | Uses `FoduuStudioLayoutMixin` with `fetchLayout('contact-us')`. 4-section `_canonicalFallbackSections` matching `log.txt`. `FormApiService` with slug `'contact'` for schema + submission. First/last name prefill from `GetStorage`. `buildLayout()` override detects formbuilder slug changes. No eager `Get.find` calls. |
| `lib/app/modules/contact/views/contact_view.dart` | **[REWRITTEN]** | Pure `FoduuStudioLayoutView` (no hardcoded `ListView`, no outer `Obx`). `AppBar` with back button, centered title, clean styling matching `AboutusView`. `GestureDetector` for keyboard dismissal. Pull-to-refresh via `onRefresh: controller.fetchContactLayout`. |

### 5.2 Widget Files

| File Path | Change | Description |
|:----------|:------:|:------------|
| `lib/components/contact_component/contact_widgets.dart` | **[HEAVILY MODIFIED]** | **ContactHeroBannerWidget**: Renders `heading`, `subHeading`, `description` from slider payload; uses `contact-us-2173b173.webp`; gradient overlay with `Home / Contact Us` breadcrumb pill. **ContactSectionHeaderWidget** (NEW): Parses concatenated `"Let's ConnectSend Your Message"` into eyebrow pill + bold heading via HTML stripping, known-phrase matching, and camelCase boundary fallback. **ContactIntroTextWidget** (NEW): Clean `13.5sp` muted subtitle for `text_block`. **ContactFormCardWidget**: Optional `controller` (lazy GetX resolution in `build()`), 2-col First/Last Name row, `AutofillGroup`/`AutofillHints`, suppresses short placeholders like `"HI"`, inline loading spinner on SEND MESSAGE button. **Removed**: `url_launcher` import, dead `_ContactChannelTile`, `_MapGridPainter`, and commented-out `ContactChannelsWidget` / `ContactLocationMapCard` sections. |

### 5.3 Widget Registry

| File Path | Change | Description |
|:----------|:------:|:------------|
| `lib/core/foduuStudio/register_default_widgets.dart` | **[MODIFIED]** | **Added**: `_isContactRichTextHeading()` matcher → `ContactSectionHeaderWidget` (for `rich_text` on contact route). `_isContactIntroText()` matcher → `ContactIntroTextWidget` (for `text_block` on contact route). **Removed**: `import 'contact_controller.dart'`, `import 'url_launcher'`, eager `Get.find<ContactController>()` from `buildFormBuilder`, `_handleContactCardTap` function. **Commented out**: `contact_map` and `_isContactChannels` registrations (not in CMS payload). |

### 5.4 Data Models

| File Path | Change | Description |
|:----------|:------:|:------------|
| `lib/app/data/models/form_schema_model.dart` | **[MODIFIED]** | `fallbackContactFormSchema` updated to match live `GET /api/forms/contact`: `first-name` (text), `last-name` (text), `email_id` (email), `message` (textarea). Added `validate()` method and `FormSchemaOption` class. |
| `lib/app/data/models/contact_sections.dart` | **[MODIFIED]** | Updated `ContactHeroHeaderData` defaults and parsing. Updated `ContactFormBuilderData` with `badgeText`, `badgeSubtitle`, `eyebrow`, `subtitle` fields. `ContactLocationMapData` commented out (not in CMS). `ContactChannelCard` enhanced with `isWebsite`, `isAddress`, `normalizedWebsiteUrl` helpers. `ContactChannelsData` commented out (not in CMS). |

### 5.5 Shared Component Fix

| File Path | Change | Description |
|:----------|:------:|:------------|
| `lib/components/home_component/home_common_widgets.dart` | **[MODIFIED]** | `TextBlockComponent`: When CMS sends `#000000` and app is in dark mode, automatically uses `colorScheme.onSurface` instead of hardcoded black. Affects both Contact Us and any other SDUI page using `text_block`. |

---

## 6. Widget Registry Matching Logic

### 6.1 `_isContactHeroSlider(Map? json)` → `ContactHeroBannerWidget`
- Matches slider with `slug` containing `'contact-us-slider'` or `'contact-us'`
- Fallback: heading `"contact us"` or sub_heading containing `"get in touch"`

### 6.2 `_isContactRichTextHeading(Map? json)` → `ContactSectionHeaderWidget`
- Matches `rich_text` on the `/contact` route
- Checks `html_content` contains `"connect"` or `"message"` (case-insensitive)

### 6.3 `_isContactIntroText(Map? json)` → `ContactIntroTextWidget`
- Matches `text_block` on the `/contact` route
- Checks `text` contains `"questions"` or `"feedback"` (case-insensitive)

### 6.4 `formbuilder` → `ContactFormCardWidget`
- All `formbuilder` / `form_builder` sections → `ContactFormBuilderData.fromContentJson()`
- Controller resolution **deferred to `build()`** (GetX lifecycle safe)

---

## 7. ContactSectionHeaderWidget — Parsing Strategy

The CMS sends `rich_text` with `html_content: "Let's ConnectSend Your Message"` (concatenated, no HTML tags). The widget uses a 4-tier parsing strategy:

1. **HTML Tag Stripping**: Replace `<br>`, `</p>`, `</div>`, `</h1-h6>`, `</span>` with `\n`, then strip remaining tags and decode HTML entities (`&rsquo;`, `&#39;`, `&amp;`)
2. **Newline Split**: If result contains `\n`, split into parts → first part = eyebrow, rest = heading
3. **Known-Phrase Match**: If lowercase starts with `"let's connect"` and has more text → split at phrase boundary
4. **CamelCase Boundary Fallback**: Find `[a-z][A-Z]` boundary (e.g., `"...ct" + "Se..."`) → split there

**Result**: `eyebrow = "LET'S CONNECT"` (primary-accent pill) + `heading = "Send Your Message"` (bold 22sp)

---

## 8. ContactFormCardWidget — Key Features

### 8.1 Dynamic Schema-Driven Fields
- Loads field definitions from `GET /api/forms/contact` at runtime
- Falls back to `FormSchemaField.fallbackContactFormSchema` if API unavailable
- Cached in `GetStorage` under key `'cms_form_schema_contact'`

### 8.2 Smart Field Detection & UI Adaptation
| Detection | Behavior |
|:----------|:---------|
| `first-name` + `last-name` adjacent | 2-column `Row` layout |
| `type == 'email'` or name contains `'email'` | `TextInputType.emailAddress` + email validation |
| `type == 'tel'` or name contains `'phone'` | `TextInputType.phone` + digits-only filter + 15-char limit |
| `type == 'textarea'` or name `== 'message'` | `TextInputType.multiline` + 4 lines |
| Name contains `'name'` | Letters-only filter (`a-zA-Z\s'-`) |

### 8.3 User Profile Prefill
- Reads from `GetStorage('userDetails')` during `onInit()`
- Auto-fills `first-name` (first word of `name`), `last-name`, `email`

### 8.4 Title Suppression
- If CMS `title` is `"HI"`, empty, or < 3 characters → suppressed
- `"Send Your Message"` from `ContactSectionHeaderWidget` acts as unified heading

---

## 9. CMS Broadcasting & SDUI Compliance Checklist

| CMS Parity Rule | Status | Details |
|:-----------------|:------:|:--------|
| **Section 11.1** — `FoduuStudioLayoutMixin` with correct slug | ✅ | `fetchLayout('contact-us')` |
| **Section 11.2** — `FoduuStudioLayoutView` without outer `Obx` | ✅ | `ContactView` → `Scaffold.body = GestureDetector > FoduuStudioLayoutView` |
| **Section 11.3** — No eager `Get.find` during `onInit` | ✅ | `ContactFormCardWidget.controller` is optional; resolved in `build()` |
| **Section 11.4** — Order-preserving server-driven rendering | ✅ | `WidgetRegistry` renders in exact CMS section order |
| **Section 11.5** — Socket broadcast hot-refresh | ✅ | `StudioSocketRouting` handles `'contact-us'` and `'contact'` cases |
| **Section 11.6** — Canonical fallback matches live API | ✅ | 4-section `_canonicalFallbackSections` matches `log.txt` exactly |
| **Dark-mode safety** | ✅ | `TextBlockComponent` maps `#000000` → `colorScheme.onSurface` |

---

## 10. Verification Results

- **`flutter analyze`** across all modified files (`contact/`, `contact_component/`, `home_common_widgets.dart`, `register_default_widgets.dart`, `contact_sections.dart`, `form_schema_model.dart`): **0 errors, 0 warnings** (only pre-existing `info`-level `deprecated_member_use` and `prefer_interpolation_to_compose_strings`)
- **`git diff --check`**: Exit code `0` — no whitespace, syntax, or merge conflict issues

---

## 11. Visual Before/After Comparison

### Before (Broken State)
- Hero banner with raw breadcrumb overlay
- `"Let's ConnectSend Your Message"` shown as raw concatenated text in gray pill
- `"HI"` title rendered as form card header
- `"Contact Information"` section injected from fallback (not in CMS)
- `#000000` text broken in dark mode

### After (Current State)
- Clean hero banner with gradient overlay, `Home / Contact Us` breadcrumb pill, title, subtitle, description
- `"LET'S CONNECT"` eyebrow pill + **"Send Your Message"** bold heading (properly parsed)
- `"HI"` title suppressed — clean form card
- Only 4 CMS-driven sections rendered (no phantom sections)
- Dark-mode safe text rendering
- 2-column First/Last Name row with autofill hints
- Inline loading spinner on SEND MESSAGE button

---

## 12. Files NOT Modified (Intentionally)

| File | Reason |
|:-----|:-------|
| `lib/app/modules/Profie/contact/` | Legacy dead/mocked `ContactUsController` with `Future.delayed`. Not wired to current Contact Us route. Cleanup deferred. |
| `lib/core/studio_socket_routing.dart` | Already handles `'contact-us'` and `'contact'` cases correctly. No changes needed. |
| `lib/app/routes/app_pages.dart` | Contact Us route and binding already correctly configured. |
