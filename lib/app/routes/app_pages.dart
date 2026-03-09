import 'package:foduu_ecommerce/app/modules/add_profile/bindings/add_profile_binding.dart';
import 'package:foduu_ecommerce/app/modules/add_profile/views/add_profile_view.dart';
import 'package:foduu_ecommerce/app/modules/address/bindings/address_form_binding.dart';
import 'package:foduu_ecommerce/app/modules/address/bindings/address_list_binding.dart';
import 'package:foduu_ecommerce/app/modules/address/views/address_form_view.dart';
import 'package:foduu_ecommerce/app/modules/address/views/address_list_view.dart';
import 'package:foduu_ecommerce/app/modules/addtocart/bindings/add_to_cart_bindings.dart';
import 'package:foduu_ecommerce/app/modules/addtocart/views/add_to_cart_views.dart';
import 'package:foduu_ecommerce/app/modules/auth/createnewpassword/bindings/create_new_password__bindings.dart';
import 'package:foduu_ecommerce/app/modules/auth/createnewpassword/views/create_new_password_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/forgotepassword/bindings/forgotepassword_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/forgotepassword/views/forgotepassword_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/bindings/login_binding.dart';

import 'package:foduu_ecommerce/app/modules/auth/login/views/login_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/binding/otp_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/view/otp_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/register/bindings/register_binding.dart';
import 'package:foduu_ecommerce/app/modules/auth/register/views/register_view.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/bindings/bottombar_binding.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/views/bottombar_view.dart';
import 'package:foduu_ecommerce/app/modules/cart/bindings/cart_binding.dart';
import 'package:foduu_ecommerce/app/modules/cart/views/cart_view.dart';
import 'package:foduu_ecommerce/app/modules/category/bindings/category_binding.dart';
import 'package:foduu_ecommerce/app/modules/category/views/categorydetail_view.dart';
import 'package:foduu_ecommerce/app/modules/checkout/bindings/checkout_bindings.dart';
import 'package:foduu_ecommerce/app/modules/checkout/views/checkout_views.dart';
import 'package:foduu_ecommerce/app/modules/choose_category/bindings/choose_category_binding.dart';
import 'package:foduu_ecommerce/app/modules/choose_category/views/choose_category_view.dart';
import 'package:foduu_ecommerce/app/modules/homepage/bindings/homepage_binding.dart';
import 'package:foduu_ecommerce/app/modules/homepage/views/home_page_view.dart';
import 'package:foduu_ecommerce/app/modules/intro/bindings/intro_binding.dart';
import 'package:foduu_ecommerce/app/modules/intro/views/intro_view.dart';
import 'package:foduu_ecommerce/app/modules/notification/binding/notificatin_binding.dart';
import 'package:foduu_ecommerce/app/modules/notification/views/notification_view.dart';
import 'package:foduu_ecommerce/app/modules/onboarding/bindings/onboarding_binding.dart';
import 'package:foduu_ecommerce/app/modules/onboarding/views/onboarding_view.dart';
import 'package:foduu_ecommerce/app/modules/product/bindings/product_binding.dart';
import 'package:foduu_ecommerce/app/modules/product/views/product_view.dart';
import 'package:foduu_ecommerce/app/modules/search/bindings/search_binding.dart';
import 'package:foduu_ecommerce/app/modules/search/views/search_view.dart';
import 'package:foduu_ecommerce/app/modules/shop/bindings/shop_binding.dart';
import 'package:foduu_ecommerce/app/modules/shop/views/shop_view.dart';
import 'package:foduu_ecommerce/app/modules/splashscreen/bindings/splashscreen_binding.dart';
import 'package:foduu_ecommerce/app/modules/splashscreen/view/splashscreen_view.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/bindings/wishlist_binding.dart';
import 'package:foduu_ecommerce/app/modules/wishlist/views/wishlist_view.dart';
import 'package:get/get.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
        name: _Paths.INTRO,
        page: () => const IntroView(),
        binding: IntroBinding()),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),

    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),

    GetPage(
      name: _Paths.ADDRESS_LIST,
      page: () => AddressListView(),
      binding: AddressListBinding(),
    ),
    GetPage(
      name: _Paths.ADDRESS_FORM,
      page: () => AddressFormView(),
      binding: AddressFormBinding(),
    ),

    // GetPage(
    //   name: _Paths.SIGNIN,
    //   page: () => const SigninView(),
    //   binding: SigninBindings(),
    // ),

    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),

    // GetPage(
    //   name: _Paths.SIGNUP,
    //   page: () => const SignupView(),
    //   binding: SignupBinding(),
    // ),

    GetPage(
      name: _Paths.SEARCH,
      page: () => SearchView(),
      binding: SearchBinding(),
    ),

    GetPage(
      name: _Paths.FOREGETPASSWORD,
      page: () => const ForgotepasswordView(),
      binding: ForgotepasswordBinding(),
    ),

    GetPage(
      name: _Paths.OTP,
      page: () => OTPView(),
      binding: OtpBinding(),
    ),

    GetPage(
      name: _Paths.HOME,
      page: () => HomePageView(),
      binding: HomepageBinding(),
    ),

    GetPage(
      name: _Paths.CREATENEWPASSWORD,
      page: () => const CreateNewPasswordView(),
      binding: CreateNewPasswordBinding(),
    ),

    GetPage(
      name: _Paths.ADDPROFILE,
      page: () => const AddProfileView(),
      binding: AddProfileBinding(),
    ),

    GetPage(
      name: _Paths.CHOOSECATEGORY,
      page: () => const ChooseCategoryView(),
      binding: ChooseCategoryBinding(),
    ),

    // GetPage(
    //   name: _Paths.PRODUCTDETAILS,
    //   page: () => const ProductDetailViews(),
    //   binding: ProductDetailsBinding(),
    // ),

    GetPage(
      name: _Paths.ADDTOCART,
      page: () => const AddToCartViews(),
      binding: AddToCartBindings(),
    ),

    GetPage(
      name: _Paths.CART,
      page: () => CartView(),
      binding: CartBinding(),
    ),

    GetPage(
      name: _Paths.PRODUCTDETAILS,
      page: () => ProductView(),
      binding: ProductBinding(),
    ),

    GetPage(
      name: _Paths.CHECKOUT,
      page: () => CheckoutViews(),
      binding: CheckoutBindings(),
    ),

    GetPage(
      name: _Paths.DETAILCATEGORY,
      page: () => CategeorydetailView(),
      binding: CategoryBinding(),
    ),

    GetPage(
      name: _Paths.SHOPPRODUCTLISTVIEW,
      page: () => ShopView(),
      binding: ShopBinding(),
    ),

    GetPage(
      name: _Paths.WISHLIST,
      page: () => WishlistView(),
      binding: WishlistBinding(),
    ),

    // GetPage(
    //   name: _Paths.LOGIN,
    //   page: () => LoginView(),
    //   binding: LoginBinding(),
    // ),

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
    // GetPage(
    //   name: _Paths.REGISTER,
    //   page: () => const RegisterView(),
    //   binding: RegisterBinding(),
    // ),
    // GetPage(
    //   name: _Paths.HOME,
    //   page: () => Testinghome(),
    //   binding: HomepageBinding(),
    // ),

    GetPage(
      name: _Paths.BOTTOMBAR,
      page: () => BottombarView(),
      binding: BottombarBinding(),
    ),
    // GetPage(
    //   name: _Paths.CATEGORY,
    //   page: () => CategoryView(),
    //   binding: CategoryBinding(),
    // ),
    GetPage(
      name: _Paths.NOTIFICATION,
      page: () => NotificationsView(),
      binding: NotificationsBinding(),
    ),
    // GetPage(
    //   name: _Paths.BLOG,
    //   page: () => BlogView(),
    //   binding: BlogBinding(),
    // ),
    // GetPage(
    //   name: _Paths.BLOG_DETAILS,
    //   page: () => BlogDetailsView(),
    //   binding: BlogBinding(),
    // ),
    // GetPage(
    //   name: _Paths.CONTACT,
    //   page: () => ContactView(),
    //   binding: ContactBinding(),
    // ),
    // GetPage(
    //   name: _Paths.PROFILE,
    //   page: () => ProfileView(),
    //   binding: ProfileBinding(),
    // ),
    // GetPage(
    //   name: _Paths.DELETE_ACCOUNT,
    //   page: () => DeleteAccountView(),
    //   binding: DeleteAccountBinding(),
    // ),
    // GetPage(
    //   name: _Paths.ORDERS,
    //   page: () => OrdersView(),
    //   binding: OrdersBindi
  ];
}
