import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Clé SharedPreferences
// ─────────────────────────────────────────────────────────────────────────────

const String _kOnboardingDone = 'onboarding_done';

// ─────────────────────────────────────────────────────────────────────────────
// Données des pages
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardData {
  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final Color accentColor;
  const _OnboardData({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

const List<_OnboardData> _pages = [
  _OnboardData(
    image: AppImages.onboardAfricaine,
    tag: 'Petit Déjeuner',
    title: 'Commencez la journée\ndu bon pied !',
    subtitle:
        'Omelettes, boissons chaudes et spéciaux\nFouquet préparés chaque matin pour vous.',
    accentColor: Color(0xFF8DC63F),
  ),
  _OnboardData(
    image: AppImages.onboardEuropeenne,
    tag: 'Nos Plats',
    title: 'Burgers, Pizzas &\nShawarmas Savoureux',
    subtitle:
        'Une cuisine africaine, européenne et asiatique\npréparée avec passion à Calavi Zopah.',
    accentColor: Color(0xFFE01A6A),
  ),
  _OnboardData(
    image: AppImages.onboardAsiatique,
    tag: 'Notre Service',
    title: 'Une Expérience\nInoubliable',
    subtitle:
        'Profitez d\'un accueil chaleureux en salle,\nen terrasse ou commandez depuis chez vous.',
    accentColor: Color(0xFF8DC63F),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// OnboardingScreen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  /// À appeler depuis le SplashScreen pour savoir quelle route afficher.
  ///
  /// Exemple dans ton SplashScreen :
  /// ```dart
  /// final bool show = await OnboardingScreen.shouldShow();
  /// Get.offAllNamed(show ? AppRoutes.onboarding : AppRoutes.home);
  /// ```
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_kOnboardingDone) ?? false);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  /// Sauvegarde que l'onboarding est vu, puis va au Home.
  Future<void> _markDoneAndGoHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDone, true);
    Get.offAllNamed(AppRoutes.home);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _markDoneAndGoHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── PageView plein écran ───────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _animCtrl
                  ..reset()
                  ..forward();
              },
              itemBuilder: (_, i) => SizedBox.expand(
                child: Image.asset(
                  _pages[i].image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.bgSplash,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.white24,
                        size: 80,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Gradient bas ──────────────────────────────────
          const Positioned.fill(child: IgnorePointer(child: _BottomGradient())),

          // ── Header (logo + bouton "Passer") ───────────────
          Positioned(
            top: topPadding + 16,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo du restaurant
                IgnorePointer(
                  child: Image.asset(
                    AppImages.logoFouquet,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Image.asset(AppImages.logoFouquet, height: 48),
                  ),
                ),

                // Bouton "Passer" — visible sauf sur la dernière page
                if (_currentPage < _pages.length - 1)
                  GestureDetector(
                    onTap: _markDoneAndGoHome,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Contenu bas (tag, titre, sous-titre, dots, bouton) ──
          Positioned(
            bottom: bottomPadding + 48,
            left: 28,
            right: 28,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IgnorePointer(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: page.accentColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          page.tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    IgnorePointer(
                      child: Text(page.title, style: AppTextStyles.splashTitle),
                    ),
                    const SizedBox(height: 12),
                    IgnorePointer(
                      child: Text(
                        page.subtitle,
                        style: AppTextStyles.splashSubtitle,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      children: [
                        IgnorePointer(
                          child: _Dots(
                            count: _pages.length,
                            current: _currentPage,
                            activeColor: page.accentColor,
                          ),
                        ),
                        const Spacer(),
                        _NextButton(
                          isLast: _currentPage == _pages.length - 1,
                          color: page.accentColor,
                          onTap: _next,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets internes
// ─────────────────────────────────────────────────────────────────────────────

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.25, 0.6, 1.0],
          colors: [Colors.transparent, Color(0x99000000), Color(0xEE000000)],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;
  final Color activeColor;
  const _Dots({
    required this.count,
    required this.current,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white38,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLast;
  final Color color;
  final VoidCallback onTap;
  const _NextButton({
    required this.isLast,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isLast ? 24 : 20,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLast ? 'Commencer' : 'Suivant',
              style: AppTextStyles.buttonPrimary,
            ),
            const SizedBox(width: 8),
            Icon(
              isLast
                  ? Icons.restaurant_menu_rounded
                  : Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
