import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECE8E5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AppTopBar(title: 'Profile'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF1A1A1A)),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _UserInfoCard(),
                      const SizedBox(height: 24),
                      _SectionLabel(label: 'Account settings'),
                      const SizedBox(height: 16),
                      _MenuSection(items: controller.accountSettings),
                      const SizedBox(height: 24),
                      _SectionLabel(label: 'Other'),
                      const SizedBox(height: 16),
                      _MenuSection(items: controller.otherSettings),
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }


}

// ── Section Label ──────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A)));
  }
}

// ── User Info Card ─────────────────────────────────────────────────
class _UserInfoCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // ── Avatar ───────────────────────────────────────
            Container(
              width: 64, height: 64,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9D9D9)),
              clipBehavior: Clip.antiAlias,
              child: _buildAvatar(
                controller.avatarUrl.value,
                controller.avatarPath.value,
              ),
            ),
            const SizedBox(width: 14),

            // ── Name / Email / Mobile ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : '—',
                    style: const TextStyle(
                        fontSize:   16,
                        fontWeight: FontWeight.w600,
                        color:      Color(0xFF1A1A1A)),
                  ),
                  if (controller.userEmail.value.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(controller.userEmail.value,
                        style: const TextStyle(
                            fontSize: 13,
                            color:    Color(0xFF6B6B6B))),
                  ],
                  if (controller.userMobile.value.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(controller.userMobile.value,
                        style: const TextStyle(
                            fontSize: 13,
                            color:    Color(0xFF6B6B6B))),
                  ],
                ],
              ),
            ),

            // ── Wallet Badge ──────────────────────────────────
            if (controller.walletBal.value > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color:        const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '💰 \$${controller.walletBal.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color:      Colors.white,
                      fontSize:   12,
                      fontWeight: FontWeight.w500),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildAvatar(String url, String path) {
    if (url.isNotEmpty) {
      return Image.network(url, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback());
    }
    if (path.isNotEmpty && path.startsWith('/')) {
      return Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback());
    }
    if (path.isNotEmpty) {
      return Image.asset(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback());
    }
    return _fallback();
  }

  Widget _fallback() =>
      const Icon(Icons.person, size: 32, color: Color(0xFF9E9E9E));
}

// ── Menu Section ───────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  final List<ProfileMenuModel> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return _MenuItem(
            item:      items[i],
            isLast:    i == items.length - 1,
          );
        }),
      ),
    );
  }
}

// ── Menu Item ──────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final ProfileMenuModel item;
  final bool isLast;
  const _MenuItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(
                      color: Color(0xFF1A1A1A),
                      shape: BoxShape.circle),
                  child: Center(
                    child: Image.asset(
                      item.iconPath,
                      width: 20, height: 20,
                      color: Colors.white,
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.circle_outlined,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          fontSize:   14,
                          fontWeight: FontWeight.w500,
                          color:      Color(0xFF1A1A1A))),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF9E9E9E), size: 22),
              ],
            ),
          ),
          if (!isLast)
            Divider(height: 1,
                color: const Color(0xFFEEECE8),
                indent: 70),
        ],
      ),
    );
  }
}
