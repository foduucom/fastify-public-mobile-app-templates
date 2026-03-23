import 'package:get/get.dart';

import '../../components/custom_bottom_navigator_bar/controller/bottom_nav_controller.dart';
import '../../components/custom_bottom_navigator_bar/view/bottom_nav_view.dart';
import '../modules/ai/ai_chat/controller/ai_chat_controller.dart';
import '../modules/ai/ai_chat/view/ai_chat_view.dart';
import '../modules/ai/view/ai_view.dart';
import '../modules/auth/login/views/create_account_view.dart';
import '../modules/auth/login/views/widgets/controller.dart';
import '../modules/auth/otp/bindings/otp_binding.dart';
import '../modules/auth/otp/view/otp_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/view/cart_view.dart';
import '../modules/checkout/controller/checkout_controller.dart';
import '../modules/checkout/view/checkout_view.dart';
import '../modules/helpandsupport/controllers/helpandsupport_controller.dart';
import '../modules/helpandsupport/views/helpandsupport_view.dart';
import '../modules/homepage/products/bindings/product_details_binding.dart';
import '../modules/homepage/products/view/products_details_view.dart';
import '../modules/homepage/views/home_view.dart';
import '../modules/onboarding_controller/bindings/profile_bindings.dart';
import '../modules/onboarding_controller/controller/onboarding_controller.dart';
import '../modules/onboarding_controller/view/onboarding_view.dart';
import '../modules/ordre_history/binding/order_detail_binding.dart';
import '../modules/ordre_history/order_detils/view/order_details_view.dart';
import '../modules/ordre_history/ordrer_binding.dart';
import '../modules/ordre_history/view/order_history_view.dart';
import '../modules/payment/controller/payment_controller.dart';
import '../modules/payment/view/payment_view.dart';
import '../modules/profile/change_password/view/change_password_view.dart';
import '../modules/profile/controller/profile_controller.dart';
import '../modules/profile/profile_updates/personal_info.dart';
import '../modules/profile/view/profile_view.dart';
import '../modules/splashscreen/controller/splash_controller.dart';
import '../modules/splashscreen/view/splashscreen_view.dart';
import '../modules/success/view/success_view.dart';
import '../modules/termsandcondition/controllers/termsandcondition_controller.dart';
import '../modules/termsandcondition/views/termsandcondition_view.dart';
import '../modules/wishlist/view/wishlist_view.dart';
import '/app/modules/homepage/bindings/homepage_binding.dart';
import '/app/modules/intro/bindings/intro_binding.dart';
import '/app/modules/intro/views/intro_view.dart';
import '/app/modules/notification/binding/notificatin_binding.dart';
import '/app/modules/notification/views/notification_view.dart';
import '/app/modules/product/bindings/product_binding.dart';
import '/app/modules/product/views/product_view.dart';



part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;  // ← FIXED: was LOGIN

  static final pages = [                 // ← FIXED: was 'routes'

    // ── Splash ────────────────────────────────────────────────
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: '/aichat',
      page: () => const AiChatView(),
      binding: BindingsBuilder(() => Get.put(AiChatController())),
    ),

    GetPage(
      name: _Paths.AI,
      page: () => const AiRoomoaView(),
      // ✅ No binding needed — AI view is StatefulWidget
    ),
    GetPage(
      name: Routes.OTP,
      page: () => const OtpView(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: '/profile',
      page: () => ProfileView(),
      binding: ProfileBinding(), // if you have one
    ),
    // ── Onboarding ────────────────────────────────────────────
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put<OnboardingController>(OnboardingController());
      }),
    ),

    // ── Bottom Nav ────────────────────────────────────────────
    // FIXED: Only ONE entry for BOTTOMBAR
    GetPage(
      name: _Paths.BOTTOMBAR,
      page: () => const BottomNavView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<BottomNavController>(() => BottomNavController());
      }),
    ),
    GetPage(
      name: '/productdetails',
      page: () => const ProductDetailsView(),   // ← new view
      binding: ProductDetailsBinding(),          // ← new binding
    ),
    GetPage(
      name: '/payment',
      page: () => const PaymentView(),
      binding: BindingsBuilder(() => Get.put(PaymentController())),
    ),
    GetPage(
      name: '/help-support',
      page: () => const HelpSupportView(),
      binding: BindingsBuilder(() => Get.put(HelpSupportController())),
    ),


    // ── Intro ─────────────────────────────────────────────────
    GetPage(
      name: _Paths.INTRO,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),

    // ── Login ─────────────────────────────────────────────────
    GetPage(
      name: _Paths.CREATE_ACCOUNT,
      page: () => const CreateAccountView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CreateAccountController>(
              () => CreateAccountController(),
        );
      }),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomepageBinding(),   // ← this calls the binding above ✅
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: BindingsBuilder(() {
        Get.put<ProfileController>(ProfileController());
      }),
    ),
    GetPage(
      name: '/password',
      page: () => const ChangePasswordView(),
    ),
    GetPage(
      name: '/personal-info',
      page: () => const PersonalInfoView(),
    ),

    GetPage(
      name: '/wishlist',
      page: () => const WishlistView(),
    ),
    GetPage(
      name: _Paths.PRODUCTDETAILS,
      page: () => ProductView(),
      binding: ProductBinding(),
      preventDuplicates: false,
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: '/cart',
      page: () => const CartView(),
      binding: CartBinding(),   // ✅ this was missing
    ),

    GetPage(
      name: _Paths.ORDERS,                                 // ✅ ONLY ONE (removed duplicate)
      page: () => const OrderHistoryView(),
      binding: OrderHistoryBinding(),
    ),
    GetPage(
      name: '/checkout',
      page: () => const CheckoutView(),
      binding: BindingsBuilder(() => Get.put(CheckoutController())),
    ),

    GetPage(
      name: '/terms-conditions',
      page: () => const TermsConditionsView(),
      binding: BindingsBuilder(
            () => Get.put(TermsConditionsController()),
      ),
    ),
    GetPage(
      name:  '/order-success',
      page:  () => const OrderSuccessView(),
      // No controller binding needed — fully self-contained
    ),
    GetPage(
      name:    '/order-detail',         // ← THIS is missing from your file
      page:    () => const OrderDetailView(),
      binding: OrderDetailBinding(),
    ),

  ];
}
