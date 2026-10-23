import 'package:get_storage/get_storage.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/home_cms.dart';

class HomeCmsService {
  static const _cacheKey = 'home_cms_content';
  final GetStorage _box = GetStorage();

  /// Last good layout (just the `content` string, a few KB) for instant paint.
  HomeCms? cached() {
    final raw = _box.read(_cacheKey);
    return raw == null ? null : HomeCms.fromContent(raw);
  }

  /// Fresh layout, or null when the request failed.
  Future<HomeCms?> fetch() async {
    final page = await BasicProvider('pages/home').getRequest();
    if (page is! Map || page['content'] == null) return null;
    final content = page['content'];
    _box.write(_cacheKey, content is String ? content : null);
    return HomeCms.fromPage(page);
  }
}
