import 'package:flutter/material.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/resources/app_images.dart';
import 'package:fouquet/core/style/colors.dart';
import 'package:fouquet/core/style/text_styles.dart';

// ── Modèle d'une page onboarding ─────────────────────────────
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

// ── Données des 3 slides ──────────────────────────────────────
const List<_OnboardData> _pages = [
  _OnboardData(
    image: AppImages.onboardAfricaine, // ☕ café latte
    tag: 'Petit Déjeuner',
    title: 'Commencez la journée\ndu bon pied !',
    subtitle:
        'Omelettes, boissons chaudes et spéciaux\nFouquet préparés chaque matin pour vous.',
    accentColor: Color(0xFFE8732A), // orange chaud
  ),
  _OnboardData(
    image: AppImages.onboardEuropeenne, // 🍔 burger
    tag: 'Nos Plats',
    title: 'Burgers, Pizzas &\nShawarmas Savoureux',
    subtitle:
        'Une cuisine africaine, européenne et asiatique\npréparée avec passion à Calavi Zopah.',
    accentColor: Color(0xFFE01A6A), // rose Fouquet
  ),
  _OnboardData(
    image: AppImages.onboardAsiatique, // 🌿 terrasse
    tag: 'Notre Service',
    title: 'Une Expérience\nInoubliable',
    subtitle:
        'Profitez d\'un accueil chaleureux en salle,\nen terrasse ou commandez depuis chez vous.',
    accentColor: Color(0xFF8DC63F), // vert Fouquet
  ),
];

// ── Écran Onboarding ──────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

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

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      _goToHome();
    }
  }

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Images plein écran ────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) {
              setState(() => _currentPage = i);
              _animCtrl
                ..reset()
                ..forward();
            },
            itemBuilder: (_, i) => _PageImage(image: _pages[i].image),
          ),

          // ── Gradient progressif bas ───────────────────
          const _BottomGradient(),

          // ── Contenu ───────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Barre haut : logo + passer ─────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo blanc
                      Image.asset(
                        AppImages.splashLogo,
                        height: 36,
                        errorBuilder: (_, __, ___) => Text(
                          'Le Fouquet',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      // Bouton passer
                      if (_currentPage < _pages.length - 1)
                        GestureDetector(
                          onTap: _goToHome,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white24,
                                width: 1,
                              ),
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

                const Spacer(),

                // ── Texte animé ────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag catégorie
                          Container(
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
                          const SizedBox(height: 14),

                          // Titre
                          Text(page.title, style: AppTextStyles.splashTitle),
                          const SizedBox(height: 12),

                          // Sous-titre
                          Text(
                            page.subtitle,
                            style: AppTextStyles.splashSubtitle,
                          ),
                          const SizedBox(height: 36),

                          // Dots + bouton
                          Row(
                            children: [
                              _Dots(
                                count: _pages.length,
                                current: _currentPage,
                                activeColor: page.accentColor,
                              ),
                              const Spacer(),
                              _NextButton(
                                isLast: _currentPage == _pages.length - 1,
                                color: page.accentColor,
                                onTap: _next,
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget image de fond ──────────────────────────────────────
class _PageImage extends StatelessWidget {
  final String image;
  const _PageImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.bgSplash,
          child: const Center(
            child: Icon(Icons.restaurant, color: Colors.white24, size: 80),
          ),
        ),
      ),
    );
  }
}

// ── Gradient sombre bas ───────────────────────────────────────
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

// ── Indicateurs de page ───────────────────────────────────────
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

// ── Bouton Suivant / Commencer ────────────────────────────────
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
