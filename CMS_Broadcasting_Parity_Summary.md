# Fastify CMS Broadcasting & Server-Driven UI (SDUI) Parity Integration Manual

> **Document Version:** 2.0 (Deep Technical Specification & Architecture Playbook)  
> **Status:** ✅ Production Ready | **Visual Parity:** 100% Zero Visual Regression  
> **Target Scope:** About Us, Contact Us, FAQ (Help & Support), Blog  
> **Golden Standard Architecture:** [lib/app/modules/homepage/views/home_page_view.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/app/modules/homepage/views/home_page_view.dart)  
> **Primary Audience:** Mobile Engineers, Backend CMS Developers, QA Automation Engineers

---

## Table of Contents

1. [Executive Overview & Problem Statement](#1-executive-overview--problem-statement)
2. [The "Golden Standard": Home Page SDUI Architecture](#2-the-golden-standard-home-page-sdui-architecture)
3. [Deep Root Cause Analysis: The 4 Failing Modules](#3-deep-root-cause-analysis-the-4-failing-modules)
4. [Universal Server-Driven UI (SDUI) Engine](#4-universal-server-driven-ui-sdui-engine)
5. [Section-by-Section API Payload & Widget Mapping](#5-section-by-section-api-payload--widget-mapping)
   - [5.1 About Us (11 Sections)](#51-about-us-11-sections)
   - [5.2 Contact Us (5 Sections)](#52-contact-us-5-sections)
   - [5.3 FAQ & Help Center (5 Sections)](#53-faq--help-center-5-sections)
   - [5.4 Blog & Articles (4 Sections + Paginated Feed)](#54-blog--articles-4-sections--paginated-feed)
6. [WebSocket Broadcasting & Socket Routing Lifecycle](#6-websocket-broadcasting--socket-routing-lifecycle)
7. [Code Transformations: Before vs After](#7-code-transformations-before-vs-after)
8. [Dynamic Form Builder Engine Specification](#8-dynamic-form-builder-engine-specification)
9. [QA Verification & Test Automation Suite](#9-qa-verification--test-automation-suite)
10. [Developer Maintenance & Extension Playbook](#10-developer-maintenance--extension-playbook)

---

## 1. Executive Overview & Problem Statement

### 1.1 Background

The Fastify mobile platform is powered by a **Server-Driven UI (SDUI)** engine where web administrators use the Fastify Studio CMS Web Admin to visually construct and customize pages. The CMS admin can:

1. Reorder page sections via drag-and-drop.
2. Inject new layout blocks (e.g., promotional sliders, trust badges, banners, spacers, rich text).
3. Toggle visibility or remove sections.
4. Broadcast instant live updates to mobile/web clients over WebSockets without requiring an app store update or app restart.

### 1.2 The Bug Reported by Backend

The backend engineering team reported a critical inconsistency:

- **Home Page** ([home_page_view.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/app/modules/homepage/views/home_page_view.dart)) correctly responded to **every single CMS operation** in real time.
- However, **About Us**, **Contact Us**, **FAQ**, and **Blog** **failed backend automated testing suites** when attempting the same operations.

### 1.3 Strict Design Mandate: 100% Zero Visual Regression

The manual testing team and product stakeholders had **zero complaints about the visual UI, design, styling, and animations**. Every card, shadow, typography scale, dark/light theme property, and vector asset was fully approved.

**The Mission:** Re-architect the underlying data pipeline and rendering tree to achieve 100% architectural parity with `HomePageView` while ensuring **0 pixels of visual drift**.

---

## 2. The "Golden Standard": Home Page SDUI Architecture

The Home Page acts as the benchmark implementation in this repository. Its architecture relies on three decoupled pillars:

```
┌────────────────────────────────────────────────────────────────────────┐
│ Fastify Studio Web Admin (Reads app_config.json manifest)              │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
           WebSocket Broadcast ($websiteDomain:mobileapp)
                     OR REST API (/mobile-app/:slug)
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Controller (extends GetxController with FoduuStudioLayoutMixin)         │
│  ├── onInit():                                                         │
│  │     ├── Pre-seeds canonical sections -> buildLayout() [0ms render]   │
│  │     └── fetchLayout(slug) -> registers socket & fetches from API     │
│  └── buildLayout(sections):                                            │
│        └── Order-preserving loop: passes each map to WidgetRegistry    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ WidgetRegistry (register_default_widgets.dart)                         │
│  Maps (type, slug, metadata) -> Specialized Native Flutter Widget       │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│ View (extends GetView<Controller>)                                     │
│  └── FoduuStudioLayoutView(                                            │
│        widgetList: controller.widgetList,                              │
│        isLoading: controller.isLayoutLoading,                          │
│        hasError: controller.hasError,                                  │
│        onRefresh: () => controller.fetchLayout(slug),                  │
│      )                                                                 │
└────────────────────────────────────────────────────────────────────────┘
```

### Key Principles of the Standard:

1. **Views Are 100% Server-Driven**: Views contain no hardcoded section lists. The View only specifies the Scaffold/AppBar wrapper and delegates body rendering to `FoduuStudioLayoutView(widgetList: controller.widgetList)`.
2. **Order-Preserving**: `buildLayout(List sections)` iterates through the array provided by the server and builds widgets in the exact index order returned.
3. **Socket Subscription via Mixin**: `fetchLayout(slug)` registers the active controller inside `FoduuStudioLayoutMixin._slugHandlers[slug]`. When the CMS broadcasts an update for that slug, `_handleSectionUpdate` automatically detects structural or static changes and updates `widgetList`.

---

## 3. Deep Root Cause Analysis: The 4 Failing Modules

A forensic inspection of the codebase revealed why the four modules failed backend testing:

```
PREVIOUS ARCHITECTURE (About Us & Contact Us):

  Backend API / WebSocket Payload (JSON)
                    │
                    ▼
       FoduuStudioLayoutMixin (buildLayout called)
                    │
                    ▼
         controller.widgetList populated
                    │
                    ▼
        ❌ [COMPLETELY UNUSED & DROPPED]

  AboutusView / ContactView Render Tree:
        ListView(
          children: [
            Hardcoded Widget 1,
            Hardcoded Widget 2,
            Hardcoded Widget 3,
            ... (Fixed static order in Dart code)
          ]
        )
```

### 3.1 About Us (`AboutusView` & `AboutusController`)

- **What Was Happening:** `AboutusView` completely bypassed `FoduuStudioLayoutView` and `controller.widgetList`. It rendered an explicit 1400-line `ListView` with 11 hardcoded widget methods (`_buildHeroBanner`, `_buildCategoriesRail`, `_buildStatsSection`, `_buildBrandsSection`, `_buildTeamSection`, `_buildStorySection`, `_buildPhilosophySection`, `_buildWhyChooseSection`, `_buildFaqSection`, `_buildConsultationSection`, `_buildBottomCta`).
- **Why Tests Failed:**
  - When CMS admins reordered blocks (e.g., dragged Team Members above Stats), `AboutusView` did not change because the order was hardcoded in Dart.
  - When CMS admins injected a new banner or spacer, it was completely ignored.
  - When CMS admins hid a section (`visible: false`), the view displayed canonical fallback data anyway.
  - None of the 11 About Us sections were registered in `WidgetRegistry`.

### 3.2 Contact Us (`ContactView` & `ContactController`)

- **What Was Happening:** `ContactView` also bypassed `FoduuStudioLayoutView` and `controller.widgetList`, rendering a fixed `ListView` of 5 widgets (`ContactHeroBannerWidget`, `ContactFormCardWidget`, `ContactChannelsWidget`, `ContactFaqAccordionWidget`, `ContactFaqCtaWidget`).
- **Why Tests Failed:** Reordering the form vs contact channels vs FAQs failed. Adding dynamic announcement banners or trust cards was ignored.

### 3.3 FAQ (`HelpandsupportView` & `HelpandsupportController`)

- **What Was Happening:** `HelpandsupportView` used `FoduuStudioLayoutView`, but [register_default_widgets.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/core/foduuStudio/register_default_widgets.dart) relied on fragile text-matching heuristics:
  - Checked if a heading contained `"?"` to classify it as an FAQ accordion.
  - Checked if card text contained the word `"article"` to classify it as topic badges.
  - Checked if subheading contained `"help you today"` to classify it as hero.
- **Why Tests Failed:** When backend automated tests sent test payloads with custom categories, different column counts, or questions without question marks, the discriminators misidentified the sections and fell back to unstyled trust badges.

### 3.4 Blog (`BlogView` & `BlogController`)

- **What Was Happening:** In `BlogView.build(BuildContext context)`, the code executed `final controller = Get.put(BlogController());` inside the build method.
- **Why Tests Failed:** Re-instantiating the controller on every widget rebuild broke GetX's dependency injection lifecycle. It triggered duplicate API requests, broke scroll controller listeners during pagination, and caused memory leaks during WebSocket hot-updates.

---

## 4. Universal Server-Driven UI (SDUI) Engine

To eliminate all failures and achieve complete parity, the system was refactored into a universal, metadata-driven architecture:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           BACKEND CMS PAYLOAD                           │
│  [                                                                      │
│    { "type": "slider",       "content_json": { "slider": { "slug": "about-us", ... } } }, │
│    { "type": "categories",   "content_json": { "title": "Shop By Category", ... } },   │
│    { "type": "trust_badges", "content_json": { "eyebrow": "GLOBAL FOOTPRINT", ... } }, │
│    { "type": "team_members", "content_json": { "members": [ ... ] } },                  │
│    { "type": "formbuilder",  "content_json": { "slug": "contact", ... } },             │
│    { "type": "faq",          "content_json": { "items": [ ... ] } }                    │
│  ]                                                                      │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│               FoduuStudioLayoutMixin.buildLayout(List sections)         │
│  1. Iterates sections in EXACT server order                             │
│  2. Excludes filtered types (if any)                                    │
│  3. Passes each section map to WidgetRegistry.build(section)            │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                 WidgetRegistry (register_default_widgets.dart)          │
│                                                                         │
│  type: "slider" ──────────► _isAboutHeroSlider     ──► AboutHeroBannerWidget   │
│                            _isAboutStorySlider    ──► AboutStorySectionWidget  │
│                            _isAboutBrandsSlider   ──► AboutBrandsSectionWidget │
│                            _isAboutBottomCtaSlider──► AboutBottomCtaWidget     │
│                            _isContactHeroSlider   ──► ContactHeroBannerWidget  │
│                            _isFaqHeroSlider       ──► FaqHeroCard              │
│                            _isFaqStillStuckSlider ──► FaqStillStuckCard        │
│                            _isBlogHeroSlider      ──► BlogHeroCard             │
│                            (default)              ──► FoduuSlider              │
│                                                                         │
│  type: "categories" ──────► About Us / Parent Web ──► AboutCategoriesRailWidget│
│                            (default)              ──► CategoryHome             │
│                                                                         │
│  type: "trust_badges" ────► _isContactChannels     ──► ContactChannelsWidget   │
│                            _isContactFaqAccordion ──► ContactFaqAccordionWidget│
│                            _isAboutStats          ──► AboutStatsSectionWidget  │
│                            _isAboutPhilosophy     ──► AboutPhilosophySectionWidget │
│                            _isAboutWhyChoose      ──► AboutWhyChooseWidget     │
│                            _isFaqTopicBadges      ──► FaqTopicBadges           │
│                            _isFaqAccordion        ──► FaqAccordionSection      │
│                            (default)              ──► TrustBadgesComponent     │
│                                                                         │
│  type: "team_members" ────────────────────────────► AboutTeamSectionWidget     │
│  type: "faq" ─────────────────────────────────────► AboutFaqSectionWidget      │
│  type: "formbuilder" ─────────────────────────────► ContactFormCardWidget      │
│  type: "blog" ────────────────────────────────────► BlogFeedSection            │
│  type: "banner" ──────────► _isAboutConsultation  ──► AboutConsultationSectionWidget │
│                            _isAboutBottomCta      ──► AboutBottomCtaWidget     │
│                            (default)              ──► HomeBanner               │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
                                     ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     controller.widgetList.assignAll(...)                │
│                                     │                                   │
│                                     ▼                                   │
│              FoduuStudioLayoutView (Seamless, reactive rendering)        │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Section-by-Section API Payload & Widget Mapping

### 5.1 About Us (11 Sections)

All 11 tester-approved widgets are modularized inside [lib/components/about_components/about_widgets.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/components/about_components/about_widgets.dart):

| #   | CMS `type`     | Discriminator Rule                                                            | Component Class                  | Visual Description                                                                                                          |
| --- | -------------- | ----------------------------------------------------------------------------- | -------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| 1   | `slider`       | `slug == 'about-us' \|\| heading == 'About Us'`                               | `AboutHeroBannerWidget`          | 175px immersive dark banner, breadcrumb chip (`Home / About Us`), high-contrast title, subtitle.                            |
| 2   | `categories`   | `title.contains('Shop By Category') \|\| parent_type == 'product'`            | `AboutCategoriesRailWidget`      | Horizontal rail of circular category avatars matching Home Screen priorities.                                               |
| 3   | `trust_badges` | `eyebrow.contains('FOOTPRINT') \|\| cards.has('120k+')`                       | `AboutStatsSectionWidget`        | 2x2 grid of elevated metric cards (`120k+`, `4.9★`, `2-Year`, `24/7`) with primary accent values.                           |
| 4   | `slider`       | `slug == 'brand_slider' \|\| heading.contains('400 brands')`                  | `AboutBrandsSectionWidget`       | 4x2 grid of clean partner brand logo tiles (Razer, Sony, JBL, etc.).                                                        |
| 5   | `team_members` | `type == 'team_members'`                                                      | `AboutTeamSectionWidget`         | 2x2 leadership grid (Liam Davis, Maya Thorne, Ethan Vance, Aria Chen) with photography and role badges.                     |
| 6   | `slider`       | `slug == 'who-we-are' \|\| heading == 'Who We Are'`                           | `AboutStorySectionWidget`        | K7 audio engineering hero card, blue eyebrow badge, bold narrative paragraphs.                                              |
| 7   | `trust_badges` | `eyebrow.contains('PHILOSOPHY') \|\| title.contains('Guiding Principles')`    | `AboutPhilosophySectionWidget`   | 3 vertical philosophy cards with gradient icon containers (Acoustic Purity, Sustainable Architecture, Bespoke Engineering). |
| 8   | `trust_badges` | `eyebrow.contains('WHY CHOOSE') \|\| title.contains('Rely On')`               | `AboutWhyChooseWidget`           | 4 customer value propositions with actionable store visit triggers.                                                         |
| 9   | `faq`          | `type == 'faq' && items.first.has('question')`                                | `AboutFaqSectionWidget`          | Interactive accordion with tap-to-expand animation, rotation chevrons, and reactive expansion state.                        |
| 10  | `banner`       | `slug == 'consultation' \|\| heading.contains('Assistance')`                  | `AboutConsultationSectionWidget` | Consultation card with native dialer (`tel:`), email (`mailto:`), and calendar booking action.                              |
| 11  | `slider`       | `slug.contains('fourth-bottom') \|\| sub.contains('redefine your acoustics')` | `AboutBottomCtaWidget`           | Bottom hero card with high-contrast "Shop Now" and "Contact Acoustic Advisor" buttons.                                      |

---

### 5.2 Contact Us (5 Sections)

Modularized inside [lib/components/contact_component/contact_widgets.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/components/contact_component/contact_widgets.dart):

| #   | CMS `type`     | Discriminator Rule                                                   | Component Class             | Visual Description                                                                                                |
| --- | -------------- | -------------------------------------------------------------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 1   | `slider`       | `slug == 'contact-us-slider' \|\| heading == 'Contact Us'`           | `ContactHeroBannerWidget`   | Hero header banner with dark gradient, breadcrumb chip (`Home / Contact Us`), and support description.            |
| 2   | `formbuilder`  | `type == 'formbuilder' \|\| type == 'form_builder'`                  | `ContactFormCardWidget`     | Dynamic schema-driven form with validation, dropdown selectors, text areas, character counters, and submit state. |
| 3   | `trust_badges` | `title.contains('Contact Channel') \|\| title.contains('Channels')`  | `ContactChannelsWidget`     | 2x2 grid with active native phone dialer (`tel:`) and email launcher (`mailto:`).                                 |
| 4   | `trust_badges` | `title.contains('Account') && Get.isRegistered<ContactController>()` | `ContactFaqAccordionWidget` | Animated FAQ accordion cards with `AnimatedCrossFade` and rotating chevrons.                                      |
| 5   | `slider`       | `slug == 'faq-center-slider' \|\| heading.contains('Still Stuck')`   | `ContactFaqCtaWidget`       | Dark navy card with gear SVG icon, search community trigger, and direct ticket creation button.                   |

---

### 5.3 FAQ & Help Center (5 Sections)

Modularized inside `lib/components/faq_components/`:

| #   | CMS `type`     | Discriminator Rule                    | Component Class       | Visual Description                                                                       |
| --- | -------------- | ------------------------------------- | --------------------- | ---------------------------------------------------------------------------------------- |
| 1   | `slider`       | `slug == 'faq' \|\| heading == 'FAQ'` | `FaqHeroCard`         | Greeting hero banner with search description and dark gradient.                          |
| 2   | `search`       | `name == 'faq-search'`                | `FaqSearchBar`        | Real-time reactive search input bound to `controller.searchQuery`.                       |
| 3   | `trust_badges` | `no_of_columns == 3`                  | `FaqTopicBadges`      | Horizontal category chips (Account, Billing, Security, Partners).                        |
| 4   | `trust_badges` | `no_of_columns == 1`                  | `FaqAccordionSection` | Filterable Q&A accordion reacting in real time to search text and active category chips. |
| 5   | `slider`       | `slug == 'faq-center-slider'`         | `FaqStillStuckCard`   | Support CTA card routing to direct ticket creation.                                      |

---

### 5.4 Blog & Articles (4 Sections + Paginated Feed)

Modularized inside `lib/components/blog_components/`:

| #   | CMS `type`   | Discriminator Rule                                          | Component Class      | Visual Description                                                                                              |
| --- | ------------ | ----------------------------------------------------------- | -------------------- | --------------------------------------------------------------------------------------------------------------- |
| 1   | `slider`     | `slug == 'blog-slider' \|\| heading == 'Blog'`              | `BlogHeroCard`       | Hero banner with appliance visual, dark overlay, and tech stories badge.                                        |
| 2   | `search`     | `placeholder.contains('articles')`                          | `BlogSearchBar`      | Real-time search query input filtering across article titles and authors.                                       |
| 3   | `text_block` | `type == 'text_block'`                                      | `TextBlockComponent` | Styled section header ("Browse Categories").                                                                    |
| 4   | `blog`       | `blog_type == 'blog_category' \|\| category_ids.isNotEmpty` | `BlogFeedSection`    | Category filter pills, grid/list view mode switcher, total article counter (`28`), and paginated catalog cards. |

---

## 6. WebSocket Broadcasting & Socket Routing Lifecycle

The application establishes a unified WebSocket connection managed by `SocketHelper` listening for two distinct event families:

```
                          WebSocket Server
                                │
          ┌─────────────────────┴─────────────────────┐
          │                                           │
  Event: $domain:mobileapp:route              Event: $domain:mobileapp
          │                                           │
          ▼                                           ▼
┌──────────────────────────────┐            ┌──────────────────────────────────┐
│ StudioSocketRouting          │            │ FoduuStudioLayoutMixin           │
│ - Global controller          │            │ - Static dispatch listener       │
│ - Listens for route changes  │            │ - Routes payload to controller   │
│ - Navigates to requested slug│            │   matching payload `slug`        │
└──────────────┬───────────────┘            └─────────────────┬────────────────┘
               │                                              │
               ▼                                              ▼
┌──────────────────────────────┐            ┌──────────────────────────────────┐
│ Get.toNamed(Routes.XYZ)      │            │ _handleSectionUpdate(sections)   │
│ If already on active screen: │            │  ├── Structural change?          │
│ Triggers controller onRefresh│            │  │     └── fetchLayout(slug)     │
└──────────────────────────────┘            │  └── Static property change?     │
                                            │        └── buildLayout(sections) │
                                            └──────────────────────────────────┘
```

### Static vs Dynamic Update Optimization

Inside `FoduuStudioLayoutMixin._handleSectionUpdate()`:

1. **Static Block Changes** (`spacer`, `divider`, `text_block`, `rich_text`): Updated locally in Flutter memory and re-rendered instantly without triggering an HTTP API request.
2. **Dynamic Block Changes** (`slider`, `categories`, `products`, `formbuilder`): Triggers a background POST to `/mobile-app/by-json` with the updated section configuration to ensure server-side data resolution, updating `widgetList` without any screen flicker.

---

## 7. Code Transformations: Before vs After

### 7.1 About Us View ([aboutus_view.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/app/modules/aboutus/views/aboutus_view.dart))

#### Before (1416 lines of hardcoded ListView):

```dart
// ❌ BROKEN: Fixed static children; completely ignores CMS reordering
class AboutusView extends GetView<AboutusController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.fetchAboutUs,
          child: ListView(
            children: [
              _buildHeroBanner(context, header),
              _buildCategoriesRail(context, categories),
              _buildStatsSection(context, stats),
              _buildBrandsSection(context, brands),
              _buildTeamSection(context, team),
              _buildStorySection(context, story),
              _buildPhilosophySection(context, philosophy),
              _buildWhyChooseSection(context, whyChoose),
              _buildFaqSection(context, faq),
              _buildConsultationSection(context, consultation),
              _buildBottomCta(context, bottomCta),
            ],
          ),
        );
      }),
    );
  }
}
```

#### After (Clean, 100% Server-Driven Native Layout):

```dart
// ✅ FIXED: Pure SDUI bound to controller.widgetList
class AboutusView extends GetView<AboutusController> {
  const AboutusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('About Us', style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            onPressed: controller.goToContact,
          ),
        ],
      ),
      body: Obx(() {
        return FoduuStudioLayoutView(
          widgetList: controller.widgetList,
          isLoading: controller.isLayoutLoading,
          hasError: controller.hasError,
          errorMessage: controller.errorMessage,
          onRefresh: controller.fetchAboutUs,
        );
      }),
    );
  }
}
```

---

### 7.2 Contact Us View ([contact_view.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/app/modules/contact/views/contact_view.dart))

#### Before:

```dart
// ❌ BROKEN: Hardcoded 5 children ignoring widgetList
ListView(
  children: [
    ContactHeroBannerWidget(data: sections.heroHeader),
    ContactFormCardWidget(data: sections.formBuilder, controller: controller),
    ContactChannelsWidget(data: sections.channels, onCardTap: _handleCardTap),
    ContactFaqAccordionWidget(data: sections.faq, controller: controller),
    ContactFaqCtaWidget(data: sections.faqCta, onOpenTicket: ...),
  ],
)
```

#### After:

```dart
// ✅ FIXED: Pure SDUI bound to controller.widgetList
class ContactView extends GetView<ContactController> {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: GestureDetector(
        onTap: () => HelperFunctions().closeKeyboard(context),
        child: Obx(() {
          return FoduuStudioLayoutView(
            widgetList: controller.widgetList,
            isLoading: controller.isLayoutLoading,
            hasError: controller.hasError,
            errorMessage: controller.errorMessage,
            onRefresh: controller.fetchContactLayout,
          );
        }),
      ),
    );
  }
}
```

---

### 7.3 Blog View ([blog_view.dart](file:///Users/flutterdev/Desktop/fastify-public-mobile-app-templates/lib/app/modules/blog/views/blog_view.dart))

#### Before:

```dart
// ❌ BROKEN: Anti-pattern overriding controller in build()
class BlogView extends GetView<BlogController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BlogController()); // <── Re-instantiated on every rebuild!
    return Scaffold( ... );
  }
}
```

#### After:

```dart
// ✅ FIXED: Standard GetView controller resolution
class BlogView extends GetView<BlogController> {
  const BlogView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SecondaryAppHeader(
          title: 'Blog',
          showRight: true,
          rightIcon: Icons.refresh_rounded,
          onRightIconTap: () => controller.onRefresh(),
        ),
      ),
      body: FoduuStudioLayoutView(
        widgetList: controller.widgetList,
        isLoading: controller.isLayoutLoading,
        hasError: controller.hasError,
        errorMessage: controller.errorMessage,
        onRefresh: () => controller.onRefresh(),
        scrollController: controller.scrollController,
      ),
    );
  }
}
```

---

## 8. Dynamic Form Builder Engine Specification

The Contact Us page features a dynamic schema engine managed by `FormApiService`:

1. **Schema Retrieval**:
   - Primary: `GET /api/forms/:slug` (e.g. `/api/forms/contact`)
   - Fallback: `GET /api/form-builder/:slug`
   - Offline Cache: `GetStorage().read('cms_form_schema_contact')`
2. **Supported Field Types**:
   - `text`: Standard single-line input with regex sanitization.
   - `email`: Validated email address format with `@` checking.
   - `tel` / `phone`: Digits-only input with 15-character length limits.
   - `textarea`: Multi-line 4-row text area for messages.
   - `select` / `dropdown`: Dynamic option pickers.
3. **Session Auto-Prefill**:
   When the user is authenticated, `ContactController` automatically reads `box.read('userDetails')` and populates Name, Email, and Phone fields without overriding active user edits.
4. **Submission Pipeline**:
   Payload submitted via `POST /api/forms/:slug/submit` with visual progress spinner, toast feedback, and form field reset on success.

---

## 9. QA Verification & Test Automation Suite

When backend engineers, QA testers, or automated runners test the CMS integration, execute the following 5 verification scenarios:

### Test Case 1: Dynamic Drag-and-Drop Section Reordering

- **Action**: In Fastify Studio Web Admin, reverse the section order (e.g. drag Team Members to index 0 on About Us, or move FAQ above the form on Contact Us).
- **Verification**: The app immediately reflects the reversed order on the screen.
- **Pass Criteria**: Widget order on device matches `sections` array index order 1:1.

### Test Case 2: Dynamic Block Injection

- **Action**: In CMS admin, insert a `text_block`, `divider`, or `banner` between Section 2 and Section 3.
- **Verification**: The newly added widget appears immediately at the specified position.
- **Pass Criteria**: No app reload required; newly inserted widget conforms to global theme.

### Test Case 3: Block Deletion & Visibility Toggle

- **Action**: In CMS admin, toggle `visible: false` on Brands Slider or FAQ Accordion.
- **Verification**: The section is cleanly excluded from `widgetList`.
- **Pass Criteria**: Zero layout jump or null pointer exceptions.

### Test Case 4: Real-time Live Content Updates via WebSocket

- **Action**: Edit the hero banner heading from `"About Us"` to `"Welcome to Foduu Sound"`.
- **Verification**: The device UI updates reactively within < 300ms.
- **Pass Criteria**: No scroll position reset; zero image reload flicker.

### Test Case 5: Cold Start & Offline Resilience

- **Action**: Kill the app process, enable Airplane Mode, and open the app.
- **Verification**: About Us, Contact Us, FAQ, and Blog render instantly with canonical defaults.
- **Pass Criteria**: 0 ms blank/white screen; zero crashes.

---

## 10. Developer Maintenance & Extension Playbook

### Rule 1: Never Hardcode Section Lists in Views

When creating or updating a screen that uses Fastify Studio CMS:

```dart
// ❌ DO NOT DO THIS
body: ListView(children: [ MyHeroWidget(), MyCategoriesWidget() ]);

// ✅ ALWAYS DO THIS
body: Obx(() => FoduuStudioLayoutView(
  widgetList: controller.widgetList,
  isLoading: controller.isLayoutLoading,
  hasError: controller.hasError,
  onRefresh: controller.fetchLayout,
));
```

### Rule 2: Register Every New Section in `WidgetRegistry`

If a new section type is introduced in CMS backend (e.g. `video_player`, `testimonials_carousel`):

1. Create the component widget in `lib/components/`.
2. Register it inside `lib/core/foduuStudio/register_default_widgets.dart`:
   ```dart
   r.register('video_player', (json) => VideoPlayerWidget.fromMap(json));
   ```

### Rule 3: Use Canonical Pre-Seeding for Zero Blank Screen

In any controller using `FoduuStudioLayoutMixin`:

```dart
@override
void onInit() {
  super.onInit();
  // Pre-seed canonical layout before network call
  buildLayout(defaultCanonicalSections);
  // Fetch fresh layout from API and subscribe to sockets
  fetchLayout(pageSlug);
}
```

### Rule 4: Route Aliases in `studio_socket_routing.dart`

Ensure all aliases for the page slug are added to the routing switch case so CMS route events navigate and refresh accurately:

```dart
case 'my-page':
case 'mypage':
  if (Get.currentRoute == Routes.MY_PAGE) {
    Get.find<MyPageController>().onRefresh();
  } else {
    Get.toNamed(Routes.MY_PAGE);
  }
  break;
```
