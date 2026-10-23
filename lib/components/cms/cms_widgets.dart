import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';

/// Resolves a CMS image path (relative or absolute) to a full URL.
String cmsImageUrl(String path) {
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return path.startsWith('/') ? '$url${path.substring(1)}' : '$url$path';
}

/// Maps a website icon-font HTML snippet (e.g. `<i class="w-icon-headphone">`)
/// to a Material icon. The HTML is only inspected, never rendered.
IconData iconFromHtml(String html, {IconData fallback = Icons.info_outline}) {
  final match = RegExp(r'class\s*=\s*"([^"]*)"').firstMatch(html);
  final cls = (match?.group(1) ?? html).toLowerCase();
  if (cls.contains('envelop') || cls.contains('mail')) {
    return Icons.email_outlined;
  }
  if (cls.contains('phone') || cls.contains('headphone')) {
    return Icons.headset_mic_outlined;
  }
  if (cls.contains('map') || cls.contains('location') || cls.contains('pin')) {
    return Icons.location_on_outlined;
  }
  return fallback;
}

class CmsSpacer extends StatelessWidget {
  const CmsSpacer(this.height, {super.key});
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(height: height);
}

/// Hero banner with image, dark overlay and HOME > TITLE breadcrumb.
class CmsPageHeader extends StatelessWidget {
  const CmsPageHeader({
    super.key,
    required this.title,
    required this.imagePath,
    this.breadcrumb,
  });

  final String title;
  final String imagePath;
  final String? breadcrumb;

  @override
  Widget build(BuildContext context) {
    final image = cmsImageUrl(imagePath);
    return Semantics(
      header: true,
      label: title,
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: const Color(0xFF12253D),
          image: image.isEmpty
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    const Color(0xFF0A192D).withOpacity(0.78),
                    BlendMode.darken,
                  ),
                ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('HOME',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                        color: Colors.white.withOpacity(0.7))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 14, color: Colors.white.withOpacity(0.5)),
                ),
                Flexible(
                  child: Text((breadcrumb ?? title).toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    letterSpacing: -0.3)),
          ],
        ),
      ),
    );
  }
}
