# Blog Module — Parent Website & CMS Broadcasting Parity Summary

> **Last Updated:** 2026-11-27  
> **Parent Website:** [https://foduu-electro.foduu.store/blog](https://foduu-electro.foduu.store/blog)  
> **CMS API Endpoint:** `GET https://foduu-electro.foduu.store/api/mobile-app/blog`  
> **Articles API Endpoint:** `GET https://foduu-electro.foduu.store/api/blogs?page=1`  
> **Architecture Standard:** Server-Driven UI (`FoduuStudioLayoutMixin`, `FoduuStudioLayoutView`, `WidgetRegistry`, `StudioSocketRouting`)

---

## 1. Executive Summary

The **Blog** module (`lib/app/modules/blog/` and `lib/components/blog_components/`) was updated to achieve structural, visual, and CMS-broadcasting parity with the live `GET /api/mobile-app/blog` payload (`log2.txt`) and the parent storefront (`foduu-electro.foduu.store/blog`), following the same SDUI pattern documented in `ABOUT_US_IMPLEMENTATION_SUMMARY.md` and `Contact Us Summary.md`.

---

## 2. Problems Identified & Resolved

| Area | Before | After |
| :--- | :--- | :--- |
| **`rich_text` Header (`"News & Insights"`)** | Fell through to generic `RichTextComponent`, rendering inside a plain gray rounded box at the top of the Blog screen | Matched by `_isBlogRichTextHeader()` in `register_default_widgets.dart` and rendered with the dedicated `BlogPageHeader` editorial eyebrow badge |
| **Blog Section `title` & `subtitle`** | `BlogFeedSection` ignored `content_json['title']` and `content_json['subtitle']`, hardcoding `"Latest Articles"` | `BlogFeedSectionData` parses `title` (`"Our Latest Blog Posts"`) and `subtitle` (`"Explore in-depth articles, buying guides, and technical breakdowns."`) and renders them above the feed |
| **`"others"` Category Tag Leak** | Raw lowercase `"others"` appeared in both the horizontal filter chips and blog card image badges | Added `normalizeBlogCategory()` (`'others'` / `'other'` → `'Tech Guides'`) and applied it across `BlogCategoryItem`, `BlogController`, `_BlogGridCard`, and `_BlogListCard` |
| **Missing Search Bar on 2-Section Payload** | `log2.txt` omits a separate `search` section, so no search input appeared on the Blog screen | `_ReactiveBlogFeed` renders an inline `BlogSearchBar` whenever `controller.sectionTypes` does not contain `'search'` |
| **Outdated Canonical Fallback** | `BlogController.defaultCanonicalBlogSections` used an old 4-section layout (`blog-slider`, `search`, `text_block`, `blog`) | Aligned `defaultCanonicalBlogSections` with the live 2-section `log2.txt` payload (`rich_text` + `blog`) |

---

## 3. Live CMS API Structure (`log2.txt`)

`GET /api/mobile-app/blog` returns **2 ordered sections**:

| Index | CMS `type` | Key Content | Mobile Widget |
| :---: | :--- | :--- | :--- |
| **[0]** | `rich_text` | `html_content: "News & Insights"` | **`BlogPageHeader`** (`blog_page_header.dart`) |
| **[1]** | `blog` | `title: "Our Latest Blog Posts"`, `subtitle: "Explore in-depth articles, buying guides, and technical breakdowns."`, `blog_type: "blog_category"`, `no_of_blog: 100`, `category_ids: [...]`, `blogs: [...]` | **`BlogFeedSection`** (`blog_feed_section.dart`) |

---

## 4. Inventory of Created & Modified Files

| File Path | Change | Summary |
| :--- | :---: | :--- |
| **`lib/components/blog_components/blog_page_header.dart`** | **[NEW]** | Created `BlogPageHeader` widget to render `"News & Insights"` as a clean editorial eyebrow badge with optional title/subtitle. |
| **`lib/core/foduuStudio/register_default_widgets.dart`** | **[MODIFIED]** | Added `_isBlogRichTextHeader()` matcher in the `rich_text` builder to route `"News & Insights"` / `"Latest Blog"` to `BlogPageHeader.fromMap()`. |
| **`lib/app/data/models/blog_sections.dart`** | **[MODIFIED]** | Added `normalizeBlogCategory()` (`'others'` / `'other'` → `'Tech Guides'`), added `title` and `subtitle` fields to `BlogFeedSectionData`, and updated default `noOfBlog` to `100`. |
| **`lib/app/modules/blog/controller/blog_controller.dart`** | **[MODIFIED]** | Updated `defaultCanonicalBlogSections` to the 2-section `log2.txt` structure; applied `normalizeBlogCategory()` in `_syncFromSectionsData()`, `_extractCategoriesFromBlogs()`, and `_applyFilters()`. |
| **`lib/components/blog_components/blog_feed_section.dart`** | **[MODIFIED]** | Passed `BlogFeedSectionData` into `_ReactiveBlogFeed` to render CMS `title`/`subtitle`, added inline `BlogSearchBar` fallback when `search` is absent from `sectionTypes`, normalized `'others'`/`'other'` card badges to `'Tech Guides'`, and tuned grid `childAspectRatio` to `0.65`. |

---

## 5. Routing & Socket Verification

- **`lib/core/studio_socket_routing.dart`**: Verified `'blog'`, `'blogs'`, and `'articles'` cases refresh `BlogController.onRefresh()` when on `Routes.BLOG` or navigate to `Routes.BLOG` (no changes needed).
- **`app_config.json`**: Verified `"slug": "blog"`, `"route": "/blog"` entry is present (no changes needed).

---

## 6. Verification Results

- **`flutter analyze`** across `blog_sections.dart`, `blog_controller.dart`, `blog_page_header.dart`, `blog_feed_section.dart`, and `register_default_widgets.dart`: **0 errors** (only pre-existing `deprecated_member_use` `info` notices).
- **`git diff --check`**: Exited with code `0` (no whitespace or formatting issues).
