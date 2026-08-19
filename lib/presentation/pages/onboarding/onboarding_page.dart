import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/onboarding_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingProvider(),
      child: const OnboardingView(),
    );
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late VideoPlayerController _videoController1;
  late VideoPlayerController _videoController2;
  bool _isVideo1Initialized = false;
  bool _isVideo2Initialized = false;
  bool _video1Completed = false;
  bool _video2Completed = false;

  @override
  void initState() {
    super.initState();
    _videoController1 =
        VideoPlayerController.asset('assets/videos/onboaridng1.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideo1Initialized = true;
              });
              _videoController1.setLooping(false);
              _videoController1.setVolume(0.0);
              _videoController1.play();
            }
          });

    _videoController2 =
        VideoPlayerController.asset('assets/videos/onboarding2.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {
                _isVideo2Initialized = true;
              });
              _videoController2.setLooping(false);
              _videoController2.setVolume(0.0);
            }
          });

    _setupVideoListeners();
  }

  void _setupVideoListeners() {
    _videoController1.addListener(() {
      if (!mounted) return;
      final value = _videoController1.value;
      if (value.isInitialized &&
          value.position >= value.duration &&
          !_video1Completed) {
        _video1Completed = true;
        final provider = Provider.of<OnboardingProvider>(
          context,
          listen: false,
        );
        provider.nextPage(() {});
        _handlePageChange(1);
      }
    });

    _videoController2.addListener(() {
      if (!mounted) return;
      final value = _videoController2.value;
      if (value.isInitialized &&
          value.position >= value.duration &&
          !_video2Completed) {
        _video2Completed = true;
        context.go('/welcome');
      }
    });
  }

  void _handlePageChange(int index) {
    if (index == 0) {
      _video1Completed = false;
      if (_isVideo1Initialized) {
        _videoController1.seekTo(Duration.zero);
        _videoController1.play();
      }
      _videoController2.pause();
    } else if (index == 1) {
      _video2Completed = false;
      if (_isVideo2Initialized) {
        _videoController2.seekTo(Duration.zero);
        _videoController2.play();
      }
      _videoController1.pause();
    }
  }

  @override
  void dispose() {
    _videoController1.dispose();
    _videoController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingProvider = Provider.of<OnboardingProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            // Background Video 1 (Slide 1)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity:
                    (onboardingProvider.currentPage == 0 &&
                        _isVideo1Initialized)
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _isVideo1Initialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController1.value.size.width,
                          height: _videoController1.value.size.height,
                          child: VideoPlayer(_videoController1),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Background Video 2 (Slide 2)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity:
                    (onboardingProvider.currentPage == 1 &&
                        _isVideo2Initialized)
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _isVideo2Initialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _videoController2.value.size.width,
                          height: _videoController2.value.size.height,
                          child: VideoPlayer(_videoController2),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            // Semi-transparent overlay to ensure content is readable over the videos
            Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            // Page content
            PageView(
              controller: onboardingProvider.pageController,
              onPageChanged: (index) {
                onboardingProvider.setPage(index);
                _handlePageChange(index);
              },
              children: [_buildSlide1(), _buildSlide2()],
            ),
            // Bottom navigation & indicators
            Positioned(
              bottom: 50,
              left: 30,
              right: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button (visible on slide 1, or hidden)
                  TextButton(
                    onPressed: () => context.go('/welcome'),
                    child: Text(
                      '',
                      style: AppTextStyles.sansBody(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(
                      2,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: onboardingProvider.currentPage == index
                              ? AppColors.goldPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  // Next/Proceed button
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(12),
                    ),
                    onPressed: () {
                      onboardingProvider.nextPage(() {
                        context.go('/welcome');
                      });
                    },
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Astrology zodiac wheel
          SizedBox(width: 280, height: 280),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'DISCOVER\n',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 37 / 30, // line-height: 45px
                  ),
                ),
                TextSpan(
                  text: 'WHAT THE STARS\nREVEAL',
                  style: GoogleFonts.cinzel(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 37 / 30, // line-height: 45px
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Guiding You Through the\nstars, every day',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: AppColors.goldOrange,

              fontSize: 18,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  Widget _buildSlide2() {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Taurus / Constellation vector drawing
          SizedBox(width: 280, height: 280),
          const Spacer(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'EXPLORE\n',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 37 / 30,
                  ),
                ),
                TextSpan(
                  text: 'the secrets written in the stars',
                  style: GoogleFonts.cinzel(
                    color: AppColors.goldPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 37 / 30,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Guiding You Through the\nstars, every day',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: AppColors.goldOrange,

              fontSize: 18,
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}
