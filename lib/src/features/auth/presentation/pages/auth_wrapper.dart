import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../../../../features/common/presentation/pages/splash_screen.dart';
import 'login_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isInitializing) {
          return const SplashScreen();
        }
        if (auth.user != null) {
          return const HomePage(title: 'Better Half');
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
