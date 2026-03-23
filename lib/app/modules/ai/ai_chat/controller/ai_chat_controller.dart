import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '/app/data/basic_provider.dart';
import '/app/controllers/api_exception_handle_controller.dart';

class AiChatController extends GetxController with BaseController {

  final TextEditingController inputController = TextEditingController();
  final ScrollController      scrollController = ScrollController();

  // ── Observables ───────────────────────────────────────────────
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxString  inputText       = ''.obs;
  final RxBool    isTyping        = false.obs;
  final RxBool    isListening     = false.obs;
  final RxBool    isSpeaking      = false.obs;
  final RxString  speakingMsgId   = ''.obs; // which msg is being read
  final RxList<File>   attachedFiles  = <File>[].obs;
  final RxList<String> attachedNames  = <String>[].obs;

  // ── Services ──────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts        _tts   = FlutterTts();
  bool _speechAvailable = false;

  // ── Quick Actions ─────────────────────────────────────────────
  final List<Map<String, String>> quickActions = [
    {
      'emoji': '🛍️',
      'title': 'Find Products You\'ll Love',
      'subtitle': 'Browse personalized product suggestions based on your preferences.',
      'prompt': 'Find products I\'ll love based on my preferences',
    },
    {
      'emoji': '🎯',
      'title': 'Get Deals on Your Favorites',
      'subtitle': 'Show me discounts on items you\'ve been eyeing.',
      'prompt': 'Show me deals and discounts on my favorite items',
    },
    {
      'emoji': '🗒️',
      'title': 'Browse Trending Items',
      'subtitle': 'See what\'s hot and happening in fashion right now.',
      'prompt': 'Show me trending home decor and furniture items right now',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _initTts();
  }

  @override
  void onClose() {
    inputController.dispose();
    scrollController.dispose();
    _speech.stop();
    _tts.stop();
    super.onClose();
  }

  // ── Init Speech ───────────────────────────────────────────────
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (e) {
        isListening(false);
        debugPrint('Speech error: $e');
      },
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') isListening(false);
      },
    );
  }

  // ── Init TTS ──────────────────────────────────────────────────
  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      isSpeaking(false);
      speakingMsgId.value = '';
    });
  }

  // ── Mic Toggle ────────────────────────────────────────────────
  Future<void> toggleMic() async {
    if (!_speechAvailable) {
      Get.snackbar('Mic unavailable', 'Speech recognition not supported',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12);
      return;
    }

    if (isListening.value) {
      await _speech.stop();
      isListening(false);
      return;
    }

    isListening(true);
    await _speech.listen(
      onResult: (result) {
        inputController.text = result.recognizedWords;
        inputText.value      = result.recognizedWords;
        // move cursor to end
        inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: inputController.text.length),
        );
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      localeId: 'en_US',
    );
  }

  // ── TTS — Read AI Message ─────────────────────────────────────
  Future<void> speakMessage(String msgId, String text) async {
    if (isSpeaking.value && speakingMsgId.value == msgId) {
      // Tap again → stop
      await _tts.stop();
      isSpeaking(false);
      speakingMsgId.value = '';
      return;
    }
    await _tts.stop();
    isSpeaking(true);
    speakingMsgId.value = msgId;
    await _tts.speak(text);
  }

  // ── Pick Image ────────────────────────────────────────────────
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    final file = File(picked.path);
    attachedFiles.add(file);
    attachedNames.add(picked.name);
  }

  // ── Pick File ─────────────────────────────────────────────────
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final pf = result.files.first;
    if (pf.path == null) return;
    attachedFiles.add(File(pf.path!));
    attachedNames.add(pf.name);
  }

  // ── Remove Attachment ─────────────────────────────────────────
  void removeAttachment(int index) {
    attachedFiles.removeAt(index);
    attachedNames.removeAt(index);
  }

  // ── Send Message ──────────────────────────────────────────────
  Future<void> sendMessage([String? overrideText]) async {
    final text        = (overrideText ?? inputController.text).trim();
    final hasFiles    = attachedFiles.isNotEmpty;
    if (text.isEmpty && !hasFiles) return;

    // stop mic if running
    if (isListening.value) {
      await _speech.stop();
      isListening(false);
    }

    final msgId    = DateTime.now().millisecondsSinceEpoch.toString();
    final filePaths = attachedFiles.map((f) => f.path).toList();
    final fileNames = attachedNames.toList();

    // Add user message with attachments snapshot
    messages.add({
      'id':        msgId,
      'role':      'user',
      'text':      text,
      'files':     filePaths,
      'fileNames': fileNames,
    });

    inputController.clear();
    inputText.value = '';
    attachedFiles.clear();
    attachedNames.clear();
    _scrollToBottom();

    isTyping(true);
    try {
      // ── TODO: replace with real API when ready ────────────────
      // final response = await BasicProvider('ai/chat').postRequest({
      //   'message': text,
      // });
      // final reply = response is Map ? response['reply']?.toString() ?? '...' : '...';

      // ── Mock response for now ─────────────────────────────────
      await Future.delayed(const Duration(seconds: 1));
      const reply = 'Thanks for your message! Our AI is being integrated. Stay tuned for smart furniture recommendations. 🛋️';

      final replyId = DateTime.now().millisecondsSinceEpoch.toString();
      messages.add({'id': replyId, 'role': 'ai', 'text': reply});
    } catch (e) {
      debugPrint('AI Chat error: $e');
      messages.add({
        'id':   DateTime.now().millisecondsSinceEpoch.toString(),
        'role': 'ai',
        'text': 'Sorry, I\'m having trouble connecting. Please try again.',
      });
    } finally {
      isTyping(false);
      _scrollToBottom();
    }
  }

  void onQuickAction(String prompt) => sendMessage(prompt);
  void clearChat() {
    messages.clear();
    attachedFiles.clear();
    attachedNames.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
