import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/resilience_strings.dart';
import 'package:foduu_ecommerce/services/api_health_service.dart';
import 'package:get/get.dart';

/// Wraps the whole app (via `GetMaterialApp.builder`) and shows a slim status
/// strip above the current page while the backend is unreachable.
class ResilienceShell extends StatelessWidget {
  final Widget child;
  const ResilienceShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final health = ApiHealthService.maybe;
    if (health == null) return child;

    return Column(
      children: [
        Obx(() => _Banner(health: health)),
        Expanded(
          child: Obx(() {
            // The banner already consumed the status-bar inset.
            final bannerVisible = _bannerText(health) != null;
            return MediaQuery.removePadding(
              context: context,
              removeTop: bannerVisible,
              child: child,
            );
          }),
        ),
      ],
    );
  }
}

String? _bannerText(ApiHealthService h) {
  if (h.showRecovered.value) return ResilienceStrings.bannerRecovered;
  if (!h.isUnhealthy) return null;
  if (h.isOffline.value) return ResilienceStrings.bannerOffline;
  return h.servingStale.value
      ? ResilienceStrings.bannerReconnecting
      : ResilienceStrings.bannerReconnectingNoCache;
}

class _Banner extends StatelessWidget {
  final ApiHealthService health;
  const _Banner({required this.health});

  @override
  Widget build(BuildContext context) {
    final text = _bannerText(health);
    final recovered = health.showRecovered.value;
    final scheme = Theme.of(context).colorScheme;
    final bg = recovered ? Colors.green.shade600 : scheme.inverseSurface;
    final fg = recovered ? Colors.white : scheme.onInverseSurface;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedSize(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: text == null
          ? const SizedBox(width: double.infinity)
          : Semantics(
              liveRegion: true,
              label: text,
              child: Material(
                color: bg,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (recovered)
                          Icon(Icons.check_circle_outline, size: 16, color: fg)
                        else
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: fg),
                          ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            text,
                            style: TextStyle(
                                color: fg,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
