import 'package:fouquet/features/cart/presentation/cart_screen.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/home/presentation/product_detail_screen.dart';
import 'package:fouquet/features/profile/presentation/edit_profile_screen.dart';
import 'package:fouquet/features/profile/presentation/order_history_screen.dart';
import 'package:fouquet/features/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/presentation/splash_screen.dart';
import 'package:fouquet/core/presentation/onboarding_screen.dart';
import 'package:fouquet/features/auth/presentation/login_screen.dart';
import 'package:fouquet/features/auth/presentation/register_screen.dart';
import 'package:fouquet/features/auth/presentation/otp_screen.dart';
import 'package:fouquet/features/home/presentation/home_screen.dart';

abstract class AppRouter {
  static final List<GetPage> routes = [
    // ── Splash ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ── Onboarding ─────────────────────────────────────
    GetPage(
      name: AppRoutes.onboardingScreen,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ── Auth ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // ── Home ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // ── À décommenter progressivement ──────────────────
    // GetPage(
    //   name: AppRoutes.menu,
    //   page: () => const MenuScreen(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // GetPage(
    //   name: AppRoutes.checkout,
    //   page: () => const CheckoutScreen(),
    //   transition: Transition.rightToLeft,
    //   transitionDuration: const Duration(milliseconds: 300),
    // ),
    // GetPage(
    //   name: AppRoutes.orderTracking,
    //   page: () => const OrderTrackingScreen(),
    //   transition: Transition.downToUp,
    //   transitionDuration: const Duration(milliseconds: 400),
    // ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    // GetPage(
    //   name: AppRoutes.payment,
    //   page: () => const PaymentScreen(),
    //   transition: Transition.downToUp,
    //   transitionDuration: const Duration(milliseconds: 350),
    // ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
