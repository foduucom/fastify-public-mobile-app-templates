import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar2.dart';
import '../controller/messages_controller.dart';


class MessagesView extends GetView<MessagesController> {
  const MessagesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => MessagesController());
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background like the design

      // ── Floating Action Button ──
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A1A1A), // Dark almost-black color
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          // Add new message action
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
        const CustomAppBar2(
                title: 'Message',
                showBackButton: false,
              ),
              const SizedBox(width: 45),
            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: TextField(
                onChanged: (value) => controller.searchTextController.value = value,
                decoration: InputDecoration(
                  // 1. Set the background color here instead of a Container
                  filled: true,
                  fillColor: Colors.grey.shade50,

                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  suffixIcon: Icon(Icons.tune_rounded, color: Colors.grey.shade600),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),

                  // 2. Default rounded border
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),

                  // 3. Border when the TextField is enabled but not clicked
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),

                  // 4. Border when the user clicks/focuses on the TextField
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary), // Or use Colors.grey.shade400
                  ),
                ),
              ),
            ),

            const SizedBox(height: 1),

            // ── Chat List ──
            Expanded(
              child: Obx(() {
                if (controller.chatList.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.chatList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 5),
                  itemBuilder: (context, index) {
                    final chat = controller.chatList[index];
                    return _buildChatItem(chat);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Single Chat Item with Swipe-To-Delete ──
  Widget _buildChatItem(Map<String, dynamic> chat) {
    return Dismissible(
      key: Key(chat['id'].toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        controller.deleteChat(chat['id'].toString());
      },
      // The red background that shows when swiping
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 30.0),
        color: const Color(0xFFFFF0F0), // Very light red background
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.redAccent,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to Chat Details Screen
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              // ── Avatar & Online Status ──
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: CachedNetworkImageProvider(chat['avatar']),
                  ),
                  if (chat['isOnline'] == true)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C853), // Bright green dot
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 15),

              // ── Name & Message Preview ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chat['message'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ── Time & Unread Badge ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chat['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (chat['unread'] > 0)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF4B6B50), // Muted dark green badge
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        chat['unread'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 24), // Placeholder to keep alignment
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}