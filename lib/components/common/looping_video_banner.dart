import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';

/// An industry-standard, hardware-accelerated video banner widget designed
/// for mobile e-commerce storefronts.
///
/// Features:
/// - Muted auto-play by default conforming to mobile app store best practices.
/// - Seamless infinite looping without stutter.
/// - Aspect-ratio preserving [BoxFit.cover] via [FittedBox].
/// - Shimmer buffering state to prevent black screen flickers.
/// - Subtle luxury sound toggle pill (muted/unmuted).
/// - Safe lifecycle management and memory cleanup.
class LoopingVideoBanner extends StatefulWidget {
  final String videoUrl;
  final double? height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final bool autoPlay;
  final bool looping;
  final bool initialMuted;
  final bool showSoundToggle;
  final VoidCallback? onTap;

  const LoopingVideoBanner({
    super.key,
    required this.videoUrl,
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
    this.autoPlay = true,
    this.looping = true,
    this.initialMuted = true,
    this.showSoundToggle = true,
    this.onTap,
  });

  @override
  State<LoopingVideoBanner> createState() => _LoopingVideoBannerState();
}

class _LoopingVideoBannerState extends State<LoopingVideoBanner> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.initialMuted;
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant LoopingVideoBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposePlayer();
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    final rawUrl = widget.videoUrl.trim();
    if (rawUrl.isEmpty) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.hasScheme) {
      dev.log('[LoopingVideoBanner] Invalid video URI: $rawUrl');
      if (mounted) setState(() => _hasError = true);
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(uri);
      _controller = controller;

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.setLooping(widget.looping);
      await controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (widget.autoPlay) {
        await controller.play();
      }

      setState(() {
        _isInitialized = true;
        _hasError = false;
      });
    } catch (e, stack) {
      dev.log('[LoopingVideoBanner] Error initializing video player: $e',
          error: e, stackTrace: stack);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  void _toggleSound() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
    });
    _controller!.setVolume(_isMuted ? 0.0 : 1.0);
  }

  void _disposePlayer() {
    try {
      _controller?.pause();
      _controller?.dispose();
    } catch (_) {}
    _controller = null;
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        height: widget.height,
        width: widget.width ?? double.infinity,
        color: const Color(0xFF141416),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized || _controller == null) {
      return _buildShimmerPlaceholder();
    }

    final videoSize = _controller!.value.size;
    final hasValidSize = videoSize.width > 0 && videoSize.height > 0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Responsive edge-to-edge video render
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: hasValidSize
              ? FittedBox(
                  fit: widget.fit,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: videoSize.width,
                    height: videoSize.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio > 0
                        ? _controller!.value.aspectRatio
                        : 16 / 9,
                    child: VideoPlayer(_controller!),
                  ),
                ),
        ),

        // Bottom subtle gradient overlay for contrast with UI controls
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 60,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Luxury Sound Toggle Pill
        if (widget.showSoundToggle)
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleSound,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isMuted ? 'Muted' : 'Sound',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E22),
      highlightColor: const Color(0xFF2C2C34),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E22),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white38,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: const Color(0xFF16161A),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Unable to load video banner',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
