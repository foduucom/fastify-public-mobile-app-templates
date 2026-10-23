import 'package:get/get.dart';
import 'package:zouhi/app/modules/Profie/orders/orders_details/view/orderdetail_view.dart';
import 'package:zouhi/app/modules/blog/views/blgo_details_view.dart';
import 'package:zouhi/app/modules/supportTicketDetails/binding/supportTicketDetails_binding.dart';
import 'package:zouhi/app/modules/supportTicketDetails/views/supportTicketDetails_view.dart';
import 'package:zouhi/app/modules/support_ticket/binding/support_ticker_binding.dart';
import 'package:zouhi/app/modules/support_ticket/views/supportticket_view.dart';
import 'package:zouhi/app/modules/quotes/bindings/my_quotes_request_binding.dart';
import 'package:zouhi/app/modules/quotes/views/my_quotes_request_view.dart';
import 'package:zouhi/app/modules/reviews/bindings/my_reviews_binding.dart';
import 'package:zouhi/app/modules/reviews/views/my_reviews_view.dart';

import '../modules/Profie/delete_account/binding/binding.dart';
import '../modules/Profie/delete_account/view/views.dart';
import '../modules/Profie/orders/binding/order_binding.dart';
import '../modules/Profie/orders/orders_details/binding/orderdetails_binding.dart';
import '../modules/Profie/orders/orders_details/view/orderdetails_view.dart';
import '../modules/Profie/orders/view/order_view.dart';
import '../modules/Profie/profile/bindings/profile_binding.dart';
import '../modules/Profie/profile/views/profile_view.dart';
import '../modules/Profie/profile/views/security_settings_view.dart';
import '../modules/aboutus/bindings/aboutus_binding.dart';
import '../modules/aboutus/views/aboutus_view.dart';
import '../modules/address/bindings/address_binding.dart';
import '../modules/address/views/address_view.dart';
import '../modules/address/views/addupdateAddress_view.dart';
import '../modules/address/views/delivery_detial_view.dart';
import '../modules/auth/email_password/forgotepassword/bindings/forgotepassword_binding.dart';
import '../modules/auth/email_password/forgotepassword/views/forgotepassword_view.dart';
import '../modules/auth/email_password/otp_verification/bindings/email_otp_binding.dart';
import '../modules/auth/email_password/otp_verification/views/email_otp_view.dart';
import '../modules/auth/email_password/login/bindings/login_binding.dart';
import '../modules/auth/email_password/login/views/login_view.dart';
import '../modules/auth/email_password/register/bindings/register_binding.dart';
import '../modules/auth/email_password/register/views/register_view.dart';
import '../modules/auth/mobile_number/binding/mobilelogin_binding.dart';
import '../modules/auth/mobile_number/view/mobileLoginOTP_view.dart';
import '../modules/auth/mobile_number/view/mobileLogin_view.dart';
import '../modules/auth/mobile_number/view/mobileRegister_view.dart';
import '../modules/blog/binding.dart/blog_binding.dart';
import '../modules/blog/views/blog_view.dart';
import '../modules/bottomar/bindings/bottombar_binding.dart';
import '../modules/bottomar/views/bottombar_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/category/bindings/category_binding.dart';
import '../modules/category_products/bindings/category_products_binding.dart';
import '../modules/category_products/views/category_products_view.dart';
import '../modules/category/views/category_view.dart';
import '../modules/category/views/categorydetail_view.dart';
import '../modules/contact/binding/contact_binding.dart';
import '../modules/contact/views/contact_view.dart';
import '../modules/helpandsupport/bindings/helpandsupport_binding.dart';
import '../modules/helpandsupport/bindings/policy_binding.dart';
import '../modules/helpandsupport/views/helpandsupport_view.dart';
import '../modules/helpandsupport/views/policy_detail_view.dart';
import '../modules/homepage/bindings/homepage_binding.dart';
import '../modules/homepage/views/home.dart';
import '../modules/notification/binding/notificatin_binding.dart';
import '../modules/notification/views/notification_view.dart';
import '../modules/pages/home/bindings/page_binding.dart';
import '../modules/pages/home/views/page_view.dart';
import '../modules/payment/bindings/payment_binding.dart';
import '../modules/payment/views/ordersucess_view.dart';
import '../modules/payment/views/payment_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/shop/bindings/shop_binding.dart';
import '../modules/shop/views/productdetail_view.dart';
import '../modules/shop/views/shop_view.dart';
import '../modules/splashscreen/splashscreen_view.dart';
import '../modules/termsandcondition/bindings/termsandcondition_binding.dart';
import '../modules/termsandcondition/views/termsandcondition_view.dart';
import '../modules/wishlist/bindings/wishlist_binding.dart';
import '../modules/wishlist/views/wishlist_view.dart';
import '../modules/pages/solutions/bindings/solutions_binding.dart';
import '../modules/pages/solutions/views/solutions_view.dart';
import '../modules/pages/services/bindings/services_binding.dart';
import '../modules/pages/services/views/services_view.dart';
import '../modules/coupons/bindings/coupons_binding.dart';
import '../modules/coupons/views/coupons_view.dart';
import '../modules/cable_assemblies/bindings/cable_assemblies_binding.dart';
import '../modules/cable_assemblies/views/cable_assemblies_view.dart';
import '../modules/mtp_solution/bindings/mtp_solution_binding.dart';
import '../modules/mtp_solution/views/mtp_solution_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    // GetPage(
    //     name: _Paths.INTRO,
    //     page: () => const IntroView(),
    //     binding: IntroBinding()),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashscreenView(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.MOBILELOGIN,
      page: () => MobileNoLoginView(),
      binding: MobileNoLoginBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.MOBILELOGINOTP,
      page: () => LoginOtpView(),
      binding: MobileNoLoginBinding(),
    ),
    GetPage(
      name: _Paths.MOBILEREGISTER,
      page: () => MobileNoRegisterView(),
      binding: MobileNoLoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FOREGETPASSWORD,
      page: () => const ForgotepasswordView(),
      binding: ForgotepasswordBinding(),
    ),
    GetPage(
      name: _Paths.EMAIL_OTP,
      page: () => const EmailOtpView(),
      binding: EmailOtpBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD_OTP,
      page: () => const EmailOtpView(),
      binding: EmailOtpBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomePageView(),
      binding: HomepageBinding(),
      // children: [
      //   GetPage(
      //     name: _Paths.PAGE,
      //     page: () => const PageView(),
      //     binding: PageBinding(),
      //   ),
      // ],
    ),
    GetPage(
      name: _Paths.PAGES,
      page: () => const PageView(),
      binding: PageBinding(),
    ),

    GetPage(
      name: _Paths.BOTTOMBAR,
      page: () => BottombarView(),
      binding: BottombarBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: _Paths.CATEGORY,
      page: () => CategoryView(),
      binding: CategoryBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.BLOG,
      page: () => BlogView(),
      binding: BlogBinding(),
    ),
    GetPage(
      name: _Paths.BLOGDETAILS,
      page: () => BlogDetailsView(),
      binding: BlogBinding(),
    ),
    GetPage(
      name: _Paths.CONTACT,
      page: () => ContactView(),
      binding: ContactBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DELETE_ACCOUNT,
      page: () => DeleteAccountView(),
      binding: DeleteAccountBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => OrdersView(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_DETAILS,
      page: () => OrderdetailView(),
      //page: () => OrderTrackingCard(),
      binding: OrderdetailBinding(),
    ),
    GetPage(
      name: _Paths.DETAILCATEGORY,
      page: () => CategeorydetailView(),
      // binding: CategoryDet(),
    ),
    GetPage(
      name: _Paths.CATEGORYPRODUCTS,
      page: () => const CategoryProductsView(),
      binding: CategoryProductsBinding(),
    ),
    GetPage(
      name: _Paths.SHOPPRODUCTLISTVIEW,
      page: () => ShopView(),
      binding: ShopBinding(),
    ),
    // binding: CategoryDet(),
    GetPage(
        name: _Paths.PRODUCTDETAILS,
        page: () => ProductdetailView(),
        binding: ShopBinding(),
        preventDuplicates: false),
    GetPage(
      name: _Paths.WISHLIST,
      page: () => WishlistView(),
      binding: WishlistBinding(),
    ),
    GetPage(
        name: _Paths.CART,
        page: () => CartView(),
        binding: CartBinding(),
        children: [
          GetPage(
            name: _Paths.DELIVERYADDRESS,
            page: () => DeliveryDetialView(),
            binding: AddressBinding(),
          ),
          GetPage(
            name: _Paths.PAYMENT,
            page: () => PaymentView(),
            binding: PaymentBinding(),
          ),
          GetPage(
            name: _Paths.ORDERSUCCESS,
            page: () => OrdersucessView(),
          )
        ]),

    GetPage(
      name: _Paths.SEARCH,
      page: () => SearchView(),
      binding: SearchBinding(),
    ),

    GetPage(
      name: _Paths.ADD_UPDATE_ADDRESS,
      page: () => AddUpdateAddress(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: _Paths.MANAGEADDRESS,
      page: () => AccountManageAddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: _Paths.ABOUTUS,
      page: () => const AboutusView(),
      binding: AboutusBinding(),
    ),
    GetPage(
      name: _Paths.HELPANDSUPPORT,
      page: () => HelpAndSupportView(),
      binding: HelpandsupportBinding(),
    ),
    GetPage(
      name: _Paths.POLICY_DETAIL,
      page: () => const PolicyDetailView(),
      binding: PolicyBinding(),
    ),
    GetPage(
      name: _Paths.TERMSANDCONDITION,
      page: () => const TermsandconditionView(),
      binding: TermsandconditionBinding(),
    ),

    GetPage(
      name: _Paths.SUPPORTTICKET,
      page: () => SupportTicketView(),
      binding: SupportTicketBinding(),
    ),
    GetPage(
        name: _Paths.SUPPORTTICKETDETAILS,
        page: () => SupportTicketDetailsView(),
        binding: SupportTicketDetailsBinding()),
    GetPage(
        name: Routes.SHOP_DEEP_LINK,
        page: () => ProductdetailView(),
        binding: ShopBinding(),
        preventDuplicates: false),
    GetPage(
      name: _Paths.MY_QUOTES,
      page: () => const MyQuotesRequestView(),
      binding: MyQuotesRequestBinding(),
    ),
    GetPage(
      name: _Paths.MY_REVIEWS,
      page: () => const MyReviewsView(),
      binding: MyReviewsBinding(),
    ),
    GetPage(
      name: Routes.SHOP,
      page: () => ShopView(),
      binding: ShopBinding(),
    ),
    GetPage(
      name: Routes.ORDER_DETAILS_NEW,
      page: () => OrderdetailView(),
      binding: OrderdetailBinding(),
    ),
    GetPage(
      name: Routes.SECURITY_SETTINGS,
      page: () => SecuritySettingsView(),
    ),
    GetPage(
      name: _Paths.SOLUTIONS,
      page: () => const SolutionsView(),
      binding: SolutionsBinding(),
    ),
    GetPage(
      name: _Paths.SOLUTION,
      page: () => const SolutionsView(),
      binding: SolutionsBinding(),
    ),
    GetPage(
      name: _Paths.SERVICES,
      page: () => const ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: _Paths.COUPONS,
      page: () => const CouponsView(),
      binding: CouponsBinding(),
    ),
    GetPage(
      name: _Paths.CABLE_ASSEMBLIES,
      page: () => const CableAssembliesView(),
      binding: CableAssembliesBinding(),
    ),
    GetPage(
      name: _Paths.MTP_SOLUTION,
      page: () => const MtpSolutionView(),
      binding: MtpSolutionBinding(),
    ),
  ];

  static searchVi() {}
}
