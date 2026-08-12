import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
class LoginFormPage extends GetView<AuthController> { const LoginFormPage({super.key}); @override Widget build(BuildContext context) { return const Scaffold(body: Center(child: Text('Login Form'))); } }
