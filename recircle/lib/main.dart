import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';
import 'screens/create_item_screen.dart';

void main() {
  runApp(ReCircleApp());
}

class ReCircleApp extends StatelessWidget {
  ReCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReCircle',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(),
        builder: (context, snapshot) {
          // Handle different connection states safely
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          // Handle errors
          if (snapshot.hasError) {
            print('Auth check error: ${snapshot.error}');
            return const LoginScreen(); // Fallback to login on error
          }

          // Use data safely
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/create_item': (context) => const CreateItemScreen(), // ← ADD THIS
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// Splash Screen remains the same
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.recycling, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'ReCircle',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Starting the revolution...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
