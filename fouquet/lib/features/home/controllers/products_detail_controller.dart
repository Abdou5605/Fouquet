import 'dart:io';

import 'package:fouquet/features/cart/controller/cart_controller.dart';
import 'package:fouquet/features/home/controllers/home_controller.dart';
import 'package:fouquet/features/home/service/menu_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailController extends GetxController {
  final _service = MenuService();

  final dish = Rxn<Map<String, dynamic>>();
  final isLoading = true.obs;
  final isFavorite = false.obs;
  final isLikeLoading = false.obs;
  final quantity = 1.obs;

  late String _slug;

  double get unitPrice =>
      double.tryParse(dish.value?['price']?.toString() ?? '0') ?? 0;

  int get total => (unitPrice * quantity.value).toInt();

  String get formattedTotal {
    final s = total.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
    return '$s FCFA';
  }

  @override
  void onInit() {
    super.onInit();
    _slug = Get.arguments as String;
    fetchDish(_slug);
  }

  // ── Ajouter au panier ──────────────────────────────────────────────────────
  Future<void> addToCart() async {
    final disheId = dish.value?['id'] as String?;
    if (disheId == null) return;

    final cartCtrl = Get.find<CartController>();
    await cartCtrl.addItem(disheId: disheId, quantity: quantity.value);
  }

  Future<void> fetchDish(String slug) async {
    isLoading.value = true;
    final res = await _service.getDishBySlug(slug);
    if (res != null && res['success'] == true) {
      final data = res['data'] as Map<String, dynamic>;
      dish.value = data;
      isFavorite.value = data['is_liked'] == true || data['is_liked'] == 1;
    }
    isLoading.value = false;
  }

  Future<void> toggleFavorite() async {
    if (isLikeLoading.value) return;
    isLikeLoading.value = true;

    isFavorite.value = !isFavorite.value;

    final liked = await _service.likeDish(_slug);

    if (liked == null) {
      isFavorite.value = !isFavorite.value;
    } else {
      isFavorite.value = liked;

      final homeCtrl = Get.find<HomeController>();
      _updateDishInList(homeCtrl.dishes, liked);
      _updateDishInList(homeCtrl.allDishes, liked);
    }

    isLikeLoading.value = false;
  }

  void _updateDishInList(RxList<Map<String, dynamic>> list, bool liked) {
    final index = list.indexWhere((d) => d['slug'] == _slug);
    if (index != -1) {
      final updated = Map<String, dynamic>.from(list[index]);
      updated['is_liked'] = liked;
      list[index] = updated;
    }
  }

  void increment() => quantity.value++;
  void decrement() {
    if (quantity.value > 1) quantity.value--;
  }

  Future<void> shareProduct({String? target}) async {
    final d = dish.value;
    if (d == null) return;

    final name = d['name'] as String? ?? '';
    final description = d['description'] as String? ?? '';
    final imageUrl = d['image'] as String?;
    final shareText =
        '🍽️ $name\n$description\n\nDécouvrez ce plat sur Fouquet !';
    final encodedText = Uri.encodeComponent(shareText);

    // Télécharge l'image une fois
    XFile? xfile;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final response = await http.get(Uri.parse(imageUrl));
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/fouquet_dish.jpg');
      await file.writeAsBytes(response.bodyBytes);
      xfile = XFile(file.path);
    }

    try {
      switch (target) {
        case 'whatsapp':
          // WhatsApp supporte image via Share natif en ciblant le package
          await Share.shareXFiles(
            xfile != null ? [xfile] : [],
            text: shareText,
          );
          break;

        case 'facebook':
          final uri = Uri.parse(
            'https://www.facebook.com/sharer/sharer.php?u=$encodedText',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          break;

        case 'x':
          final uri = Uri.parse(
            'https://twitter.com/intent/tweet?text=$encodedText',
          );
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          break;

        case 'instagram':
          // Instagram ne supporte pas le texte, image seulement
          if (xfile != null) {
            await Share.shareXFiles([xfile], text: shareText);
          }
          break;

        default:
          // Sélecteur natif
          if (xfile != null) {
            await Share.shareXFiles([xfile], text: shareText);
          } else {
            await Share.share(shareText);
          }
      }
    } catch (e) {
      await Share.share(shareText);
    }
  }
}
