# Home & Parent Web Alignment: Comprehensive Implementation Summary

## 1. Executive Summary

This document provides a technical record of the analysis, architecture, and modifications completed to align the Flutter mobile app with the parent boutique website (**[https://daksh-store.foduu.store/home](https://daksh-store.foduu.store/home)** — _Pixio / Kharido Boutique Design System_), resolving all anomalies reported across the live screenshots, the CMS payload in `log.txt`, and the public theme settings in `log2.txt`.

---

## 2. Parent Website & Backend Architecture Alignment (`log.txt` & `log2.txt`)

The home API (`https://daksh-store.foduu.store/api/mobile-app/home`) delivers **17 structured CMS sections**. All sections are mapped directly to luxury native mobile widgets:

| Index | Section Type | CMS Layout & View | Content & Mobile Presentation |
| :---: | :--- | :--- | :--- |
| **[00]** | `products` | `layout=parent_web`, `view=list` | Hero Product Carousel ("Vintage Denim Overalls", "Premium Cushion Cover"), bold title, category kicker, price with strikethrough, dual solid & outlined CTAs. |
| **[01]** | `categories` | `layout=circular`, `view=list` | Featured Categories horizontal story row with 15 categories, curated boutique photography avatars (`assets/images/`), clean leaf names (sanitized from `>`), and champagne gold rings. |
| **[02]** | `trust_badges` | Wardrobe Collection Cards | Editorial boutique collection cards ("Women Collection", "Child Fashion") with full-bleed lifestyle photography and floating pill badge buttons. |
| **[03]** | `rich_text` | Department Ribbon Chips | Editorial luxury ticker pill (`Jeans ✦ Shirts ✦ Shorts ✦ T-Shirt`) with letter-spaced typography and gold stars. |
| **[04]** | `products` | `layout=standard`, `view=list` | "Most popular products" horizontal card carousel with high-contrast black prices, gold stars, single floating wishlist heart, and quick-add bag icon. |
| **[05]** | `slider` | Lifestyle Banner | "Summer 2024" banner with crisp white typography, lightened gradient scrim, drop shadow, and animated expanding pill indicators. |
| **[06]** | `slider` | Lifestyle Banner | "New Summer Collection" with white typography and active "Shop Now" pill button. |
| **[07]** | `banner` | Single Promo Banner | Category promo banner ("Lumber Pillow"). |
| **[08]** | `products` | `layout=horizontal`, `view=list` | "Users Who Viewed This Also Checked Out These Similar Profiles" with responsive 260px cards, 105px image, and high-contrast solid black "View Product" button. |
| **[09]** | `slider` | Promo Banner | "Great saving on everyday essentials" with "Up to 42% off on top picks" and "See All" pill CTA. |
| **[10]** | `products` | `layout=parent_web`, `view=list` | Discounted products rendered as boutique portrait cards (`ParentWebProductCard`s) rather than an invasive full-screen banner. |
| **[11]** | `text_block` | Deals Spotlight Ribbon | Deals callout parsed into high-fashion deal spotlight chips rather than unstyled text dump. |
| **[12]** | `products` | `layout=overlay`, `view=list` | "Discovering the Hottest Nearby Destinations" overlay cards with high-contrast buttons and no invasive floating quantity steppers. |
| **[13]** | `products` | `layout=horizontal`, `view=list` | "Featured now" horizontal product list with clean store labels and black CTA buttons. |
| **[14]** | `slider` | Promo Slider | Lifestyle promotion banner. |
| **[15]** | `products` | `layout=standard`, `view=list` | Standard product carousel. |
| **[16]** | `trust_badges` | Partner Logos | Sponsored partner badges. |

---

## 3. Key Issues Resolved Across the Latest Review

### 1. Faint / Invisible Yellow "View Product" Button
- **Root Cause:** In `_buildHorizontalItem`, the icon and text used `colorScheme.primary` (`#feeb9d` pale buttery yellow), making it invisible on white cards.
- **Fix:** Switched to a solid onyx black pill (`#111111`) with white shopping bag icon and white bold "View Product" text.

### 2. Invasive `- 1 +` Quantity Stepper Floating Over Photo
- **Root Cause:** `_buildCartControl` replaced the button with a 3-part stepper widget (`[-] [qty] [+]`) overlaid right on the center of the product image whenever an item was in the cart.
- **Fix:** Replaced with a high-contrast onyx circle (`#111111`) displaying a champagne gold checkmark (`#D4AF37`) when in cart.

### 3. Card 2 Chopped Off / 300px Wide Horizontal Cards
- **Root Cause:** `_buildHorizontalStyleList()` used fixed 300px width for horizontal cards with a 120px photo box. On mobile screens, only the first card fit, and the 2nd card showed only a 120px blank square on the edge.
- **Fix:** Tuned card width to 260px and image width to 105px, revealing title, price, and CTA for the adjacent card to make the carousel swipable.

### 4. Giant Full-Bleed Product Card Blocking Scrolling
- **Root Cause:** Section 10 (`discounted_products`) has `layout: "parent_web"`. The router sent it to `_buildParentWebHorizontalList()` which built a massive 500px tall full-bleed `PageView` hero banner.
- **Fix:** Added check in `_buildParentWebHorizontalList()`: if not the top hero section, render a horizontal row of standard `ParentWebProductCard`s (`width: 155, height: 265`).

### 5. Ugly "Foduu Cart" Watermark & Placeholder
- **Root Cause:** `AppImagePlaceholder` rendered `'assets/images/app_logo.png'` with low opacity.
- **Fix:** Replaced with a minimalist luxury fashion hanger silhouette (`Icons.checkroom_outlined`) on an off-white tile.

### 6. Breadcrumb Truncation in Categories
- **Root Cause:** Raw titles like `Home Decor> Cushion Cover` were rendered with delimiters.
- **Fix:** Implemented `cleanCategoryTitle` to strip hierarchy delimiters (`>` and `/`) and map missing images to high-res boutique assets in `assets/images/`.

---

## 4. Modified Files Inventory

| File Path | Changes |
| :--- | :--- |
| `lib/constants/dynamic_theme.dart` | Added luminance-based WCAG AA contrast guard; enforced dark text on pale primaries (`#feeb9d`); upgraded default light theme to Noir & Gold. |
| `lib/constants/product_helper.dart` | Removed trailing `.0` decimals from prices; resolved duplicate price ranges (`₹1899` instead of `₹1899 - ₹1899`). |
| `lib/components/app_image_placeholder.dart` | Replaced "Foduu Cart" watermark with a minimalist boutique hanger icon (`Icons.checkroom_outlined`). |
| `lib/components/home_component/home_products.dart` | Removed desktop 3-button hover stack; fixed Section 10 to render boutique cards instead of full-screen banner; upgraded "View Product" to solid onyx pill; fixed `_buildCartControl` to remove photo stepper. |
| `lib/components/parent_web_product_card.dart` | Upgraded Quick-Add button to onyx circle (`#111111`) with white bag icon; ensured 5 gold stars and centered high-contrast typography. |
| `lib/components/home_component/home_category.dart` | Added breadcrumb cleaner; mapped missing category images to local boutique photography or champagne gold monogram rings. |
| `lib/components/home_component/home_slider.dart` | Lightened banner gradient scrim to keep lifestyle photography vibrant; added expanding white pill pagination indicators. |
| `lib/components/home_component/home_common_widgets.dart` | Guarded `StudioSectionHeader` so long titles never push `"See all >"` off-screen. |
| `lib/components/home_component/home_rich_text_component.dart` | Transformed raw text into an editorial luxury ticker ribbon with champagne gold stars (`✦`). |
| `lib/app/modules/homepage/views/material/responsive_bottom_nav.dart` | Uses a simple icon-and-label bottom bar aligned with the parent website; selected items no longer use an active capsule. |

---

## 5. Mobile Screenshot Follow-up (November 4, 2026)

The mobile screenshot review found that the perceived gaps were caused by several spacing sources adding together: the category carousel's fixed height, per-widget margins, and CMS-authored `spacer` sections. Earlier reductions to individual widget margins did not fully address that combined rhythm.

### Home Feed Spacing and Hierarchy

- `lib/core/foduuStudio/foduu_studio_layout_mixin.dart` caps CMS spacer sections on the `home` layout at 12 px. Other CMS pages retain their configured spacer sizes.
- `lib/core/foduuStudio/register_default_widgets.dart` opts the home category section into compact spacing. The compact circular category row is 104 px high with an 8 px section ending gap; category instances outside this home layout keep the existing dimensions.
- `lib/components/home_component/home_trust_badges.dart` reduces the wardrobe collection cards to 184 px high and tightens the heading, top, and bottom spacing.
- `lib/components/home_component/home_rich_text_component.dart` reduces the department ribbon's vertical margins so it reads as a transition into the product carousel.
- `lib/components/home_component/home_slider.dart` uses a home-only compact spacing marker to bring consecutive campaign banners closer. Other slider layouts keep their previous vertical spacing.
- `lib/components/home_component/home_products.dart` aligns horizontal and overlay product rows to consistent 16 px side gutters. Overlay product cards use a solid caption panel beneath the photo, with the cart control clear of the product details.

### Parent-Aligned Bottom Navigation

The app tab order now matches the parent website: **Home, Shop, Wishlist, Cart, Login/Account**. Guest users see “Login”; authenticated users see “Account”. The selected item uses a simple icon-and-label treatment rather than the previous capsule.

The `PageView` order, header shortcuts, shop navigation constant, wishlist shortcut, cart shortcut, drawer profile shortcut, and studio route mapping were updated to use the new indices. Existing destinations and cart/wishlist badges are preserved.

### Verification

- Android profile APK build completed successfully with `flutter build apk --profile`.
- `git diff --check` passed.
- No automated tests were run for this follow-up.

---

## 6. Image 1 & Image 2 Parts Alignment with Parent Web (November 5, 2026)

Following in-depth inspection of the parent website (`https://daksh-store.foduu.store/home` — Pixio Design System) and user review of the live screenshots:

### 1. Image 1 Part: Banners (Sections 05 & 06)
- **Parent Web Alignment**: On the parent site (`adv-area`), "Summer 2024" and "New Summer Collection" form a side-by-side 2-column campaign block (`col-lg-6` + `col-lg-6`) with differentiated CTA treatments: Section 05 uses an **outline CTA button** (`btn-outline-secondary`), while Section 06 uses a **solid CTA button** (`btn-secondary`).
- **Implementation**:
  - `lib/components/home_component/home_slider.dart`: Updated `_compact_home_spacing` vertical padding from `2px` to `7px` (yielding `14px` total clean editorial separation between consecutive banners instead of the jammed 4px hairline).
  - Dynamically renders an outline pill CTA for Section 05 (`Summer 2024` / `home-top-left-slider`) and a solid pill CTA for Section 06 (`New Summer Collection`), directly mirroring the parent boutique design.

### 2. Image 2 Part: Horizontal Products & Action Button (Section 08)
- **Parent Web Alignment**: Section 07 (`pic3.jpg`) serves as the editorial feature companion for Section 08 ("Users Who Viewed This Also Checked Out These Similar Profiles").
- **Implementation**:
  - `lib/components/home_component/home_products.dart`:
    - Adjusted horizontal card width from `280px` to `235px` with `12px` separator. On standard mobile viewports, Card 2 clearly peeks in showing thumbnail, title, and price, inviting smooth horizontal browsing.
    - Added `_buildHorizontalActionControl`: Guarantees a persistent high-contrast onyx action button (bag icon for in-stock simple products, arrow icon to navigate to product details for variable items or options), eliminating the awkward empty void under the wishlist heart.

### 3. Image 2 Part: Portrait Cards & Bottom Navigation Clearance (Section 10)
- **Issue**: Prices in Section 10 cards (`ParentWebProductCard`) were sliced across the middle by the bottom navigation bar due to lack of scroll bottom inset.
- **Implementation**:
  - `lib/core/foduuStudio/foduu_studio_layout_view.dart`: Added `padding: const EdgeInsets.only(bottom: 36.0)` to the scroll view, ensuring complete visibility and comfortable scrolling past the bottom navigation bar.
  - `lib/components/home_component/home_products.dart`: Tuned `cardHeight` from `265px` to `275px` and `cardWidth` to `158px` in `_buildParentWebHorizontalList` to give comfortable vertical breathing room for 2-line titles, 5 gold stars, and formatted prices.

---

## 7. Industry Standards & Feed Cohesion Alignment (November 10, 2026)

Following user audit of `home_view.dart` where individual sections felt disconnected rather than part of a unified, high-fashion editorial feed:

### 1. Section Header & Hierarchy Normalization
- **Issue**: Standard product sections whose CMS heading was `"_"` or blank were completely missing a header, causing large product cards to float disconnected below lifestyle banners. Headers also had inconsistent typography sizes (14px vs 22px).
- **Implementation**:
  - `lib/components/home_component/home_products.dart`: Added intelligent fallback resolution when heading is `"_"` or blank (e.g. `Special Offers`, `Most Popular Products`, `Featured Collection`, `Trending Products`), ensuring the section is anchored with a proper title.
  - `lib/components/home_component/home_common_widgets.dart`: Standardized `StudioSectionHeader` across all sections to `fontSize: 18, fontWeight: FontWeight.w700` and uppercase-styled `See All` link at `fontSize: 13`.
  - `lib/components/home_component/home_trust_badges.dart`: Replaced ad-hoc `Row` in `_LogoStrip` with the standardized `StudioSectionHeader`.

### 2. Standardized Card Scale & 30% Peek Affordance
- **Implementation**:
  - `lib/components/home_component/home_products.dart`: Set standard portrait card width to `152.0dp` with a 3:4 aspect ratio (`0.76`). On typical mobile screens (390-393dp), this perfectly reveals Card 1, Card 2, and a ~30% sliver of Card 3, providing immediate affordance for horizontal swiping.
  - Elevated card corner radius to `14dp` with a subtle neutral foundation (`#F7F7F8` in light mode, `#1E1E22` in dark mode) so product photography blends cleanly.

### 3. Hero Lifestyle Banner Proportions & Typography
- **Issue**: Short letterbox banners caused title kickers ("Shortlist") to be clipped under the search bar.
- **Implementation**:
  - `lib/components/home_component/home_slider.dart`: Updated default banner height calculation on mobile to `(Get.width * 0.58).clamp(225.0, 260.0)`, refined gradient scrim stops (`[0.35, 0.65, 1.0]`), and gave title/content balanced vertical padding so text and CTA pills have comfortable breathing room.

### 4. Sponsor & Partner Logo Refinement
- **Implementation**:
  - `lib/components/home_component/home_trust_badges.dart`: Refined `_logoCard` to sleek obsidian tiles (`#18181B`) with delicate `0.8px` borders and compact `56dp` height, harmonizing seamlessly with the editorial feed.

