import 'package:flutter/material.dart';
import 'package:fouquet/core/presentation/onboarding_screen.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _ctrl.forward();

    // ── Redirection après 3 secondes ─────────────────────
    // Remplace le Future.delayed dans initState() par ceci :

    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return; // ← sécurité si le widget est détruit
      try {
        final bool showOnboarding = await OnboardingScreen.shouldShow();
        if (!mounted) return;
        Get.offAllNamed(
          showOnboarding ? AppRoutes.onboardingScreen : AppRoutes.home,
        );
      } catch (e) {
        debugPrint('Erreur splash: $e');
        if (!mounted) return;
        Get.offAllNamed(AppRoutes.login); // fallback
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSplash,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Image de fond ─────────────────────────────
          Image.asset(
            AppImages.splashBg,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: AppColors.bgSplash),
          ),

          // ── Overlay sombre ────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgSplash.withOpacity(0.6),
                  AppColors.bgSplash.withOpacity(0.92),
                ],
              ),
            ),
          ),

          // ── Logo centré animé ─────────────────────────
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppImages.splashLogo,
                      width: 220,
                      errorBuilder: (_, __, ___) => Column(
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Le Fouquet',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'CALAVI ZOPAH',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Indicateur de chargement bas ──────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Chargement...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
