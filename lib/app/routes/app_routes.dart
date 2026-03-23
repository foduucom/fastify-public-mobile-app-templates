part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH      = _Paths.SPLASH;
  static const ONBOARDING  = _Paths.ONBOARDING;
  static const BOTTOMBAR = _Paths.BOTTOMBAR;
// In _Paths class
  static const CREATE_ACCOUNT = '/create-account';
  static const OTP = _Paths.OTP;

  static const INTRO = _Paths.INTRO;
  // static const LOGIN = _Paths.LOGIN;
  static const PROFILE = _Paths.PROFILE;


  static const REGISTER = _Paths.REGISTER;
  static const RESETPASSWORD = _Paths.RESETPASSWORD;
  static const FORGETPASSWORD = _Paths.FOREGETPASSWORD;

  static const MOBILELOGIN = _Paths.MOBILELOGIN;
  static const MOBILELOGINOTP = _Paths.MOBILELOGINOTP;
  static const MOBILEREGISTER = _Paths.MOBILEREGISTER;

  // static const BOTTOMBAR = _Paths.BOTTOMBAR;
  static const HOME = _Paths.HOME;

  static const CATEGORY = _Paths.CATEGORY;
  static const DETAILCATEGORY = _Paths.DETAILCATEGORY;
  static const SHOPPRODUCTLISTVIEW = _Paths.SHOPPRODUCTLISTVIEW;
  static const WISHLIST = _Paths.WISHLIST;
  static const SEARCH = _Paths.SEARCH;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const CONTACT = _Paths.CONTACT;
  static const DELETE_ACCOUNT = _Paths.DELETE_ACCOUNT;
  static const ORDERS = _Paths.ORDERS;
  static const ORDER_DETAILS = _Paths.ORDER_DETAILS;
  static const ORDER_PRODUCTS = _Paths.ORDER_PRODUCTS;
  static const BLOG = _Paths.BLOG;

  static const CART = _Paths.CART;
  static const PAYMENT = _Paths.CART + _Paths.PAYMENT;
  static const CHECKOUT = _Paths.CART + _Paths.CHECKOUT;

}

abstract class _Paths {
  _Paths._();
  static const SPLASH     = '/splash';
  static const ONBOARDING = '/onboarding';
  static const INTRO = '/intro';
  static const CREATE_ACCOUNT = '/create-account';
  static const OTP = '/otp';
  static const FOREGETPASSWORD = '/forgetpassword';
  static const RESETPASSWORD = '/resetpassword';
  static const REGISTER = '/register';
  static const BOTTOMBAR = '/bottombar';
  static const MOBILELOGIN = '/mobilelogin';
  static const MOBILELOGINOTP = '/mobileloginotp';
  static const MOBILEREGISTER = '/mobileregister';
  static const CONTACT = '/contact';
  static const DELETE_ACCOUNT = '/DELETE_ACCOUNT';
  static const ORDERS = '/orders';
  static const ORDER_DETAILS = '/order_detail';
  static const ORDER_PRODUCTS = '/order_products';
  static const AI           = '/ai';
  static const HOME = '/home';
  static const PROFILE = '/profile';
  static const CATEGORY = '/category';
  static const DETAILCATEGORY = '/detailcategory';
  static const SHOPPRODUCTLISTVIEW = '/productlistview';
  static const PRODUCTDETAILS = '/productdetails';
  static const NOTIFICATION = '/notification';
  static const BLOG = '/blog';

  static const WISHLIST = '/wishlist';
  static const CART = '/cart';
  static const SEARCH = '/search';
  static const PAYMENT = '/payment';
  static const CHECKOUT = '/checkout';


}
