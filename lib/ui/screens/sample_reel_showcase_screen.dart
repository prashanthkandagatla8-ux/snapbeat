import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../components/retro_metal_panel.dart';
import '../components/tactile_action_button.dart';
import 'home_screen.dart';

class SampleReelShowcaseScreen extends StatefulWidget {
  final bool autoNavigate;
  final Widget? placeholderPreview;

  const SampleReelShowcaseScreen({
    super.key,
    this.autoNavigate = true,
    this.placeholderPreview,
  });

  @override
  State<SampleReelShowcaseScreen> createState() => _SampleReelShowcaseScreenState();
}

class _SampleReelShowcaseScreenState extends State<SampleReelShowcaseScreen> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasNavigated = false;
  bool _skipDemoNextTime = false;
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    _loadSkipPreference();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (widget.autoNavigate) {
      _safetyTimer = Timer(const Duration(seconds: 20), () {
        _navigateToHome();
      });
    }
    _initVideo();
  }

  Future<void> _loadSkipPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _skipDemoNextTime = prefs.getBool('snapbeat_skip_showcase_demo') ?? false;
      });
    }
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
      if (widget.autoNavigate) {
        _navigateToHome();
      }
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
        backgroundColor: AppColors.canvasSlateGrey,
        body: SafeArea(
          child: Column(
            children: [
              // Top Branding Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      'assets/images/snapbeat_studio_logo.png',
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    TextButton(
                      onPressed: () => _navigateToHome(fromShowcase: true),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'SKIP',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 1. Framed Video Display (unobstructed, full video visible)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x30FFFFFF), width: 1.5),
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
                          else if (widget.placeholderPreview != null)
                            Positioned.fill(child: widget.placeholderPreview!)
                          else
                            const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),

                          // Play / Pause Indicator
                          if ((!isPlaying && _isReady) || widget.placeholderPreview != null)
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Separate Buttons Panel Below the Frame
              RetroMetalPanel(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                padding: const EdgeInsets.all(12),
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
                                  Icon(Icons.motion_photos_auto_rounded, size: 12, color: AppColors.textSecondary),
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
                                  Icon(Icons.music_note_rounded, size: 12, color: AppColors.textSecondary),
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
                              playedColor: Colors.white,
                              bufferedColor: Colors.black26,
                              backgroundColor: Colors.black12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Master Call-to-Action
                      TactileActionButton.primary(
                        height: 46,
                        label: 'CREATE YOUR OWN REEL',
                        icon: Icons.auto_awesome_rounded,
                        onTap: _navigateToHome,
                      ),

                      const SizedBox(height: 8),

                      // Skip demo checkbox
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          final newVal = !_skipDemoNextTime;
                          setState(() => _skipDemoNextTime = newVal);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('snapbeat_skip_showcase_demo', newVal);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: Checkbox(
                                  value: _skipDemoNextTime,
                                  activeColor: const Color(0xFF07080A),
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: AppColors.chassisBevelLight, width: 1.2),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (val) async {
                                    final newVal = val ?? false;
                                    setState(() => _skipDemoNextTime = newVal);
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.setBool('snapbeat_skip_showcase_demo', newVal);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Don't show this demo from next time onwards",
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8E887E),
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
      ),
    );
  }
}
