import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    // Complete fullscreen immersive mode (no status bar, no navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initAndPlayVideo();
  }

  Future<void> _initAndPlayVideo() async {
    // Master safety timeout
    _safetyTimer = Timer(const Duration(seconds: 11), _navigateToHome);

    try {
      final controller = VideoPlayerController.asset('assets/videos/splash_screen.mp4');
      _controller = controller;
      await controller.initialize();
      await controller.setVolume(1.0);
      controller.addListener(_videoListener);

      if (!mounted) return;
      setState(() => _isReady = true);
      await controller.play();
    } catch (e) {
      debugPrint('Video splash error: $e');
      _navigateToHome();
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
    if (dur > Duration.zero && pos >= (dur - const Duration(milliseconds: 150))) {
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

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _navigateToHome,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: _isReady && _controller != null && _controller!.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}
