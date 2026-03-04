import 'package:flutter/material.dart';
import '../../core/auth_storage.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage().getToken();
    await Future.delayed(const Duration(seconds: 2)); // Para que se vea el logo
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => token != null ? const HomeScreen() : const LoginScreen()
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Icon(Icons.build_circle, size: 80, color: Colors.blue)),
    );
  }
}