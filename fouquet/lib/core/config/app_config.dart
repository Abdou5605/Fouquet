import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppConfig {
  AppConfig._();

  static Future<void> init() async {
    await GetStorage.init();
    GetStorage().erase();

    FlutterNativeSplash.remove();
  }

  static final baseUrl = "https://fouquet.twoftechnologies.com/api";
}
