import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/editprofile_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/commonWidgets/user_avatar.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/services/wishlistService.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);

  final ProfileController _profileController =
      Get.isRegistered<ProfileController>()
          ? Get.find<ProfileController>()
          : Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    // Rebuilds the moment the session is torn down, so cached account data
    // and the account menu never outlive a dead session.
    return Obx(() {
      AuthDetails.loggedIn.value;
      return _buildBody(context);
    });
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!AuthDetails.loggedIn.value) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Your Account',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Log in to view your orders, wishlist, saved addresses, and profile details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    itemText: 'Log In / Sign Up',
                    keypressEvent: () {
                      Get.offAllNamed(Routes.LOGIN);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchDataFromServer();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          children: [
            // 1. Profile Header Card
            _buildProfileHeaderCard(context, colorScheme, isDark),
            const SizedBox(height: 16),

            // 2. Quick Summary Counters (Orders, Wishlist, Addresses)
            _buildQuickStatsRow(context, colorScheme, isDark),
            const SizedBox(height: 20),

            // 3. Orders & Shopping Section
            _buildSectionHeader(context, "ORDERS & PURCHASES"),
            _buildCardGroup(
              context,
              colorScheme,
              [
                _buildTile(
                  context: context,
                  icon: Icons.shopping_bag_outlined,
                  iconBgColor: Colors.deepPurple,
                  title: "My Orders",
                  subtitle: "Track, return, or reorder items",
                  onTap: () => Get.toNamed(Routes.ORDERS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.favorite_outline,
                  iconBgColor: Colors.redAccent,
                  title: "Your Wishlist",
                  subtitle: "Items you've saved for later",
                  onTap: () => Get.toNamed(Routes.WISHLIST),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.location_on_outlined,
                  iconBgColor: Colors.teal,
                  title: "Saved Addresses",
                  subtitle: "Home, work & delivery addresses",
                  onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.credit_card_outlined,
                  iconBgColor: Colors.blueAccent,
                  title: "Payment Methods",
                  subtitle: "Saved cards, UPI & wallets",
                  onTap: () => Get.toNamed(Routes.PAYMENT),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Activity & Engagement Section
            _buildSectionHeader(context, "ACTIVITY & SUPPORT"),
            _buildCardGroup(
              context,
              colorScheme,
              [
                _buildTile(
                  context: context,
                  icon: Icons.confirmation_num_outlined,
                  iconBgColor: Colors.amber.shade800,
                  title: "Support Tickets",
                  subtitle: "View and raise support requests",
                  onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.rate_review_outlined,
                  iconBgColor: Colors.orange,
                  title: "My Reviews",
                  subtitle: "Reviews & ratings you've posted",
                  onTap: () => Get.toNamed(Routes.MY_REVIEWS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.article_outlined,
                  iconBgColor: Colors.indigo,
                  title: "Blogs & Insights",
                  subtitle: "Explore fashion, tech & trends",
                  onTap: () => Get.toNamed(Routes.BLOG),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.headset_mic_outlined,
                  iconBgColor: Colors.green,
                  title: "Contact Us & Help",
                  subtitle: "Get in touch with customer care",
                  onTap: () => Get.toNamed(Routes.CONTACTUS),
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. App Preferences
            _buildSectionHeader(context, "PREFERENCES"),
            _buildCardGroup(
              context,
              colorScheme,
              [
                _buildThemeSelectorTile(context, colorScheme, isDark),
                // _buildTile(
                //   context: context,
                //   icon: Icons.notifications_outlined,
                //   iconBgColor: Colors.deepOrange,
                //   title: "Notifications",
                //   subtitle: "Offers, order alerts & updates",
                //   onTap: () => Get.toNamed(Routes.NOTIFICATION),
                //   isLast: true,
                // ),
              ],
            ),
            const SizedBox(height: 20),

            // 6. Legal & Information Section
            _buildSectionHeader(context, "LEGAL & ABOUT"),
            _buildCardGroup(
              context,
              colorScheme,
              [
                _buildTile(
                  context: context,
                  icon: Icons.description_outlined,
                  iconBgColor: Colors.blueGrey,
                  title: "Terms & Conditions",
                  subtitle: "Platform usage terms",
                  onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
                ),
                _buildTile(
                  context: context,
                  icon: Icons.privacy_tip_outlined,
                  iconBgColor: Colors.blueGrey,
                  title: "Privacy Policy",
                  subtitle: "How your data is handled",
                  onTap: () => Get.toNamed(Routes.PRIVACY_POLICY),
                ),
                // _buildTile(
                //   context: context,
                //   icon: Icons.info_outline,
                //   iconBgColor: Colors.blueGrey,
                //   title: "App Version",
                //   subtitle: "Version 1.0.0 (Latest)",
                //   showChevron: false,
                //   onTap: () {},
                //   isLast: true,
                // ),
              ],
            ),
            const SizedBox(height: 24),

            // 7. Logout Button
            OutlinedButton.icon(
              onPressed: () => _showLogoutConfirmDialog(context),
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
              label: const Text(
                'LOG OUT',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.redAccent, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Profile Header Card with UserAvatar and Edit Button
  Widget _buildProfileHeaderCard(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(() {
            final featuredImg = controller.profiledata['featured_image'];
            final imgUrl =
                featuredImg != null && featuredImg.toString().isNotEmpty
                    ? HelperFunctions().getImage(featuredImg)
                    : null;
            final name = controller.profiledata['name']?.toString();

            return UserAvatar(
              imageUrl: imgUrl,
              name: name,
              radius: 34,
              borderWidth: 2,
              borderColor: colorScheme.primary.withOpacity(0.6),
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.profiledata['name']?.toString() ?? 'User',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.profiledata['email']?.toString() ??
                        controller.profiledata['mobile']?.toString() ??
                        '',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => const EditprofileView());
            },
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text(
              'Edit',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Quick Stats Row (Orders, Wishlist, Addresses)
  Widget _buildQuickStatsRow(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            title: "Orders",
            icon: Icons.local_shipping_outlined,
            color: Colors.deepPurple,
            onTap: () => Get.toNamed(Routes.ORDERS),
            valueWidget: const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.deepPurple,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() {
            int count = 0;
            if (Get.isRegistered<WishListService>()) {
              count = WishListService.to.wishListItems.length;
            }
            return _buildStatCard(
              context: context,
              title: "Wishlist",
              icon: Icons.favorite_border,
              color: Colors.redAccent,
              onTap: () => Get.toNamed(Routes.WISHLIST),
              valueText: count.toString(),
            );
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() {
            final count = controller.addresses.length;
            return _buildStatCard(
              context: context,
              title: "Addresses",
              icon: Icons.place_outlined,
              color: Colors.teal,
              onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
              valueText: count.toString(),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? valueText,
    Widget? valueWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            if (valueText != null)
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else if (valueWidget != null)
              valueWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCardGroup(
      BuildContext context, ColorScheme colorScheme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showChevron = true,
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor.withOpacity(isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color:
                          isDark ? iconBgColor.withOpacity(0.9) : iconBgColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: colorScheme.outlineVariant.withOpacity(0.4),
          ),
      ],
    );
  }

  // Interactive Theme Mode Selector Tile
  Widget _buildThemeSelectorTile(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final themeController = Get.find<ThemeController>();

    return Column(
      children: [
        InkWell(
          onTap: () => _showThemeModeDialog(context, themeController),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color:
                        colorScheme.primary.withOpacity(isDark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme Mode",
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Obx(() {
                        final mode = themeController.themeMode;
                        final modeLabel = mode == ThemeMode.dark
                            ? 'Dark Mode'
                            : mode == ThemeMode.light
                                ? 'Light Mode'
                                : 'System Default';
                        return Text(
                          modeLabel,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.primary,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Obx(() {
                        final mode = themeController.themeMode;
                        final label = mode == ThemeMode.dark
                            ? 'Dark'
                            : mode == ThemeMode.light
                                ? 'Light'
                                : 'Auto';
                        return Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        );
                      }),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.unfold_more,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 68,
          endIndent: 16,
          color: colorScheme.outlineVariant.withOpacity(0.4),
        ),
      ],
    );
  }

  void _showThemeModeDialog(
      BuildContext context, ThemeController themeController) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    "Choose Theme",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('System Default'),
                  subtitle: const Text('Follow system settings'),
                  trailing: themeController.themeMode == ThemeMode.system
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.system);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('Light Mode'),
                  trailing: themeController.themeMode == ThemeMode.light
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.light);
                    Get.back();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: themeController.themeMode == ThemeMode.dark
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.dark);
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.find<BottombarController>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
