import 'package:zouhi/constants/constants.dart';

/// Values the parent site decides server-side and does not expose through the
/// API. Kept in one place so they are easy to swap for CMS-driven data.
class HomeConfig {
  /// Category tabs under "Special Offers" on vision.vbought.com/home. Order and
  /// labels follow the web page. (The offers rail itself is the 4 latest
  /// products from `GET products`, not category-driven.)
  static const specialOfferTabs = <({String id, String name})>[
    (id: '6a991c0cee3010dd62b873e4', name: 'Fibre Cable'),
    (id: '6a991188e9868dc79a02e27c', name: 'Fibre Optic Connectors and Adap'),
  ];

  /// Copy of the PicOS cards from the web template (the CMS only carries their
  /// images). Overridable through `card_N_title` / `card_N_text` if added later.
  static const picosCards = <({String title, String text})>[
    (
      title: 'PICOS SWITCH SOFTWARE',
      text:
          'Disaggregated NOS built on industry-standard Debian Linux seamlessly integrates into any network environment.'
    ),
    (
      title: 'AMPCON MANAGEMENT PLATFORM',
      text:
          'Deploy, orchestrate, and manage data center and campus networks at scale with automated workflows.'
    ),
    (
      title: 'PICOS-V VIRTUAL OPERATING',
      text:
          'Prototype network ops, validate configuration, and test features with PicOS-V to familiarize users with PicOS® software.'
    ),
    (
      title: 'SOFTWARE CUSTOMIZED',
      text:
          'Further software customization and enhancements to meet your exact requirements.'
    ),
  ];

  /// Resolves CMS media/links (`{{baseUrl}}/x`, `/images/x`, `https://…`) to an
  /// absolute URL; returns null for empty values and `#` placeholders.
  static String? resolveUrl(dynamic raw) {
    if (raw == null) return null;
    var v = raw.toString().trim();
    if (v.isEmpty || v == '#') return null;
    final base = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    v = v.replaceAll('{{baseUrl}}', base);
    if (v.startsWith('/')) v = '$base$v';
    if (!v.startsWith('http')) return null;
    return Uri.encodeFull(Uri.decodeFull(v));
  }
}
