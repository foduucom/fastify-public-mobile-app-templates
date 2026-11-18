import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/dynamic_theme.dart';
import 'web_theme_helper.dart';

class AppWebViewScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool cleanView;

  const AppWebViewScreen({
    Key? key,
    required this.title,
    required this.url,
    this.cleanView = true,
  }) : super(key: key);

  @override
  State<AppWebViewScreen> createState() => _AppWebViewScreenState();
}

class _AppWebViewScreenState extends State<AppWebViewScreen> {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;
  Timer? _webTimeoutTimer;
  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String? _lastAppliedCss;

  @override
  void initState() {
    super.initState();
    _initPullToRefresh();
    _initWebFallbackTimer();
  }

  @override
  void dispose() {
    _webTimeoutTimer?.cancel();
    super.dispose();
  }

  void _initWebFallbackTimer() {
    _webTimeoutTimer?.cancel();
    if (kIsWeb) {
      // Browsers often don't fire granular progress events for cross-origin iframes.
      // A fallback timer guarantees the loading overlay is dismissed so the iframe view displays.
      _webTimeoutTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
            _progress = 1.0;
          });
        }
      });
    } else {
      // WKWebView may stall without sending a progress, stop, or error callback.
      // End the spinner with a retryable error and leave a useful device log.
      _webTimeoutTimer = Timer(const Duration(seconds: 25), () {
        if (!mounted || !_isLoading) return;
        debugPrint(
          '[AppWebView] Load timed out after 25s. url=${widget.url}, '
          'progress=${(_progress * 100).round()}%',
        );
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage =
              'The page took too long to respond. Check your connection and try again.';
        });
      });
    }
  }

  void _initPullToRefresh() {
    if (!kIsWeb) {
      _pullToRefreshController = PullToRefreshController(
        settings: PullToRefreshSettings(
          color: Colors.blue,
        ),
        onRefresh: () async {
          _hasError = false;
          _isLoading = true;
          _progress = 0;
          _initWebFallbackTimer();
          setState(() {});
          if (_webViewController != null) {
            _webViewController!.reload();
          }
        },
      );
    }
  }

  String _cssColor(Color color) =>
      '#${(color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0')}';

  String _getInjectedCss({
    required AppThemeColors colors,
    required bool isDark,
  }) {
    final background = _cssColor(colors.background);
    final onBackground = _cssColor(colors.onBackground);
    final surface = _cssColor(colors.surface);
    final onSurface = _cssColor(colors.onSurface);
    final primary = _cssColor(colors.primary);
    final onPrimary = _cssColor(colors.onPrimary);
    final secondary = _cssColor(colors.secondary);
    final outline = _cssColor(colors.outline);
    final colorSchemeMode = isDark ? 'dark' : 'light';

    final cleanCss = widget.cleanView
        ? '''
      header,
      .aq-header-area,
      .aq-search-area,
      .progress-wrap,
      footer,
      .aq-footer-area,
      .aq-copyright-area,
      .foduu-auth-modal,
      .modal,
      .subscribe-popup {
        display: none !important;
      }
      body {
        padding-top: 16px !important;
        padding-bottom: 32px !important;
      }
    '''
        : '';

    return '''
      $cleanCss
      :root {
        color-scheme: $colorSchemeMode;
        --app-background: $background;
        --app-on-background: $onBackground;
        --app-surface: $surface;
        --app-on-surface: $onSurface;
        --app-primary: $primary;
        --app-on-primary: $onPrimary;
        --app-secondary: $secondary;
        --app-outline: $outline;
      }
      html, body {
        background-color: var(--app-background) !important;
        color: var(--app-on-background) !important;
      }
      body {
        color: var(--app-on-background) !important;
      }
      h1, h2, h3, h4, h5, h6, strong, b {
        color: var(--app-on-surface) !important;
      }
      p, span, li, label, small, td, th, blockquote {
        color: var(--app-on-background) !important;
      }
      a {
        color: var(--app-secondary) !important;
      }
      .custom-rp-box,
      .custom-rp-content,
      .custom-rp-bottom,
      .aq-contact-form-box,
      .aq-contact-info-item,
      .aq-contact-box,
      .card {
        background-color: var(--app-surface) !important;
        color: var(--app-on-surface) !important;
        border-color: var(--app-outline) !important;
        box-shadow: none !important;
      }
      .custom-rp-highlight {
        background-color: var(--app-surface) !important;
        border-left: 4px solid var(--app-primary) !important;
        color: var(--app-on-surface) !important;
      }
      input, textarea, select {
        background-color: var(--app-surface) !important;
        color: var(--app-on-surface) !important;
        border-color: var(--app-outline) !important;
      }
      input::placeholder, textarea::placeholder {
        color: var(--app-on-background) !important;
        opacity: 0.7;
      }
      button[type="submit"], .btn-primary, .aq-btn {
        background-color: var(--app-primary) !important;
        color: var(--app-on-primary) !important;
        border-color: var(--app-primary) !important;
      }
      hr {
        border-color: var(--app-outline) !important;
      }
    ''';
  }

  Future<void> _applyThemeStyling(
    AppThemeColors colors, {
    required bool isDark,
  }) async {
    // Avoid evaluating JS inside cross-origin iframes on web to prevent SecurityErrors
    if (kIsWeb || _webViewController == null) return;
    final controller = _webViewController!;
    final css = _getInjectedCss(
      colors: colors,
      isDark: isDark,
    );
    if (_lastAppliedCss == css) return;

    try {
      final js = '''
        (function() {
          var styleEl = document.getElementById('flutter-webview-theme-override');
          if (!styleEl) {
            styleEl = document.createElement('style');
            styleEl.id = 'flutter-webview-theme-override';
            (document.head || document.documentElement).appendChild(styleEl);
          }
          styleEl.textContent = ${jsonEncode(css)};
        })();
      ''';
      await controller.evaluateJavascript(source: js);
      _lastAppliedCss = css;
    } catch (e) {
      debugPrint('WebView theme styling ignored: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final appColors = DynamicThemeManager().getColors(colorScheme.brightness);

    // Reactively update styling
    if (kIsWeb) {
      setWebThemeMode(isDark);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applyThemeStyling(appColors, isDark: isDark);
      });
    }

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          backgroundColor: colorScheme.surface,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon:
                  Icon(Icons.open_in_new_rounded, color: colorScheme.onSurface),
              tooltip: 'Open in browser',
              onPressed: () async {
                final uri = Uri.tryParse(widget.url);
                if (uri != null) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
              tooltip: 'Reload',
              onPressed: () {
                _hasError = false;
                _isLoading = true;
                _progress = 0;
                setState(() {});
                _initWebFallbackTimer();
                _webViewController?.reload();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_progress < 1.0 && !_hasError)
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                minHeight: 2.5,
              ),
            Expanded(
              child: Stack(
                children: [
                  _buildWebView(appColors, isDark),
                  if (_isLoading && !_hasError)
                    Container(
                      color: colorScheme.surface,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading ${widget.title}...',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_hasError)
                    Container(
                      color: colorScheme.surface,
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Unable to load page',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage.isNotEmpty
                                  ? _errorMessage
                                  : 'Please check your internet connection.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _hasError = false;
                                  _isLoading = true;
                                  _progress = 0;
                                });
                                _initWebFallbackTimer();
                                _webViewController?.reload();
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(AppThemeColors appColors, bool isDark) {
    Widget webView = InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: InAppWebViewSettings(
        isInspectable: kDebugMode,
        javaScriptEnabled: true,
        // No URL interception is needed here. Enabling it without a navigation
        // callback can leave WKWebView waiting on a policy decision on iOS.
        useShouldOverrideUrlLoading: false,
        mediaPlaybackRequiresUserGesture: true,
        allowsInlineMediaPlayback: true,
        transparentBackground: true,
        forceDark: (!kIsWeb && isDark) ? ForceDark.ON : ForceDark.OFF,
        forceDarkStrategy: ForceDarkStrategy.USER_AGENT_DARKENING_ONLY,
        algorithmicDarkeningAllowed: !kIsWeb,
        supportZoom: true,
        builtInZoomControls: false,
        displayZoomControls: false,
        cacheMode: CacheMode.LOAD_DEFAULT,
        clearCache: false,
        iframeAllow: "fullscreen; camera; microphone",
        iframeAllowFullscreen: true,
      ),
      pullToRefreshController: _pullToRefreshController,
      onWebViewCreated: (controller) {
        _webViewController = controller;
      },
      onLoadStart: (controller, url) {
        debugPrint('[AppWebView] Load started: $url');
        _initWebFallbackTimer();
        _lastAppliedCss = null;
        setState(() {
          _hasError = false;
          _isLoading = true;
          _progress = 0;
        });
      },
      onProgressChanged: (controller, progress) {
        if (!kIsWeb) {
          debugPrint(
              '[AppWebView] Load progress: $progress% url=${widget.url}');
        }
        setState(() {
          _progress = progress / 100.0;
          if (progress >= 70) {
            _isLoading = false;
          }
        });
        if (progress == 100) {
          _webTimeoutTimer?.cancel();
          _pullToRefreshController?.endRefreshing();
        }
      },
      onLoadStop: (controller, url) async {
        debugPrint('[AppWebView] Load stopped: $url');
        _webTimeoutTimer?.cancel();
        _pullToRefreshController?.endRefreshing();
        if (kIsWeb) {
          setWebThemeMode(isDark);
        } else {
          await _applyThemeStyling(appColors, isDark: isDark);
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
            _progress = 1.0;
          });
        }
      },
      onReceivedError: (controller, request, error) {
        debugPrint(
          '[AppWebView] Load error: url=${request.url}, '
          'mainFrame=${request.isForMainFrame}, type=${error.type}, '
          'description=${error.description}',
        );
        _webTimeoutTimer?.cancel();
        _pullToRefreshController?.endRefreshing();
        if ((request.isForMainFrame ?? true) && mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = error.description;
          });
        }
      },
      onReceivedHttpError: (controller, request, errorResponse) {
        debugPrint(
          '[AppWebView] HTTP error: url=${request.url}, '
          'status=${errorResponse.statusCode}, '
          'reason=${errorResponse.reasonPhrase}, '
          'mainFrame=${request.isForMainFrame}',
        );
        if (request.isForMainFrame ?? true) {
          _webTimeoutTimer?.cancel();
          _pullToRefreshController?.endRefreshing();
          if (!mounted) return;
          setState(() {
            _hasError = true;
            _isLoading = false;
            _errorMessage = errorResponse.reasonPhrase?.isNotEmpty == true
                ? 'Server returned HTTP ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}'
                : 'Server returned HTTP ${errorResponse.statusCode ?? 'error'}.';
          });
        }
      },
    );

    if (kIsWeb && widget.cleanView) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: constraints.maxHeight + 70,
              maxHeight: constraints.maxHeight + 70,
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
              child: Transform.translate(
                offset: const Offset(0, -70),
                child: webView,
              ),
            ),
          );
        },
      );
    }

    return webView;
  }
}
