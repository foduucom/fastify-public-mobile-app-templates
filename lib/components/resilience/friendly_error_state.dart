import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/resilience_strings.dart';
import 'package:foduu_ecommerce/services/api_health_service.dart';
import 'package:get/get.dart';

/// Calm, reassuring full-area state shown when a screen has nothing cached to
/// display and the server is still unreachable. Never shows technical text.
class FriendlyErrorState extends StatelessWidget {
  /// Called by "Try now". Defaults to probing the backend.
  final Future<void> Function()? onRetry;
  const FriendlyErrorState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final health = ApiHealthService.maybe;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Obx(() {
          final offline = health?.isOffline.value ?? false;
          final secs = health?.secondsToRetry.value ?? 0;
          final unhealthy = health?.isUnhealthy ?? false;
          final title = offline
              ? ResilienceStrings.offlineTitle
              : unhealthy
                  ? ResilienceStrings.downTitle
                  : ResilienceStrings.almostThereTitle;
          final body = offline
              ? ResilienceStrings.offlineBody
              : ResilienceStrings.downBody;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(offline ? Icons.wifi_off_rounded : Icons.cloud_sync_outlined,
                  size: 72, color: scheme.primary),
              const SizedBox(height: 20),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(body,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.65))),
              const SizedBox(height: 20),
              if (unhealthy)
                Text(
                  secs > 0
                      ? ResilienceStrings.retryingIn(secs)
                      : ResilienceStrings.retrying,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => (onRetry ?? health?.retryNow)?.call(),
                icon: const Icon(Icons.refresh),
                label: const Text(ResilienceStrings.tryNow),
              ),
            ],
          );
        }),
      ),
    );
  }
}
