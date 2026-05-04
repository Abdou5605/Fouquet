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
import 'package:fouquet/features/favorite/controller/favorite_controller.dart';
import 'package:fouquet/features/favorite/presentation/favorites_screen.dart';
import 'package:fouquet/features/notifications/controller/notifications_controller.dart';
import 'package:fouquet/features/home/presentation/all_products_screen.dart';
import 'package:fouquet/features/home/presentation/home_screen.dart';
import 'package:fouquet/features/home/presentation/product_detail_screen.dart';
import 'package:fouquet/features/notifications/presentation/notification_screen.dart';
import 'package:fouquet/features/profile/controller/change_password_controller.dart';
import 'package:fouquet/features/profile/controller/order_history_controller.dart';
import 'package:fouquet/features/profile/controller/profile_controller.dart';
import 'package:fouquet/features/profile/controller/referral_controller.dart';
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
import 'package:fouquet/features/home/controllers/products_detail_controller.dart';

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
      binding: BindingsBuilder(
        () => Get.lazyPut(() => LoginController(), fenix: true),
      ),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => RegisterController(), fenix: true),
      ),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => OtpController(), fenix: true),
      ),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgotPasswordController(), fenix: true),
      ),
    ),

    // ── Home ───────────────────────────────────────────
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.allProducts, page: () => const AllProductsScreen()),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ProductDetailController(), fenix: true),
      ),
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
    GetPage(name: AppRoutes.editProfile, page: () => const EditProfileScreen()),
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
      binding: BindingsBuilder(() => Get.put(OrderHistoryController())),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => FavoriteController(), fenix: true),
      ),
    ),
    GetPage(name: AppRoutes.bookSpace, page: () => const BookSpaceScreen()),
    GetPage(
      name: AppRoutes.referral,
      page: () => const ReferralScreen(),
      binding: BindingsBuilder(() => Get.put(PromoCodeController())),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      binding: BindingsBuilder(() => Get.put(NotificationController())),
    ),
    GetPage(name: AppRoutes.helpCenter, page: () => const HelpCenterScreen()),
    GetPage(name: AppRoutes.contact, page: () => const ContactScreen()),
  ];
}
