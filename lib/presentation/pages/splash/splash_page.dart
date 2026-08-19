import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_colors.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late VideoPlayerController _videoController;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.repeat();

    _videoController =
        VideoPlayerController.asset('assets/videos/splashscreenBG.mp4')
          ..initialize().then((_) {
            if (mounted) {
              setState(() {});
              _videoController.play();
              _videoController.setLooping(true);
              _videoController.setVolume(100.0);
            }
          });

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isFadingOut = true;
        });
        _videoController.setVolume(0.0);
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            context.go('/onboarding');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: AnimatedOpacity(
          opacity: _isFadingOut ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 800),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
              // Glowing cosmic nebula aura
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
              ),
              // Astro Ramji Logo

              // Loading indicator at bottom
              Positioned(
                bottom: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo/logo.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    RotationTransition(
                      turns: _controller,
                      child: Image.asset(
                        'assets/images/Component/loading.png',
                        width: 50,
                        height: 50,
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
