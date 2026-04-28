import '../modules/Profie/contact/view/contact_us_view.dart';
import '../modules/Profie/privacy_policy/view/privacy_policy_view.dart';
import '../modules/Profie/profile_address/binding/address_binding.dart';
import '../modules/Profie/profile_address/view/address_view.dart';
import '../modules/Profie/terms&condition/view/terms_conditions_view.dart';
import 'package:foduu_ecommerce/app/modules/orderResponse/bindings/checkout_binding.dart';
import 'package:foduu_ecommerce/app/modules/orderResponse/views/ordersucess_view.dart';

import 'package:foduu_ecommerce/app/modules/address/bindings/address_form_binding.dart';
import 'package:foduu_ecommerce/app/modules/address/bindings/address_list_binding.dart';
import 'package:foduu_ecommerce/app/modules/address/views/address_form_view.dart';
import 'package:foduu_ecommerce/app/modules/address/views/address_list_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/binding/otp_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/view/otp_view.dart';
import 'package:foduu_ecommerce/app/modules/custompage/bindings/custompage_binding.dart';
import 'package:foduu_ecommerce/app/modules/custompage/views/custompage_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/home_view.dart';

import 'package:foduu_ecommerce/app/modules/Profie/delete_account/binding/binding.dart';
import 'package:foduu_ecommerce/app/modules/Profie/delete_account/view/views.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/binding/order_binding.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/orders_details/binding/orderdetails_binding.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/orders_details/view/orderdetails_view.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/view/order_view.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/order_products/binding/order_products_binding.dart';
import 'package:foduu_ecommerce/app/modules/Profie/orders/order_products/view/order_products_view.dart';
import 'package:foduu_ecommerce/app/modules/aboutus/bindings/aboutus_binding.dart';
import 'package:foduu_ecommerce/app/modules/aboutus/views/aboutus_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/forgotepassword/bindings/forgotepassword_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/forgotepassword/views/forgotepassword_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/bindings/login_binding.dart';

import 'package:foduu_ecommerce/app/modules/auth/login/views/login_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/register/bindings/register_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/register/views/register_view.dart';
import 'package:foduu_ecommerce/app/modules/blog/binding.dart/blog_binding.dart';
import 'package:foduu_ecommerce/app/modules/blog/views/blog_details_view.dart';
import 'package:foduu_ecommerce/app/modules/blog/views/blog_view.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/bindings/bottombar_binding.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/views/bottombar_view.dart';
import 'package:foduu_ecommerce/app/modules/cart/bindings/cart_binding.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:foduu_ecommerce/app/modules/category/bindings/category_binding.dart';
import 'package:foduu_ecommerce/app/modules/category/views/category_view.dart';
import 'package:foduu_ecommerce/app/modules/category/views/categorydetail_view.dart';
import 'package:foduu_ecommerce/app/modules/contact/binding/contact_binding.dart';
import 'package:foduu_ecommerce/app/modules/contact/views/contact_view.dart';
import 'package:foduu_ecommerce/app/modules/helpandsupport/bindings/helpandsupport_binding.dart';
import 'package:foduu_ecommerce/app/modules/helpandsupport/views/helpandsupport_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/bindings/homepage_binding.dart';
import 'package:foduu_ecommerce/app/modules/intro/bindings/intro_binding.dart';
import 'package:foduu_ecommerce/app/modules/intro/views/intro_view.dart';
import 'package:foduu_ecommerce/app/modules/notification/binding/notificatin_binding.dart';
import 'package:foduu_ecommerce/app/modules/notification/views/notification_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/bindings/profile_binding.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/profile_view.dart';
import 'package:foduu_ecommerce/app/modules/product/bindings/product_binding.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/search/views/search_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/shop_view.dart';
import 'package:foduu_ecommerce/app/modules/termsandcondition/bindings/termsandcondition_binding.dart';
import 'package:foduu_ecommerce/app/modules/termsandcondition/views/termsandcondition_view.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/bindings/wishlist_binding.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';

import 'package:foduu_ecommerce/app/modules/search/bindings/search_binding.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    // GetPage(
    //   name: _Paths.SPLASHSCREEN,
    //   page: () => SplashscreenView(),
    // ),
    GetPage(
      name: _Paths.INTRO,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),

    GetPage(
      name: _Paths.OTP,
      page: () => OTPView(),
      binding: OtpBinding(),
    ),

    // GetPage(
    //   name: _Paths.MOBILELOGINOTP,
    //   page: () => LoginOtpView(),
    //   binding: MobileNoLoginBinding(),
    // ),
    // GetPage(
    //   name: _Paths.MOBILEREGISTER,
    //   page: () => MobileNoRegisterView(),
    //   binding: MobileNoLoginBinding(),
    // ),
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
      name: _Paths.HOME,
      page: () => Testinghome(),
      binding: HomepageBinding(),
    ),

    GetPage(
      name: _Paths.BOTTOMBAR,
      page: () => BottombarView(),
      binding: BottombarBinding(),
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
      name: _Paths.BLOG_DETAILS,
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
      binding: OrderdetailBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_PRODUCTS,
      page: () => const OrderProductsView(),
      binding: OrderProductsBinding(),
    ),
    GetPage(
      name: _Paths.DETAILCATEGORY,
      page: () => CategeorydetailView(),
      // binding: CategoryDet(),
    ),
    GetPage(
      name: _Paths.SHOPPRODUCTLISTVIEW,
      page: () => ShopView(),
      binding: ShopBinding(),
    ),
    GetPage(
        name: _Paths.PRODUCTDETAILS,
        page: () => ProductView(),
        binding: ProductBinding(),
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
            name: _Paths.PAYMENT,
            page: () => CheckOutView(),
            binding: CheckOutBinding(),
          ),
          GetPage(
            name: _Paths.ORDERSUCCESS,
            page: () => OrdersucessView(),
            binding: OrderResponseBinding(),
          ),
        ]),

    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),

    GetPage(
      name: _Paths.ADDRESS_LIST,
      page: () => AddressListView(),
      binding: AddressListBinding(),
    ),

    GetPage(
      name: _Paths.ADDRESS_LIST1, // ensure this is defined in app_routes.dart
      page: () => const AddressView(),
      binding: AddressBinding(),
    ),

    GetPage(
      name: _Paths.ADDRESS_ADD, // ensure this is defined in app_routes.dart
      page: () => const AddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: _Paths.ADDRESS_FORM,
      page: () => AddressFormView(),
      binding: AddressFormBinding(),
    ),
    GetPage(
      name: _Paths.ABOUTUS,
      page: () => const AboutusView(),
      binding: AboutusBinding(),
    ),
    GetPage(
      name: _Paths.HELPANDSUPPORT,
      page: () => const HelpandsupportView(),
      binding: HelpandsupportBinding(),
    ),
    GetPage(
      name: _Paths.TERMSANDCONDITION,
      page: () => const TermsandconditionView(),
      binding: TermsandconditionBinding(),
    ),
    GetPage(
      name: _Paths.CUSTOMPAGE,
      page: () => CustomPageView(),
      binding: CustomPageBinding(),
    ),

    GetPage(
      name: _Paths.CONTACTUS,
      page: () => ContactUsView(),

    ),

    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: _Paths.TERMS_CONDITIONS,
      page: () => const TermsConditionsView(),
    ),
  ];

  static searchVi() {}
}
