import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app_colors.dart';
import '../controller/ai_chat_controller.dart';

class AiChatView extends StatelessWidget {
  const AiChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AiChatController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTopBar(controller),
            const SizedBox(height: 16),

            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return _buildEmptyState(controller);
                }
                return _buildMessageList(controller);
              }),
            ),

            // ── Attachment Preview ──────────────────────────
            Obx(() {
              if (controller.attachedFiles.isEmpty) {
                return const SizedBox.shrink();
              }
              return _buildAttachmentPreview(controller);
            }),

            _buildInputBar(controller),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────
  Widget _buildTopBar(AiChatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackground, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Color(0xFF1A1A1A)),
            ),
          ),
          const Expanded(
            child: Text('AI Roomora',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ),
          Obx(() => GestureDetector(
            onTap: controller.messages.isEmpty ? null : controller.clearChat,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackground, shape: BoxShape.circle),
              child: Icon(Icons.refresh_rounded,
                  size: 20,
                  color: controller.messages.isEmpty
                      ? const Color(0xFFD0D0D0)
                      : const Color(0xFF1A1A1A)),
            ),
          )),
        ],
      ),
    );
  }

  // ── Empty / Welcome State ─────────────────────────────────────
  Widget _buildEmptyState(AiChatController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF1A1A1A)),
            clipBehavior: Clip.antiAlias,
            child: Image.asset('assets/images/splash_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.home_work_outlined,
                    size: 36, color:AppColors.scaffoldBackground)),
          ),
          const SizedBox(height: 16),
          const Text('👋 Hi there!',
              style: TextStyle(fontSize: 16, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 6),
          const Text('Say anything...',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Quick Actions',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ),
          const SizedBox(height: 14),
          ...controller.quickActions.map((action) =>
              _QuickActionCard(action: action, controller: controller)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Message List ──────────────────────────────────────────────
  Widget _buildMessageList(AiChatController controller) {
    return Obx(() => ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: controller.messages.length +
          (controller.isTyping.value ? 1 : 0),
      itemBuilder: (_, i) {
        if (i == controller.messages.length && controller.isTyping.value) {
          return _TypingIndicator();
        }
        final msg    = controller.messages[i];
        final isUser = msg['role'] == 'user';
        return _MessageBubble(
          msg: msg,
          isUser: isUser,
          controller: controller,
        );
      },
    ));
  }

  // ── Attachment Preview Bar ────────────────────────────────────
  Widget _buildAttachmentPreview(AiChatController controller) {
    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.attachedFiles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final file = controller.attachedFiles[i];
          final name = controller.attachedNames[i];
          final isImage = ['.jpg', '.jpeg', '.png', '.webp']
              .any((ext) => name.toLowerCase().endsWith(ext));

          return Stack(
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                    color:AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 28, color: Color(0xFF6B6B6B)),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF9E9E9E))),
                    ),
                  ],
                ),
              ),
              // Remove button
              Positioned(
                top: 0, right: 0,
                child: GestureDetector(
                  onTap: () => controller.removeAttachment(i),
                  child: Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A), shape: BoxShape.circle),
                    child: const Icon(Icons.close,
                        size: 12, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Input Bar ─────────────────────────────────────────────────
  Widget _buildInputBar(AiChatController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: const Color(0xFFEEECE8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [

          // ── Attach Button ───────────────────────────────────
          _AttachMenu(controller: controller),
          const SizedBox(width: 8),

          // ── Text Field ──────────────────────────────────────
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.inputController,
                      onChanged: (v) => controller.inputText.value = v,
                      style: const TextStyle(
                          fontSize: 15, color: Color(0xFF1A1A1A)),
                      maxLines: 4,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Ask me anything...',
                        hintStyle: TextStyle(
                            fontSize: 15, color: Color(0xFFB0AEAB)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                      ),
                      textInputAction: TextInputAction.newline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // ── Mic / Send Button ───────────────────────────────
          Obx(() {
            final hasText  = controller.inputText.value.trim().isNotEmpty;
            final hasFiles = controller.attachedFiles.isNotEmpty;
            final canSend  = hasText || hasFiles;
            final listening = controller.isListening.value;

            return GestureDetector(
              onTap: canSend
                  ? () => controller.sendMessage()
                  : controller.toggleMic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 54, height: 54,
                decoration: BoxDecoration(
                  color: listening
                      ? Colors.redAccent
                      : const Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  canSend
                      ? Icons.send_rounded
                      : (listening
                      ? Icons.mic_off_rounded
                      : Icons.mic_rounded),
                  color: Colors.white,
                  size: 22,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Attach Menu ───────────────────────────────────────────────────
class _AttachMenu extends StatelessWidget {
  final AiChatController controller;
  const _AttachMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAttachSheet(context),
      child: Container(
        width: 44, height: 44,
        decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle),
        child: const Icon(Icons.attach_file_rounded,
            size: 20, color: Color(0xFF6B6B6B)),
      ),
    );
  }

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachOption(
                  icon: Icons.image_outlined,
                  label: 'Photo',
                  onTap: () {
                    Get.back();
                    controller.pickImage();
                  },
                ),
                _AttachOption(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'File',
                  onTap: () {
                    Get.back();
                    controller.pickFile();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AttachOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: const Color(0xFFF5F3F0),
                borderRadius: BorderRadius.circular(18)),
            child: Icon(icon, size: 28, color: const Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B6B6B))),
        ],
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  final Map<String, String> action;
  final AiChatController controller;
  const _QuickActionCard({required this.action, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.onQuickAction(action['prompt']!),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${action['emoji']} ${action['title']}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 6),
            Text(action['subtitle']!,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9E9E9E),
                    height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isUser;
  final AiChatController controller;
  const _MessageBubble(
      {required this.msg,
        required this.isUser,
        required this.controller});

  @override
  Widget build(BuildContext context) {
    final text      = msg['text']      as String? ?? '';
    final msgId     = msg['id']        as String? ?? '';
    final files     = msg['files']     as List?   ?? [];
    final fileNames = msg['fileNames'] as List?   ?? [];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [

            // ── Attached files/images ───────────────────────
            if (files.isNotEmpty)
              ...List.generate(files.length, (i) {
                final path = files[i].toString();
                final name = i < fileNames.length
                    ? fileNames[i].toString()
                    : 'file';
                final isImage = ['.jpg', '.jpeg', '.png', '.webp']
                    .any((e) => name.toLowerCase().endsWith(e));
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  width: 180,
                  height: isImage ? 140 : 56,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  clipBehavior: Clip.antiAlias,
                  child: isImage
                      ? Image.file(File(path), fit: BoxFit.cover)
                      : Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(Icons.insert_drive_file_outlined,
                          size: 24, color: Color(0xFF6B6B6B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1A1A1A))),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                );
              }),

            // ── Text bubble ─────────────────────────────────
            if (text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFF1A1A1A)
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(20),
                    topRight:    const Radius.circular(20),
                    bottomLeft:  Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                ),
                child: Text(text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                      height: 1.5,
                    )),
              ),

            // ── TTS button for AI messages ───────────────────
            if (!isUser && text.isNotEmpty) ...[
              const SizedBox(height: 4),
              Obx(() {
                final speaking = controller.isSpeaking.value &&
                    controller.speakingMsgId.value == msgId;
                return GestureDetector(
                  onTap: () => controller.speakMessage(msgId, text),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          speaking
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                          size: 14,
                          color: speaking
                              ? Colors.redAccent
                              : const Color(0xFF6B6B6B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          speaking ? 'Stop' : 'Read aloud',
                          style: TextStyle(
                              fontSize: 11,
                              color: speaking
                                  ? Colors.redAccent
                                  : const Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            const SizedBox(width: 4),
            _Dot(delay: 200),
            const SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(_ctrl);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(
            color: Color(0xFFB0AEAB), shape: BoxShape.circle),
      ),
    );
  }
}
