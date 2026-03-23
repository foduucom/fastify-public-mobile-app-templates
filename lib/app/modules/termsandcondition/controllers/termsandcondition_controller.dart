import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';

// ── Content block model ───────────────────────────────────────────
class TermsBlock {
  final String type;   // 'heading' | 'paragraph'
  final String text;
  const TermsBlock({required this.type, required this.text});
}

class TermsConditionsController extends GetxController {

  // 🔁 Replace with your actual Terms page ID / slug
  static const String _pageSlug = 'terms-and-conditions';

  final RxBool isLoading = false.obs;
  final RxList<TermsBlock> blocks = <TermsBlock>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPage();
  }

  Future<void> fetchPage() async {
    isLoading(true);
    try {
      // BasicProvider._processResponse already returns body["data"]
      final result =
      await BasicProvider('pages?slug=$_pageSlug').getRequest();

      if (result != null) {
        // result might be a List (list endpoint) or Map (single)
        final Map pageData = result is List
            ? (result.isNotEmpty ? result.first as Map : {})
            : result as Map;

        final content = pageData['content']?.toString() ?? '';
        if (content.isNotEmpty) {
          _parseContent(content);
        } else {
          _loadFallback();
        }
      } else {
        _loadFallback();
      }
    } catch (e) {
      debugPrint('TermsController error: $e');
      _loadFallback();
    } finally {
      isLoading(false);
    }
  }

  // ── Parse VC shortcode / HTML → clean blocks ─────────────────
  void _parseContent(String raw) {
    final List<TermsBlock> result = [];

    // 1. Strip all VC shortcode wrappers (keep inner text)
    String cleaned = raw
        .replaceAll(RegExp(r'\[/?\w[^\]]*\]'), ' ')  // remove shortcodes
        .replaceAll(RegExp(r'<br\s*/?>',
        caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<strong>(.*?)</strong>',
        caseSensitive: false, dotAll: true), '###\$1###') // mark headings
        .replaceAll(RegExp(r'<h[1-6][^>]*>(.*?)</h[1-6]>',
        caseSensitive: false, dotAll: true), '###\$1###')
        .replaceAll(RegExp(r'<[^>]*>'), '')  // strip remaining HTML tags
        .replaceAll('&amp;',  '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;',   '<')
        .replaceAll('&gt;',   '>')
        .replaceAll('&#039;', "'");

    // 2. Split into lines and classify
    final lines = cleaned
        .split(RegExp(r'\n{2,}'))   // split on blank lines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    for (final line in lines) {
      if (line.startsWith('###') && line.endsWith('###')) {
        final heading = line.replaceAll('###', '').trim();
        if (heading.isNotEmpty) {
          result.add(TermsBlock(type: 'heading', text: heading));
        }
      } else {
        // Clean up any remaining ### markers
        final para = line.replaceAll('###', '').trim();
        if (para.isNotEmpty) {
          result.add(TermsBlock(type: 'paragraph', text: para));
        }
      }
    }

    if (result.isNotEmpty) {
      blocks.assignAll(result);
      debugPrint('✅ Terms blocks parsed: ${result.length}');
    } else {
      _loadFallback();
    }
  }

  void _loadFallback() {
    debugPrint('⚠️  Using fallback Terms content');
    blocks.assignAll([
      const TermsBlock(type: 'heading',   text: 'Terms'),
      const TermsBlock(type: 'paragraph', text:
      'Welcome to our app. By accessing or using our services, you agree to be bound by these Terms and Conditions. Please read them carefully before proceeding.'),
      const TermsBlock(type: 'paragraph', text:
      'These terms govern your use of all features and services provided through our platform, including purchases, account management, and customer support interactions.'),
      const TermsBlock(type: 'heading',   text: 'Changes to the Service and/or Terms:'),
      const TermsBlock(type: 'paragraph', text:
      'We reserve the right to modify or replace these Terms at any time at our sole discretion. We will provide notice of any significant changes by updating the date at the top of this page.'),
      const TermsBlock(type: 'paragraph', text:
      'Your continued use of the service after any changes constitutes your acceptance of the new Terms. If you do not agree to the new terms, please stop using the service.'),
      const TermsBlock(type: 'heading',   text: 'User Responsibilities:'),
      const TermsBlock(type: 'paragraph', text:
      'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorized use.'),
      const TermsBlock(type: 'paragraph', text:
      'You agree not to use the service for any unlawful purpose or in any way that could damage, disable, or impair the service or interfere with any other party\'s use of the service.'),
      const TermsBlock(type: 'heading',   text: 'Privacy Policy:'),
      const TermsBlock(type: 'paragraph', text:
      'Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information when you use our services.'),
    ]);
  }
}
