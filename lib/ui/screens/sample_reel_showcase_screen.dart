import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import 'home_screen.dart';

class SampleReelShowcaseScreen extends StatefulWidget {
  const SampleReelShowcaseScreen({super.key});

  @override
  State<SampleReelShowcaseScreen> createState() => _SampleReelShowcaseScreenState();
}

class _SampleReelShowcaseScreenState extends State<SampleReelShowcaseScreen> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasNavigated = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _safetyTimer = Timer(const Duration(seconds: 20), () {
      _navigateToHome();
    });
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset('assets/videos/showcase_reel.mp4');
      _controller = controller;
      await controller.initialize();
      if (_hasNavigated || !mounted) {
        _controller?.dispose();
        return;
      }
      await controller.setLooping(false);
      await controller.setVolume(1.0);
      controller.addListener(_videoListener);
      if (!mounted) return;
      setState(() => _isReady = true);
      await controller.play();
    } catch (e) {
      debugPrint('Showcase video error: $e');
      _navigateToHome();
    }
  }

  void _videoListener() {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _hasNavigated) return;
    if (c.value.hasError) {
      _navigateToHome();
      return;
    }
    final pos = c.value.position;
    final dur = c.value.duration;
    if (dur > Duration.zero && pos >= (dur - const Duration(milliseconds: 300))) {
      _navigateToHome();
    }
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }


  void _navigateToHome({bool fromShowcase = true}) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _safetyTimer?.cancel();

    try {
      _controller?.removeListener(_videoListener);
      _controller?.pause();
    } catch (_) {}

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(fromShowcase: fromShowcase),
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
      _controller?.pause();
      _controller?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isPlaying = controller?.value.isPlaying ?? false;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _navigateToHome(fromShowcase: false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF141210),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Framed Video Display (unobstructed, full video visible)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderBrass, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          offset: const Offset(0, 4),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.5),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isReady && controller != null && controller.value.isInitialized)
                            GestureDetector(
                              onTap: _togglePlay,
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: controller.value.aspectRatio,
                                  child: VideoPlayer(controller),
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: CircularProgressIndicator(color: AppColors.brassGold),
                            ),

                          // Play / Pause Indicator
                          if (!isPlaying && _isReady)
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.brassGold, width: 2),
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: AppColors.brassGold, size: 36),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Separate Buttons Panel Below the Frame
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.panelCream.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderBrass, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Template & Track Badges Row
                      Row(
                        children: [
                          // Template Pill
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.panelInset,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: AppColors.chassisBevelDark),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.motion_photos_auto_rounded, size: 12, color: AppColors.brassGold),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Template: Pendulum',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textEngraved,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Track Pill
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.panelInset,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(color: AppColors.chassisBevelDark),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.music_note_rounded, size: 12, color: AppColors.amberJewel),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      'Track: Little Do You Know',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textEngraved,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Video Progress / Transport Bar
                      if (controller != null && controller.value.isInitialized)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: AppColors.brassGold,
                              bufferedColor: Colors.black26,
                              backgroundColor: Colors.black12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Master Call-to-Action
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _navigateToHome,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFE082), Color(0xFFFFC72C)],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: const Color(0xFFBF8A00), width: 1.2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, offset: Offset(1, 2), blurRadius: 3),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome_rounded, size: 15, color: Color(0xFF1E1A10)),
                              SizedBox(width: 8),
                              Text(
                                'CREATE YOUR OWN REEL ❯',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Color(0xFF1E1A10),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
