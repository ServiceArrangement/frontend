import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-rellenar credenciales de prueba
    _userController.text = "admin";
    _passController.text = "admin123";
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      bool success = await authProvider.login(_userController.text, _passController.text);
      if (success && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al iniciar sesión')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle, size: 100, color: Colors.blue),
            const Text("FixNow Admin", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(controller: _userController, decoration: const InputDecoration(labelText: "Usuario")),
            TextField(controller: _passController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
            const SizedBox(height: 30),
            isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton(onPressed: _handleLogin, child: const Text("Iniciar Sesión")),
          ],
        ),
      ),
    );
  }
}