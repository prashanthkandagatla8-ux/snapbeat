import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _isVideoReady = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    // 1. Overall safety timer: Never hold the user longer than 10.5 seconds
    _safetyTimer = Timer(const Duration(milliseconds: 10500), () {
      _navigateToHome();
    });

    // 2. Attempt video initialization with a strict 1500ms timeout for low-end phones
    try {
      final controller = VideoPlayerController.asset('assets/videos/splash_screen.mp4');
      _controller = controller;

      // Timeout after 1500ms if low-end GPU/RAM cannot initialize video decoder fast enough
      await controller.initialize().timeout(const Duration(milliseconds: 1500));

      if (!mounted) return;

      if (controller.value.hasError) {
        throw Exception('Video controller reported an error');
      }

      setState(() {
        _isVideoReady = true;
      });

      controller.addListener(_videoListener);
      await controller.play();
    } catch (e) {
      debugPrint('Low-end device or video playback error ($e). Falling back to static image splash.');
      if (!mounted) return;

      setState(() {
        _isVideoReady = false;
      });

      try {
        _controller?.dispose();
        _controller = null;
      } catch (_) {}

      // On low-end phones, display the static branded splash image for 2.5 seconds total
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) _navigateToHome();
      });
    }
  }

  void _videoListener() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _hasNavigated) return;

    if (controller.value.hasError) {
      _navigateToHome();
      return;
    }

    final pos = controller.value.position;
    final dur = controller.value.duration;

    if (dur > Duration.zero && pos >= (dur - const Duration(milliseconds: 200))) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

    try {
      _controller?.removeListener(_videoListener);
      _controller?.pause();
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    try {
      _controller?.removeListener(_videoListener);
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0F),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToHome, // Tap anywhere to skip
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base layer: Always render the static high-res poster immediately!
            // Guarantees instant visual display on low-end devices with 0 blank frames.
            Image.asset(
              'assets/images/splash_poster.webp',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFC8A232),
                  strokeWidth: 2,
                ),
              ),
            ),

            // Video overlay layer (only displayed once decoder is primed and playing)
            if (_isVideoReady && _controller != null && _controller!.value.isInitialized)
              Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
              ),

            // Top overlay: Skip button
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: GestureDetector(
                    onTap: _navigateToHome,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFC8A232).withValues(alpha: 0.45),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "SKIP",
                            style: TextStyle(
                              color: Color(0xFFFAF6EE),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.fast_forward_rounded,
                            size: 14,
                            color: Color(0xFFC8A232),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
