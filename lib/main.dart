import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importa tus proveedores
import 'providers/auth_provider.dart';
import 'providers/solicitud_provider.dart';
import 'providers/tecnico_provider.dart';

// Importa tu pantalla inicial
import 'ui/screens/splash_screen.dart';

void main() {
  runApp(
    // El MultiProvider es el encargado de "inyectar" todos tus archivos de lógica
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SolicitudProvider()),
        ChangeNotifierProvider(create: (_) => TecnicoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FixNow Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // La app siempre arranca con el Splash para verificar si hay token
      home: const SplashScreen(), 
    );
  }
}