import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sample_reel_showcase_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool autoNavigate;
  static ui.Image? splashUiImage;
  const SplashScreen({super.key, this.autoNavigate = true});

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
    if (widget.autoNavigate) {
      _safetyTimer = Timer(const Duration(seconds: 11), _navigateToHome);
    }

    try {
      const splashAsset = 'assets/videos/splash_screen_ios.mp4';
      final controller = VideoPlayerController.asset(splashAsset);
      _controller = controller;
      await controller.initialize();
      if (_hasNavigated || !mounted) {
        _controller?.dispose();
        return;
      }
      await controller.setVolume(1.0);
      controller.addListener(_videoListener);

      if (!mounted) return;
      setState(() => _isReady = true);
      await controller.play();
    } catch (e) {
      debugPrint('Video splash error: $e');
      if (widget.autoNavigate) {
        _navigateToHome();
      }
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

  Future<void> _navigateToHome() async {
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
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    final skipDemo = prefs.getBool('snapbeat_skip_showcase_demo') ?? false;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) =>
            skipDemo ? const HomeScreen(fromShowcase: false) : const SampleReelShowcaseScreen(),
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (SplashScreen.splashUiImage != null)
                RawImage(
                  image: SplashScreen.splashUiImage,
                  fit: BoxFit.cover,
                )
              else
                Image.asset(
                  'assets/images/splash_screen_ios.jpg',
                  fit: BoxFit.cover,
                ),
              if (_isReady && _controller != null && _controller!.value.isInitialized)
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller!.value.size.width,
                    height: _controller!.value.size.height,
                    child: VideoPlayer(_controller!),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
