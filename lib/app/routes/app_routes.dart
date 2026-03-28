part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const INTRO = _Paths.INTRO;
  static const LOGIN = _Paths.LOGIN;
  static const PROFILE = _Paths.PROFILE;
  static const OTP = _Paths.OTP;
  static const EMAIL_OTP = _Paths.EMAIL_OTP;

  static const REGISTER = _Paths.REGISTER;
  static const RESETPASSWORD = _Paths.RESETPASSWORD;
  static const FORGETPASSWORD = _Paths.FOREGETPASSWORD;

  static const MOBILELOGIN = _Paths.MOBILELOGIN;
  static const MOBILELOGINOTP = _Paths.MOBILELOGINOTP;
  static const MOBILEREGISTER = _Paths.MOBILEREGISTER;

  static const BOTTOMBAR = _Paths.BOTTOMBAR;
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
  static const ADD_UPDATE_ADDRESS = _Paths.ADD_UPDATE_ADDRESS;
  static const DELIVERYADDRESS = _Paths.CART + _Paths.DELIVERYADDRESS;
  static const MANAGEADDRESS = _Paths.MANAGEADDRESS;
  static const ADDRESS_LIST = _Paths.ADDRESS_LIST;
  static const ADDRESS_LIST1 = _Paths.ADDRESS_LIST1;
  static const ADDRESS_ADD = _Paths.ADDRESS_ADD;
  static const ADDRESS_FORM = _Paths.ADDRESS_FORM;
  static const ORDERSUCCESS = _Paths.CART + _Paths.ORDERSUCCESS;

  static const ABOUTUS = _Paths.ABOUTUS;
  static const HELPANDSUPPORT = _Paths.HELPANDSUPPORT;
  static const TERMSANDCONDITION = _Paths.TERMSANDCONDITION;
  static const PHONEPAY = _Paths.PHONEPAY;
  static const PRODUCTDETAILS = _Paths.PRODUCTDETAILS;
  static const BLOG_DETAILS = _Paths.BLOG_DETAILS;
  static const CUSTOMPAGE = _Paths.CUSTOMPAGE;
  static const CONTACTUS = _Paths.CONTACTUS;
  static const PRIVACY_POLICY = _Paths.PRIVACY_POLICY;
  static const TERMS_CONDITIONS = _Paths.TERMS_CONDITIONS;

}

abstract class _Paths {
  _Paths._();
  static const INTRO = '/intro';
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const FOREGETPASSWORD = '/forgetpassword';
  static const RESETPASSWORD = '/resetpassword';
  static const REGISTER = '/register';
  static const MOBILELOGIN = '/mobilelogin';
  static const MOBILELOGINOTP = '/mobileloginotp';
  static const MOBILEREGISTER = '/mobileregister';
  static const CONTACT = '/contact';
  static const DELETE_ACCOUNT = '/DELETE_ACCOUNT';
  static const ORDERS = '/orders';
  static const ORDER_DETAILS = '/order_detail';
  static const ORDER_PRODUCTS = '/order_products';

  static const HOME = '/home';
  static const BOTTOMBAR = '/bottombar';
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

  static const ADD_UPDATE_ADDRESS = '/addupdateaddress';
  static const DELIVERYADDRESS = '/deliveryaddress';
  static const MANAGEADDRESS = '/manageaddress';
  static const ADDRESS_LIST = '/address-list';
  static const ADDRESS_LIST1 = '/address-list1';
  static const ADDRESS_ADD = '/address-add';
  static const ADDRESS_FORM = '/address-form';
  static const ORDERSUCCESS = '/ordersuccess';

  static const ABOUTUS = '/aboutus';
  static const HELPANDSUPPORT = '/helpandsupport';
  static const TERMSANDCONDITION = '/termsandcondition';

  static const PHONEPAY = '/phonepay';
  static const EMAIL_OTP = '/emailotp';
  static const BLOG_DETAILS = '/blog_details';
  static const CUSTOMPAGE = '/custompage';
  static const CONTACTUS = '/contactus';
  static const PRIVACY_POLICY = '/privacy_policy';
  static const TERMS_CONDITIONS = '/terms_condition';


}
