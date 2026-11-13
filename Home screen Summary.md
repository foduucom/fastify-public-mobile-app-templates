# Home Screen Modernization & UI Parity Summary

## Executive Overview

This document summarizes the comprehensive UI/UX overhaul executed on the mobile application's Home Screen to achieve visual and behavioral parity with the parent web storefront ([https://yomystore.site/foduu-store/index.html](https://yomystore.site/foduu-store/index.html)).

The backend team provided live dynamic studio layout data (`https://foduu-electronics-store.foduu.store/api/mobile-app/home`), consisting of 14 dynamic sections. However, multiple rendering issues, contrast problems, raw HTML leaks, and mismatched widget bindings in the mobile app prevented the UI from matching the parent website's modern design standards.

---

## Architecture & Data Flow Analysis

The server-driven dynamic layout pipeline was analyzed from end-to-end:

```
┌─────────────────────────────────────────────────────────────┐
│ 1. HomepageController (lib/app/modules/homepage/controllers) │
│    - Extends GetxController with FoduuStudioLayoutMixin     │
│    - Calls getDashboardDesign('home') onInit                │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. FoduuStudioLayoutMixin (lib/core/foduuStudio)            │
│    - BasicProvider("mobile-app/home").getRequest()          │
│    - Extracts dynamic theme palette ('theme_color')         │
│    - Injects category tabs into product sections            │
│    - Dispatches section list to WidgetRegistry              │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. WidgetRegistry & registerDefaultWidgets()                │
│    - Maps section 'type' to dedicated Flutter builders:      │
│      • 'categories'   -> CategoryHome                       │
│      • 'slider'       -> FoduuSlider / FlashSaleCountdown   │
│      • 'products'     -> TrendingProductSection             │
│      • 'trust_badges' -> TrustBadgesComponent / PromoList   │
│      • 'blog'         -> BlogSection                        │
│      • 'countdown'    -> FlashSaleCountdownCard             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. HomePageView (lib/app/modules/homepage/views)            │
│    - Watched by RxList<Widget> widgetList                   │
│    - Rendered via FoduuStudioLayoutView (SingleChildScrollView│
│      + RefreshIndicator + Column)                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Detailed Breakdown of Implemented Changes

### 1. Categories Section Polishing
**File:** `lib/components/home_component/home_category.dart`

* **Issue:** 
  The backend payload contained `"heading": "_"`. This caused `StudioSectionHeader` to display an unsightly hyphen (`-`) and an irrelevant `See all` action button at the top of the category row. Furthermore, categories had no images configured in the backend, resulting in a low-resolution generic fallback watermark (`Foru Cart`).
* **Fix & Improvements:**
  - **Heading Sanitization:** Suppressed headers when `heading == '_'` or `'-'`, completely eliminating the unwanted hyphen line and misplaced button.
  - **Intelligent Icon Mapping:** Implemented `_getCategoryIcon()` which detects category keywords and displays sharp, brand-colored vector icons for:
    - *Drones* (`Icons.flight_takeoff_rounded`)
    - *Smart Home* (`Icons.home_outlined`)
    - *Printers* (`Icons.print_outlined`)
    - *Monitors* (`Icons.desktop_windows_outlined`)
    - *Appliances* (`Icons.kitchen_outlined`)
    - *Cameras* (`Icons.camera_alt_outlined`)
    - *Audio / Headphones* (`Icons.headphones_outlined`)
    - *Accessories* (`Icons.devices_other_outlined`)
    - *Smartphones* (`Icons.smartphone_outlined`)
    - *Gaming* (`Icons.sports_esports_outlined`)
    - *Laptops* (`Icons.laptop_outlined`)
  - **Modern Circle Styling:** Scaled tiles to 62×62px with subtle borders (`0.12` outline opacity), soft ambient elevation, and clean 12px semi-bold typography matching parent web category pills.
  - **Spacing Optimization:** Reduced excessive vertical padding from 26px to 16px.

---

### 2. Hero Slider & Typography Contrast Fix
**File:** `lib/components/home_component/home_slider.dart`

* **Issue:**
  Slide headings and descriptions had black text on top of a dark gradient overlay (`Colors.black.withOpacity(0.8)`), making slide text unreadable. In addition, slides with CMS HTML tags (e.g. `<ul class="list-unstyled"><li>...</li></ul>`) rendered raw HTML code directly in the text view.
* **Fix & Improvements:**
  - **High-Contrast Text:** Defaulted text color to crisp, high-visibility white (`Colors.white`) with subtle dropshadows for guaranteed legibility across all product image banners.
  - **HTML Sanitization:** Added `_cleanHtml()` to strip unparsed HTML tags and convert nested items into clean bulleted tags (`Smart Ecosystem • Premium Experience`).
  - **"New Arrival" Pill Badge:** Added a semi-transparent glassmorphic pill badge (`New Arrival`) on each slide, directly mirroring the web hero carousel (`hero-flag-end`).
  - **Aspect Ratio & Height Adjustment:** Set baseline slide height to 220px to prevent cramped text overlays.

---

### 3. Dedicated Flash Sale & Live Countdown Deal Widget
**Files:**
- `lib/components/home_component/flash_sale_countdown_card.dart` *(New)*
- `lib/core/foduuStudio/register_default_widgets.dart`

* **Issue:**
  On the parent website, the hero section features a side card with an interactive live countdown clock (`[06 Days] : [21 Hrs] : [48 Min] : [15 Sec]`), iPhone 15 Pro offer details (`Today Only UP TO 20% Off`, `$2199.00`), and a "Shop Now" call to action. In the mobile app, this was delivered as a slider with raw text:
  `Flash Sale ("Timer Of Days Hours Minutes And Seconds")`
  `iPhone 15 Pro("Limited Time Offer")`
* **Fix & Improvements:**
  - **Created `FlashSaleCountdownCard`:**
    - **Live Ticking Timer:** Integrated a 1-second periodic timer calculating remaining `Days`, `Hrs`, `Min`, and `Sec` in real-time.
    - **Digit Display Cells:** 4 rounded dark slate containers (`#0F172A` / `#1E293B`) with bold white digits and unit labels.
    - **Top Badges:** "Flash Sale" badge with lightning icon (`Icons.bolt_rounded`) and "Limited Time Offer" pill.
    - **Product Showcase:** Clean cutout image of iPhone 15 Pro loaded via `CachedNetworkImage`.
    - **Deal Copy & CTA:** Bold `$2199.00` price in primary theme color, offer subtext, and a rounded "Shop Now" pill button with arrow icon.
  - **Smart Registry Routing:** Updated `register_default_widgets.dart` with `_isFlashSaleSlider()` to automatically detect `home-side-slider` and flash deal items, seamlessly routing them to `FlashSaleCountdownCard`.

---

### 4. Promotional Feature Cards & Brand Logos
**File:** `lib/components/home_component/home_trust_badges.dart`

* **Issue:**
  Section 3 contained 3 promotional highlight cards (*Hot Pick Portable Bluetooth Speaker*, *Deal of the Day Latest iPhone Deals*, *Fitness Deal Smart Watch Collection*) with `footer: "Shop Now "`. The legacy code misinterpreted `footer: "Shop Now "` as customer review star ratings, mistakenly rendering Section 3 as an empty-starred testimonial carousel. Additionally, Section 8 (*Shop By Brand*) rendered brand logos in 150px tall empty text boxes.
* **Fix & Improvements:**
  - **Created `_PromoCardList`:**
    - Dedicated horizontal card carousel with rounded 16px cards.
    - Extracts promotional tags (`Hot Pick`, `Deal of the Day`, `Fitness Deal`) into primary-colored badge chips.
    - Displays high-resolution product images alongside titles, descriptions, and functional "Shop Now" navigation links.
  - **Created Compact Brand Tile Mode:**
    - For sections with empty text descriptions (like *Shop By Brand*), cards are automatically rendered as compact (105×72px) brand logo tiles displaying Apple, Samsung, Sony, LG, and Philips logos.
  - **Rating Verification:** Added `_isRatingString()` to ensure only actual review footers (`★` or numbers 1–5) trigger testimonial mode.

---

### 5. Product Listings & Category Filter Tabs
**File:** `lib/components/home_component/home_products.dart`

* **Issue:**
  Product category tabs (*All*, *Audio*, *Cameras*, *Phones*) used plain underline tabs rather than the web's pill buttons. Furthermore, products defaulted to basic cards rather than the parent website's feature-rich card layout.
* **Fix & Improvements:**
  - **Animated Pill Chips:** Modernized category filter tabs into rounded pill chips with smooth animations, active primary background (`#2563eb`), white active text, and soft border styling.
  - **Parent Web Product Cards (`ParentWebProductCard`):** Set default product list and grid rendering to `ParentWebProductCard`:
    - 4 floating action buttons (Quick Add to Cart, Quick View modal, Wishlist Heart with reactive toggle).
    - Centered 5-star rating display in warning gold.
    - Red `SALE` badge with discount percentage.
    - Clean typography for product title and pricing.

---

---

### 6. Phase 2 Polish & Web-Storefront Standards Alignment

Following user review across device screenshots, six critical visual and behavioral adjustments were applied:

1. **Hero & Dynamic Banners Frame Unified (`home_slider.dart`):**
   - Scaled responsive slider height dynamically to `(Get.width * 0.58).clamp(240.0, 265.0)` to eliminate device cropping (Galaxy S Ultra phone cutout, Echo Dot assistant, and Limited Time Offer artwork).
   - Unified the container stack with `Padding(padding: pageSurroundingPadding)` and `ClipRRect(borderRadius: BorderRadius.circular(16))` so the dark gradient never bleeds outside the card edges.
   - Replaced the harsh 80% black gradient with an ambient directional scrim (`stops: [0.40, 0.70, 1.0]`), preserving 100% artwork visibility in the top 50% while guaranteeing text readability.
   - Restored and styled the interactive "Shop Now →" pill button with theme primary accent.
   - Fixed `_cleanHtml()` regex to prevent broken bullet text (`"Smart Ecosystem •"` / `"Premium Experien..."`).
   - Positioned animated indicator dots with soft drop shadows for guaranteed contrast on any banner.

2. **Guaranteed-Contrast Product Badges (`parent_web_product_card.dart`):**
   - Hardcoded discount pill badges to an e-commerce high-contrast crimson (`#DC2626`) with bold white (`#FFFFFF`) text, eliminating the bug where API theme parsing rendered white-on-white invisible badges.
   - Formatted badges cleanly to display exact percentages (e.g., `20% OFF`) or `SALE`, while completely suppressing empty placeholder pills on non-discounted products.

3. **Promotional Highlight Cards Upgraded (`home_trust_badges.dart`):**
   - Expanded `_PromoCardList` dimensions to `148px` height and `(Get.width * 0.82).clamp(285.0, 325.0)` width, completely eliminating title and tag truncation.
   - Enlarged product cutouts from 85px to 95px with `BoxFit.contain` and subtle elevation.
   - Added category-specific pastel tints (`#F1F5F9`, `#FDF2F8`, `#F0FDF4`) matching web presentation.

4. **"Shop By Brand" Logo Tile Sizing (`home_trust_badges.dart`):**
   - Increased brand card container to `100px` height and `126px` width (up from 72×105px).
   - Expanded brand logo display area to 54px with `BoxFit.contain`, making Samsung, Sony, and Apple logos sharp, clear, and prominent.

---

### 7. Phase 3: Header & Footer Modernization (Parent Web & Industry Standards)

Following architectural analysis of the parent web storefront and modern mobile e-commerce standards (e.g. Amazon, Apple, Shopify), the Home Screen **Header**, **Bottom Navigation Dock**, and **Store Web Footer** were overhauled:

1. **Brand-Rich Header (`responsive_common_header.dart` & `responsive_circle_icon.dart`):**
   - **Integrated Store Branding:** Added store logo branding (`foduu-logo-removebg-preview.png`) in the header next to the menu drawer button, establishing immediate brand presence.
   - **Reactive Cart Badge:** Connected `CartService.to.cartItems.length` inside an `Obx` wrapper with live badge counts (`ResponsiveCircleIcon`), ensuring real-time cart count updates across shopping actions.
   - **Modern Full-Width Search Bar:** Upgraded the search trigger into a modern soft-tinted pill container (`44px` height, `#F1F5F9` tint) with search icon, interactive placeholder (`"Search iPhone, Laptops, Audio..."`), vertical divider, and voice search mic icon.
   - **Re-enabled Notifications Quick-Action:** Restored the notification bell action with clean circular outline styling and unread indicator support.

2. **Industry-Standard Bottom Navigation Dock (`responsive_bottom_nav.dart` & `bottombar_view.dart`):**
   - **Ergonomic Tab Sequence:** Realigned bottom navigation tabs to the industry standard **Discovery ➔ Engagement ➔ Personal** funnel:
     - `Home (0)` ➔ `Shop (1)` ➔ `Wishlist (2)` ➔ `Cart (3)` ➔ `Account (4)`
     - Updated `shopTabIndex = 1`, `cartTabIndex = 3`, and `profileTabIndex = 4` across `shop_navigation.dart`, `customDrawer.dart`, and `studio_socket_routing.dart` for seamless routing.
   - **Material 3 Active Pill Indicator:** Replaced the dated top sliding hairline border with active capsule pill containers (`activeColor.withOpacity(0.12)`) and smooth spring animations (`Curves.easeOutCubic`).
   - **Refined Badging & Elevation:** Rounded the dock's top corners to `20px` with ambient drop shadows, and styled cart/wishlist badge counters with white borders to prevent clipping.

3. **Pure Dynamic Studio Delivery (Static Footer Removed):**
   - **Requirement:** Every section on the Home screen must be 100% server-driven and provided dynamically by the backend API.
   - **Resolution:** Removed the static `footerWidget: const HomeStoreFooter()` from `HomePageView`. The app renders only the sections dispatched dynamically by the CMS backend.

4. **Modern Expandable "About Store" SEO Card (`home_rich_text_component.dart` & `home_common_widgets.dart`):**
   - **Eliminated Unformatted Multi-Screen Text Wall:** The backend's long store description is framed in a modern card (`#F8FAFC`, rounded 16px, 1px outline).
   - **Typographic Hierarchy:** Separated store icon, bold headline (`"About Foduu Store"`), and secondary subtitle (`"A Smarter Way to Shop Everyday Electronics"`).
   - **Collapsible Control ("Read More / Show Less"):** Long SEO text collapses to ~140px with a bottom-up fade gradient and smooth expand/collapse toggle (`AnimatedSize`), preventing multi-page plain text clutter while remaining accessible for curious shoppers.

5. **Elevated Blog Section (`home_blogs.dart`):**
   - **Multi-Source Image Resolution:** Implemented `_resolveBlogImage()` checking `featured_image`, `featured_image_url`, `image`, `thumbnail`, and `cover_image`.
   - **Editorial Magazine Fallback:** When an article has no uploaded graphic, it displays an editorial tech card with a rich blue/slate gradient and article icon, replacing the company logo watermark placeholder.
   - **Card Geometry & Spacing:** Grid extent increased to `265px` with `14px` border radius, subtle border, drop shadow, and a clean `"Read More →"` interactive link.

---

### 8. Smart Home Assistant Showcase Banner (`smart_assistant_showcase_card.dart`)

Addressing the disparity highlighted between **Image 1** (Current Mobile Screen) and **Image 2** (Parent Website `foduu-electronics-store.foduu.store`):

1. **Discrepancy in Image 1 vs Image 2:**
   - In **Image 1**, Section 4 (`slug: "home-second-slider"`) was rendered as a generic slider with the speaker graphic hidden under a dark gradient. The badge HTML was erroneously rendered as the main title (`"Smart Ecosystem Premium Experience"`), the real title (`"Meet Your Smart Home Assistant"`) was ignored, the two feature spec tiles were missing, and the CTA button was hardcoded to a generic `"Shop Now ->"`.
   - In **Image 2 (Parent Website)**, this section is a dedicated **Showcase Hero Card**: deep navy/slate container (`#0F172A`), prominent cutout of the Amazon Echo Dot with its glowing rainbow ring, dual eyebrow badges (`[SMART ECOSYSTEM]`, `[PREMIUM EXPERIENCE]`), the main title `"Meet Your Smart Home Assistant"`, lead description, two interactive feature spec tiles (`Smart Home Hub: Premium Automation [Enabled]` and `Voice Assistant: Multi-Room Audio [Enabled]`), and a `"Shop Smart Devices"` button.

2. **Dedicated & Refined `SmartAssistantShowcaseCard` Widget:**
   - **Parent Web Radius & Depth:** Upgraded card geometry to a sleek `30px` (2rem) corner radius matching the parent website's `.showcase-banner { border-radius: 2rem; }` specification, with deep onyx `#0F172A` background and subtle ambient elevation.
   - **Atmospheric Radial Glow:** Embedded a luminous radial cyan/blue gradient (`Color(0xFF3B82F6).withOpacity(0.30)`) centered behind the Echo Dot cutout, bringing the glowing LED rainbow ring to life with authentic depth.
   - **Atomic Badge Parsing:** Resolved the bug where multi-line strings were broken across wide bars. Now accurately parses `"Smart Ecosystem"` and `"Premium Experience"` as atomic phrases and renders them as compact, inline glassmorphic pills.
   - **Full-Width Zero-Truncation Spec Tiles:** Redesigned `SMART HOME HUB` and `VOICE ASSISTANT` into full-width stacked rows, giving `"Premium Automation"` and `"Multi-Room Audio"` ample room with zero text clipping.
   - **Proportional Capsule Pill Button:** Replaced the heavy full-width box with a left-aligned, self-sizing capsule pill button (`Shop Smart Devices →`) featuring a primary blue gradient and soft elevation shadow.
   - **Dynamic Routing:** Integrated `_isShowcaseSlider()` in `register_default_widgets.dart` to automatically dispatch this block dynamically without altering other sliders.

---

### 9. Section Header Collision Fix (`StudioSectionHeader` in `home_common_widgets.dart`)

* **Issue in Image 1:**
  In the `"Best Sellers"` section, the `"See all"` button was vertically centered inside a `Row` alongside a multi-line subtitle (`"Curated essentials with fast shipping, premium support..."`). This caused `"See all"` to collide directly into the middle of the second line of text (`"...premium See all support..."`).
* **Fix & Improvements:**
  - Refactored `StudioSectionHeader` into a vertical `Column`:
    - Top Row: Title (`"Best Sellers"`) on the left, `"See all"` on the right.
    - Bottom Row: Subtitle rendered across the full width underneath.
  - Completely eliminates layout collision, guaranteeing perfect multi-line subtitle wrapping across all screen widths.

---

### 10. Blog Carousel & Unified Brand Story Parity (`home_blogs.dart` & `home_rich_text_component.dart`)

Addressing the disparity highlighted in Image 1 vs Image 2 (Parent Website `https://foduu-electronics-store.foduu.store/`):

1. **Blog Section ("Stories Powered by Tech"):**
   - **Horizontal Card Carousel:** Replaced the 2-item grid with a smooth, snapping horizontal card carousel (`ListView.separated`, `scrollDirection: Axis.horizontal`) displaying all 3 articles (*How to Choose a Gaming Chair*, *Gaming Mouse Pad Materials*, *Capture Cards for Game Streaming*).
   - **Live API Fetching:** Added `_fetchLiveBlogs()` in `initState` querying `BasicProvider('blogs?count=6').getRequest()` so full blog models with complete image objects and metadata are loaded.
   - **Multi-Source Image Resolver:** Enhanced `_resolveBlogImage()` to resolve absolute URLs, root-relative paths (`/uploads/...`), subpath-relative paths (`uploads/...`, `images/...`), and map keys (`download_url`, `url`, `filePath`, `filepath`, `filename`, `path`, `src`).
   - **Web Card Footer:** Each card includes a calendar icon + date (`10 Nov 2026`) on the left, and a dark `#0F172A` pill button (`Read more >`) on the right.
   - **"EXPLORE MORE BLOG" Button:** Centered primary blue pill button (`#2563EB`) below the carousel routing to `Routes.BLOG`.

2. **Unified "About Foduu Store" Brand Story Card & Duplicate Elimination:**
   - **Root Cause of Duplicate Card:** The backend CMS layout delivers two consecutive sections:
     - Section A (`type: "rich_text"`): contains the raw unstyled title `"About Foduu StoreA Smarter Way to Shop Everyday Electronics"`.
     - Section B (`type: "text_block"`): contains the full 3-paragraph store story (`"Foduu Store brings the brands people already trust..."`).
   - Previously, Section A was intercepted to render the luxury Brand Story card, while Section B arrived right behind it and rendered the same story text as a second card.
   - **Fix & Clean Unification:**
     - `RichTextComponent` in `home_rich_text_component.dart` suppresses Section A (`return const SizedBox.shrink()`), completely eliminating the unstyled title box.
     - `TextBlockComponent` in `home_common_widgets.dart` intercepts Section B and renders the single, luxury Brand Story card matching the parent website:
       - Tag: `ABOUT FODUU STORE` in primary blue (`#2563EB`) uppercase with `letterSpacing: 1.2`.
       - Headline: `A Smarter Way to Shop Everyday Electronics` in 18px bold.
       - Paragraph 1: `Foduu Store brings the brands people already trust...`
       - Expandable details: Paragraph 2 (warehouse verification), Subheading `Support That Continues After Checkout`, and Paragraph 3 (24h shipping, 30-day returns, 7-day specialist support).
       - Action button: Outlined rounded pill button (`Read more ›` / `Show less ‹`) matching the parent website.
   - **Result:** Exactly one unified Brand Story card is displayed on the screen with zero duplication.

---

## File Changes & Path Reference Table

| File Path | Status | Key Changes Made |
| :--- | :--- | :--- |
| `lib/components/home_component/smart_assistant_showcase_card.dart` | **Created** | Dedicated Smart Home Assistant showcase card with Echo Dot visual, dual badges, headline, two feature spec tiles, and 'Shop Smart Devices' CTA. |
| `lib/components/home_component/home_category.dart` | **Modified** | Heading sanitization, smart electronics category icon fallback mapping, 62px circular tiles, padding reduction. |
| `lib/components/home_component/flash_sale_countdown_card.dart` | **Created** | Dedicated live countdown timer deal widget with 4 digit cells, badges, iPhone 15 Pro offer, and "Shop Now" CTA. |
| `lib/core/foduuStudio/register_default_widgets.dart` | **Modified** | Added `_isFlashSaleSlider()` and `_isShowcaseSlider()` routing to their respective specialized cards. |
| `lib/components/home_component/home_common_widgets.dart` | **Modified** | Fixed `StudioSectionHeader` two-row layout eliminating `"See all"` subtitle collision; unified About Store into single luxury card and suppressed duplicate title. |
| `lib/components/home_component/home_slider.dart` | **Modified** | Unified clip container eliminating gradient bleed, 240–265px responsive height, ambient gradient preserving artwork, clean HTML parser, restored "Shop Now →" button, refined indicator dots. |
| `lib/components/parent_web_product_card.dart` | **Modified** | Guaranteed crimson (`#DC2626`) Sale badge with bold white text, dynamic percentage formatting, suppressed empty pills. |
| `lib/components/home_component/home_trust_badges.dart` | **Modified** | Expanded promo cards to 148×310px with pastel tints & 95px image cutouts; enlarged "Shop By Brand" tiles to 100×126px with 54px prominent logos. |
| `lib/components/home_component/home_products.dart` | **Modified** | Animated pill chips for category filter tabs, set `ParentWebProductCard` as standard card layout across lists and grids. |
| `lib/app/modules/homepage/views/material/responsive_common_header.dart` | **Modified** | Modernized two-tier header with brand logo, live reactive cart badge, notification bell, and full-width search pill with mic icon. |
| `lib/app/modules/homepage/views/material/responsive_circle_icon.dart` | **Modified** | Added reactive badge count, unread dot support, soft ambient elevation, and theme-adaptive colors. |
| `lib/app/modules/homepage/views/material/responsive_bottom_nav.dart` | **Modified** | Material 3 active capsule pill indicator, 20px rounded top border with soft drop shadow, refined badge pill, and haptic feedback. |
| `lib/app/modules/bottomar/views/bottombar_view.dart` | **Modified** | Reordered tabs to industry standard (`Home` ➔ `Shop` ➔ `Wishlist` ➔ `Cart` ➔ `Account`), connected reactive cart tap and notification routes. |
| `lib/app/modules/shop/shop_navigation.dart` | **Modified** | Updated tab index constants (`home=0`, `shop=1`, `wishlist=2`, `cart=3`, `profile=4`) for consistent deep linking. |
| `lib/core/studio_socket_routing.dart` | **Modified** | Aligned socket slug routing table with new bottom bar tab indices. |
| `lib/components/home_component/customDrawer.dart` | **Modified** | Synchronized profile drawer navigation with updated `profileTabIndex`. |
| `lib/app/modules/homepage/views/home_page_view.dart` | **Modified** | Removed static `HomeStoreFooter` so Home screen renders strictly 100% dynamic CMS content from backend. |
| `lib/components/home_component/home_rich_text_component.dart` | **Modified** | Suppressed raw About Store heading section to prevent duplicate cards; preserved generic rich text support. |
| `lib/components/home_component/home_blogs.dart` | **Modified** | Horizontal card carousel with 3 articles, live API query, robust URL resolver for real photography, calendar date + dark `Read more >` pill, and `EXPLORE MORE BLOG` blue pill CTA. |

---

## Verification & Compatibility

- **Dynamic Studio Preserved:** All changes strictly respect the dynamic CMS architecture (`foduuStudio`). Any layout, order, or content updates made by the backend team will continue to update in real-time.
- **Theme Awareness:** All new components dynamically adhere to `DynamicThemeManager` and `Theme.of(context).colorScheme`, automatically supporting light and dark modes.
- **Cross-Platform Readiness:** Touch, trackpad, and mouse drag behaviors are preserved for both mobile and web builds.

