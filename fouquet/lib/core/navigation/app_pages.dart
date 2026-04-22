// app_pages.dart — fichier unique et complet
import 'package:fouquet/core/navigation/app_routes.dart';
import 'package:fouquet/core/presentation/onboarding_screen.dart';
import 'package:fouquet/core/presentation/splash_screen.dart';
import 'package:fouquet/features/auth/controllers/forgot_password_controller.dart';
import 'package:fouquet/features/auth/controllers/login_controller.dart';
import 'package:fouquet/features/auth/controllers/otp_controller.dart';
import 'package:fouquet/features/auth/controllers/register_controller.dart';
import 'package:fouquet/features/auth/presentation/forgot_password_screen.dart';
import 'package:fouquet/features/auth/presentation/login_screen.dart';
import 'package:fouquet/features/auth/presentation/otp_screen.dart';
import 'package:fouquet/features/auth/presentation/register_screen.dart';
import 'package:fouquet/features/booking/presentation/booking_space_screen.dart';
import 'package:fouquet/features/cart/presentation/cart_screen.dart';
import 'package:fouquet/features/cart/presentation/checkout_screen.dart';
import 'package:fouquet/features/cart/presentation/payment_screen.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/home/presentation/all_products_screen.dart';
import 'package:fouquet/features/home/presentation/home_screen.dart';
import 'package:fouquet/features/home/presentation/product_detail_screen.dart';
import 'package:fouquet/features/profile/controller/change_password_controller.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';
import 'package:fouquet/features/profile/presentation/change_password_screen.dart';
import 'package:fouquet/features/profile/presentation/contact_screen.dart';
import 'package:fouquet/features/profile/presentation/edit_profile_screen.dart';
import 'package:fouquet/features/profile/controller/edit_profile_controller.dart';
import 'package:fouquet/features/profile/presentation/help_center_screen.dart';
import 'package:fouquet/features/profile/presentation/order_history_screen.dart';
import 'package:fouquet/features/profile/presentation/profile_screen.dart';
import 'package:fouquet/features/profile/presentation/referral_screen.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

class AppPages {
  static final pages = [
    // ── Splash ─────────────────────────────────────────
    GetPage(
      name: AppRoutes.splash, // '/' ← OBLIGATOIRE comme initialRoute
      page: () => const SplashScreen(),
    ),

    // ── Onboarding ─────────────────────────────────────
    GetPage(
      name: AppRoutes.onboardingScreen,
      page: () => const OnboardingScreen(),
    ),

    // ── Auth ───────────────────────────────────────────
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => RegisterController())),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OtpController())),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgotPasswordController()),
      ),
    ),

    // ── Home ───────────────────────────────────────────
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.allProducts, page: () => const AllProductsScreen()),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
    ),

    // ── Cart / Checkout ────────────────────────────────
    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
    GetPage(name: AppRoutes.checkout, page: () => const CheckoutScreen()),
    GetPage(name: AppRoutes.payment, page: () => const PaymentScreen()),

    // ── Profile ────────────────────────────────────────
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => ProfileController())),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: BindingsBuilder(() => Get.lazyPut(() => EditProfileController())
      ),
    ),
    GetPage(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ChangePasswordController()),
      ),
    ),
    GetPage(
      name: AppRoutes.orderHistory,
      page: () => const OrderHistoryScreen(),
    ),
    GetPage(name: AppRoutes.favorites, page: () => const FavoritesScreen()),
    GetPage(name: AppRoutes.bookSpace, page: () => const BookSpaceScreen()),
    GetPage(name: AppRoutes.referral, page: () => const ReferralScreen()),
    GetPage(name: AppRoutes.helpCenter, page: () => const HelpCenterScreen()),
    GetPage(name: AppRoutes.contact, page: () => const ContactScreen()),
  ];
}
