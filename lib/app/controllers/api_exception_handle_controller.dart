import 'package:zouhi/app/data/services/session_service.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get_storage/get_storage.dart';

mixin BaseController {
  var getbox = GetStorage();

  Future<void> handleError(error) async {
    if (error is UnAuthorizedException) {
      await SessionService.expire(message: error.message);
      return;
    }
    HelperFunctions().showSnackBarError(errorMessageOf(error));
  }

  // showLoading([String? message]) {
  //   DialogHelper.showLoading(message);
  // }

  // hideLoading() {
  //   DialogHelper.hideLoading();
  // }
}


// {
//   "project_info": {
//     "project_number": "747304370191",
//     "project_id": "khedutsathi-b552c",
//     "storage_bucket": "khedutsathi-b552c.appspot.com"
//   },
//   "client": [
//     {
//       "client_info": {
//         "mobilesdk_app_id": "1:747304370191:android:245ac1a11fd3efbfba637a",
//         "android_client_info": {
//           "package_name": "com.protuff.protuffnutri"
//         }
//       },
//       "oauth_client": [],
//       "api_key": [
//         {
//           "current_key": "YOUR_FIREBASE_API_KEY"
//         }
//       ],
//       "services": {
//         "appinvite_service": {
//           "other_platform_oauth_client": []
//         }
//       }
//     },
//     {
//       "client_info": {
//         "mobilesdk_app_id": "1:747304370191:android:4b880000f2622693ba637a",
//         "android_client_info": {
//           "package_name": "com.foduu.khedutsathi"
//         }
//       },
//       "oauth_client": [],
//       "api_key": [
//         {
//           "current_key": "YOUR_FIREBASE_API_KEY"
//         }
//       ],
//       "services": {
//         "appinvite_service": {
//           "other_platform_oauth_client": []
//         }
//       }
//     },
//     {
//       "client_info": {
//         "mobilesdk_app_id": "1:747304370191:android:b0701b7609ce877bba637a",
//         "android_client_info": {
//           "package_name": "com.foduu.khedutsathi_app"
//         }
//       },
//       "oauth_client": [],
//       "api_key": [
//         {
//           "current_key": "YOUR_FIREBASE_API_KEY"
//         }
//       ],
//       "services": {
//         "appinvite_service": {
//           "other_platform_oauth_client": []
//         }
//       }
//     }
//   ],
//   "configuration_version": "1"
// }