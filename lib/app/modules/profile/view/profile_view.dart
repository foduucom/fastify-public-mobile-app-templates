import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../components/app_bar/custom_app_bar.dart';
import '../../../../../constants/dynamic_theme.dart' as themeExt;
import '../controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Dynamic scaffold background
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // ✅ Assuming AppTopBar internally supports dynamic theme,
            // otherwise replace with inline Row like OTP screen.
            const AppTopBar(title: 'My Profile'),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: context.primaryColor,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // ── 1. User Info Card ────────────────────────
                      _UserInfoCard(),
                      const SizedBox(height: 16),

                      // ── 2. Quick Actions (Orders, Wishlist, Addresses) ──
                      _QuickActionsRow(),
                      const SizedBox(height: 24),

                      // ── 3. Orders & Purchases ────────────────────
                      _SectionLabel(label: 'Orders & Purchases'),
                      const SizedBox(height: 12),
                      _MenuSection(items: controller.accountSettings),
                      const SizedBox(height: 24),

                      // ── 4. Activity & Support ────────────────────
                      _SectionLabel(label: 'Activity & Support'),
                      const SizedBox(height: 12),
                      _MenuSection(items: controller.otherSettings),

                      const SizedBox(height: 100), // Bottom padding
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

// ── Quick Actions Row (Matches Screenshot) ─────────────────────────
class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionBox(
            context,
            Icons.local_shipping_outlined, // 改成物流图标，更符合订单状态语义
            'Orders',
            'In transit', // 用状态替代纯数字
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionBox(
            context,
            Icons.favorite_border,
            'Wishlist',
            '0 items',
            () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionBox(
            context,
            Icons.location_on_outlined,
            'Addresses',
            '0 saved',
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionBox(
    BuildContext context,
    IconData icon,
    String title,
    String status,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.onSurfaceColor.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.primaryColor, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

// ── User Info Card ─────────────────────────────────────────────────
// ── User Info Card ─────────────────────────────────────────────────
class _UserInfoCard extends GetView<ProfileController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasWallet = controller.walletBal.value > 0;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.onSurfaceColor.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with brand gradient ring feel
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    context.primaryColor.withOpacity(0.25),
                    context.primaryColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildAvatar(
                context,
                controller.avatarUrl.value,
                controller.avatarPath.value,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value
                            : '—',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      if (hasWallet) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '\$${controller.walletBal.value.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: context.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (controller.userEmail.value.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      controller.userEmail.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (controller.userMobile.value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      controller.userMobile.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Edit button clean
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.edit_outlined,
                  size: 16, color: context.primaryColor),
              label: Text(
                'Edit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.primaryColor,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: context.primaryColor.withOpacity(0.08),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      );
    });
  }

  // ✅ THIS IS THE MISSING METHOD — keep it inside _UserInfoCard
  Widget _buildAvatar(BuildContext context, String url, String path) {
    final fallbackIcon = Text(
      controller.userName.value.isNotEmpty
          ? controller.userName.value[0].toUpperCase()
          : 'U',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: context.primaryColor,
      ),
    );

    if (url.isNotEmpty) {
      return Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: fallbackIcon));
    }
    if (path.isNotEmpty && path.startsWith('/')) {
      return Image.file(File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: fallbackIcon));
    }
    if (path.isNotEmpty) {
      return Image.asset(path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Center(child: fallbackIcon));
    }
    return Center(child: fallbackIcon);
  }
}

// ── Menu Section ───────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  final List<ProfileMenuModel> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor, // ✅ Dynamic surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.onSurfaceColor.withOpacity(0.08)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return _MenuItem(item: items[i], isLast: i == items.length - 1);
        }),
      ),
    );
  }
}

// ── Menu Item ────────────────────────
// ── Menu Item ──────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final ProfileMenuModel item;
  final bool isLast;
  const _MenuItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    // 不访问 item.subtitle（Model 没有该字段），统一通过 switch 兜底
    final subtitle = _fallbackSubtitle(item.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        splashColor: context.primaryColor.withOpacity(0.05),
        highlightColor: context.primaryColor.withOpacity(0.03),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.primaryColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        item.iconPath,
                        width: 20,
                        height: 20,
                        color: context.primaryColor,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.circle_outlined,
                          color: context.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.onSurfaceColor,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                color: context.onSurfaceColor.withOpacity(0.05),
                indent: 70,
              ),
          ],
        ),
      ),
    );
  }

  /// 兜底字幕：根据 title 返回副标题。
  /// ⚠️ 注意：字符串里的单引号必须转义为 \'，
  /// 之前 `you\\'ve` 是双反斜杠，Dart 会把它当字面量 + 未闭合字符串，导致语法错误。
  String? _fallbackSubtitle(String title) {
    switch (title) {
      case 'My Orders':
        return 'Track, return, or reorder items';
      case 'Your Wishlist':
        return "Items you've saved for later"; // 用双引号包裹，避免转义
      case 'Saved Addresses':
        return 'Home, work & delivery addresses';
      case 'Payment Methods':
        return 'Saved cards, UPI & wallets';
      case 'Support Tickets':
        return 'View and raise support requests';
      case 'My Reviews':
        return "Reviews & ratings you've posted"; // 同上，用双引号
      default:
        return null;
    }
  }
}
