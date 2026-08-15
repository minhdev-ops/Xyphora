import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
class SplashPage extends GetView<AuthController> { const SplashPage({super.key}); @override Widget build(BuildContext context) { return const Scaffold(body: Center(child: Text('Splash Page'))); } }
