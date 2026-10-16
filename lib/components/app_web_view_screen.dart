import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

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
  double _progress = 0;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initPullToRefresh();
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
          setState(() {});
          if (_webViewController != null) {
            _webViewController!.reload();
          }
        },
      );
    }
  }

  String _getInjectedCss({required bool isDark}) {
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
      body,
      .custom-rp-area,
      .aq-contact-area,
      .aq-blog-inner-area,
      .aq-about-me-area {
        padding-top: 16px !important;
        padding-bottom: 32px !important;
      }
    '''
        : '';

    if (isDark) {
      return '''
        $cleanCss
        html, body {
          background-color: #121212 !important;
          color: #e2e8f0 !important;
        }
        .custom-rp-area,
        .custom-rp-container,
        .custom-rp-row,
        .custom-rp-col,
        .custom-rp-box,
        .custom-rp-content,
        .custom-rp-bottom,
        .aq-contact-area,
        .aq-contact-wrap,
        .aq-contact-form-box,
        .aq-contact-info-item,
        .aq-blog-inner-area,
        .aq-blog-inner-top,
        .aq-about-me-area,
        .aq-about-info-item,
        .container,
        .row,
        .col,
        .card,
        section,
        div {
          background-color: transparent !important;
          color: #e2e8f0 !important;
        }
        .custom-rp-box,
        .aq-contact-form-box,
        .aq-contact-info-item,
        .card,
        .aq-contact-box {
          background-color: #1e1e1e !important;
          border: 1px solid #2d3748 !important;
          box-shadow: none !important;
        }
        .custom-rp-highlight {
          background-color: #27200d !important;
          border-left: 4px solid #f59e0b !important;
          color: #fef3c7 !important;
        }
        h1, h2, h3, h4, h5, h6, strong, b {
          color: #f8fafc !important;
        }
        p, span, li, label, td, th {
          color: #cbd5e1 !important;
        }
        a {
          color: #60a5fa !important;
        }
        input, textarea, select {
          background-color: #242424 !important;
          color: #ffffff !important;
          border: 1px solid #4a5568 !important;
        }
        input::placeholder, textarea::placeholder {
          color: #718096 !important;
        }
        button[type="submit"], .btn-primary, .aq-btn {
          background-color: #3b82f6 !important;
          color: #ffffff !important;
          border: none !important;
        }
      ''';
    } else {
      return '''
        $cleanCss
        html, body {
          background-color: #ffffff !important;
          color: #1a202c !important;
        }
        .custom-rp-box,
        .aq-contact-form-box,
        .aq-contact-info-item {
          background-color: #ffffff !important;
        }
      ''';
    }
  }

  void _applyThemeStyling(bool isDark) {
    if (_webViewController == null) return;
    final css = _getInjectedCss(isDark: isDark);
    final escapedCss = css.replaceAll('\n', ' ').replaceAll('"', '\\"');
    final js = '''
      (function() {
        var styleEl = document.getElementById('flutter-webview-theme-override');
        if (!styleEl) {
          styleEl = document.createElement('style');
          styleEl.id = 'flutter-webview-theme-override';
          document.head.appendChild(styleEl);
        }
        styleEl.innerHTML = "$escapedCss";
      })();
    ''';
    _webViewController!.evaluateJavascript(source: js);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark || Get.isDarkMode;
    final colorScheme = theme.colorScheme;

    // Reactively update styling if theme changes
    _applyThemeStyling(isDark);

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
              // Immediately navigate back to the previous screen (e.g. Profile in BottombarView)
              Get.back();
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
              tooltip: 'Reload',
              onPressed: () {
                _hasError = false;
                _isLoading = true;
                setState(() {});
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
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    initialSettings: InAppWebViewSettings(
                      isInspectable: kDebugMode,
                      javaScriptEnabled: true,
                      useShouldOverrideUrlLoading: true,
                      mediaPlaybackRequiresUserGesture: true,
                      allowsInlineMediaPlayback: true,
                      transparentBackground: true,
                      forceDark: isDark ? ForceDark.ON : ForceDark.OFF,
                      forceDarkStrategy:
                          ForceDarkStrategy.USER_AGENT_DARKENING_ONLY,
                      algorithmicDarkeningAllowed: true,
                      supportZoom: true,
                      builtInZoomControls: false,
                      displayZoomControls: false,
                      cacheMode: CacheMode.LOAD_DEFAULT,
                      clearCache: false,
                    ),
                    pullToRefreshController: _pullToRefreshController,
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (controller, url) {
                      setState(() {
                        _hasError = false;
                      });
                      _applyThemeStyling(isDark);
                    },
                    onProgressChanged: (controller, progress) {
                      setState(() {
                        _progress = progress / 100.0;
                        if (progress >= 70) {
                          _isLoading = false;
                        }
                      });
                      if (progress > 30) {
                        _applyThemeStyling(isDark);
                      }
                      if (progress == 100) {
                        _pullToRefreshController?.endRefreshing();
                      }
                    },
                    onLoadStop: (controller, url) async {
                      _pullToRefreshController?.endRefreshing();
                      _applyThemeStyling(isDark);
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    onReceivedError: (controller, request, error) {
                      _pullToRefreshController?.endRefreshing();
                      if (request.isForMainFrame ?? true) {
                        setState(() {
                          _hasError = true;
                          _isLoading = false;
                          _errorMessage = error.description;
                        });
                      }
                    },
                  ),
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
}
