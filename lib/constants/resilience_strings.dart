/// All user-facing copy for server-hiccup / offline states lives here so the
/// tone stays consistent across screens.
class ResilienceStrings {
  ResilienceStrings._();

  static const unavailableMessage =
      "We're making things better for you. This only takes a moment.";
  static const bannerReconnecting = 'Reconnecting… showing your saved items';
  static const bannerReconnectingNoCache = 'Reconnecting…';
  static const bannerOffline = "You're offline. Showing your saved items";
  static const bannerRecovered = "You're back online";
  static const almostThereTitle = 'Almost there';
  static const downTitle = 'Taking longer than usual';
  static const downBody =
      'Our store is getting a quick update. Your saved items are safe.';
  static const offlineTitle = "You're offline";
  static const offlineBody =
      'Check your internet connection and we will pick up right where you left off.';
  static const tryNow = 'Try now';
  static const tryAgain = 'Try again';
  static String retryingIn(int s) => 'Trying again in ${s}s';
  static const retrying = 'Trying again…';
  static const writeFailed = "Couldn't save that right now. Please try again.";
  static const checkoutFailed =
      "Don't worry, you haven't been charged. Please try again in a moment.";
}
