import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';

class HelpSupportController extends GetxController {

  static const String _pageId = '69a2a06406d88f94cbdc8cd7';

  final RxBool  isLoading     = false.obs;
  final RxString searchQuery  = ''.obs;
  final RxInt   expandedIndex = (-1).obs;

  final RxList<Map<String, String>> allFaqs =
      <Map<String, String>>[].obs;

  List<Map<String, String>> get filteredFaqs {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allFaqs;
    return allFaqs
        .where((f) =>
    (f['title']  ?? '').toLowerCase().contains(q) ||
        (f['answer'] ?? '').toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchPage();
  }

  // ── Use BasicProvider exactly as senior says ─────────────────
  Future<void> fetchPage() async {
    isLoading(true);
    try {
      // BasicProvider._processResponse already returns response["data"]
      // so `result` here IS the page object directly
      final result = await BasicProvider('pages/$_pageId').getRequest();

      if (result != null && result is Map) {
        final content = result['content']?.toString() ?? '';
        if (content.isNotEmpty) {
          _parseContent(content);
        } else {
          _loadFallback();
        }
      } else {
        _loadFallback();
      }
    } catch (e) {
      debugPrint('HelpSupportController fetchPage error: $e');
      _loadFallback();
    } finally {
      isLoading(false);
    }
  }

  // ── Parse wpbriodeinfobox blocks from VC content ──────────────
  void _parseContent(String raw) {
    final List<Map<String, String>> items = [];

    // Split on infobox boundaries
    final parts = raw.split('wpbriodeinfobox');

    for (int i = 1; i < parts.length; i++) {
      final block = parts[i];

      // ── Extract title ─────────────────────────────────────
      String title = '';

      // Try quoted: title="..."
      final tQuoted =
      RegExp(r'title\s*=\s*"([^"]+)"').firstMatch(block);
      // Try unquoted: title XXXXX (base64 or plain)
      final tUnquoted =
      RegExp(r'\btitle\s+([A-Za-z0-9+/=%]+)').firstMatch(block);

      if (tQuoted != null) {
        title = _decode(tQuoted.group(1) ?? '');
      } else if (tUnquoted != null) {
        title = _decode(tUnquoted.group(1) ?? '');
      }

      // ── Extract description ───────────────────────────────
      String answer = '';

      final dQuoted =
      RegExp(r'description\s*=\s*"([^"]+)"').firstMatch(block);
      final dUnquoted =
      RegExp(r'\bdescription\s+([A-Za-z0-9+/=%\s.]+?)(?=\s+\w+\s*[=\[\]]|$)',
          dotAll: false)
          .firstMatch(block);

      if (dQuoted != null) {
        answer = _decode(dQuoted.group(1) ?? '');
      } else if (dUnquoted != null) {
        answer = _decode(dUnquoted.group(1) ?? '');
      }

      // ── Fallback: grab vccolumntext between this infobox ──
      if (answer.isEmpty) {
        final textMatch = RegExp(
          r'\[vccolumntext[^\]]*\](.*?)\[/vccolumntext\]',
          dotAll: true,
        ).firstMatch(block);
        if (textMatch != null) {
          answer = textMatch.group(1)
              ?.replaceAll(RegExp(r'<[^>]*>'), '')
              .trim() ??
              '';
        }
      }

      if (title.isNotEmpty) {
        items.add({'title': title, 'answer': answer});
      }
    }

    if (items.isNotEmpty) {
      allFaqs.assignAll(items);
      debugPrint('✅ FAQs parsed from API: ${items.length}');
    } else {
      _loadFallback();
    }
  }

  // ── Decode base64 / URL-encoded values ────────────────────────
  String _decode(String value) {
    final trimmed = value.trim();
    // Try base64 first
    try {
      if (RegExp(r'^[A-Za-z0-9+/]+=*$').hasMatch(trimmed) &&
          trimmed.length % 4 == 0) {
        final bytes   = base64Decode(trimmed);
        final decoded = utf8.decode(bytes);
        // Sanity check — decoded must be readable text
        if (decoded.isNotEmpty && !decoded.contains('\x00')) {
          return Uri.decodeFull(decoded).trim();
        }
      }
    } catch (_) {}

    // Try URL decode
    try {
      return Uri.decodeFull(trimmed.replaceAll('+', ' ')).trim();
    } catch (_) {
      return trimmed;
    }
  }

  // ── Fallback FAQs ─────────────────────────────────────────────
  void _loadFallback() {
    debugPrint('⚠️  Using fallback FAQs');
    allFaqs.assignAll([
      {
        'title':  'How do I track my order?',
        'answer': 'Go to Orders in your profile. Tap any order to see real-time tracking.',
      },
      {
        'title':  'What is the return policy?',
        'answer': 'We offer a 30-day return policy. Items must be unused and in original packaging.',
      },
      {
        'title':  'How do I cancel an order?',
        'answer': 'Orders can be cancelled within 24 hours. Go to Orders → Select order → Cancel.',
      },
      {
        'title':  'How long does delivery take?',
        'answer': 'Standard: 5–7 business days. Express (2–3 days) available at checkout.',
      },
      {
        'title':  'How do I contact support?',
        'answer': 'Email support@app.com or call 1-800-SUPPORT (Mon–Fri 9am–6pm).',
      },
    ]);
  }

  void toggleExpand(int index) {
    expandedIndex.value = expandedIndex.value == index ? -1 : index;
  }

  void onSearch(String value) {
    searchQuery.value   = value;
    expandedIndex.value = -1;
  }
}
