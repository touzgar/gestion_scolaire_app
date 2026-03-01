import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/constants/app_strings.dart';
import 'domain/entities/user_role.dart';
import 'injection/dependency_injection.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/shells/role_shells.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyATzbE2Q2dehziBoywSSxE6OM3tHWEOZ3w",
        authDomain: "gestionscolaire-3b0a2.firebaseapp.com",
        projectId: "gestionscolaire-3b0a2",
        storageBucket: "gestionscolaire-3b0a2.firebasestorage.app",
        messagingSenderId: "919288512507",
        appId: "1:919288512507:web:ea1200301e3cc54830955e",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Initialiser l'injection de dépendances
  await initDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(AuthCheckRequested()),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              return const SplashPage();
            }
            if (state is AuthAuthenticated) {
              return _buildShellForRole(state.user.role);
            }
            // AuthUnauthenticated, AuthError, etc.
            return const LoginPage();
          },
        ),
      ),
    );
  }

  /// Retourne le shell de navigation adapté au rôle de l'utilisateur
  Widget _buildShellForRole(UserRole role) {
    switch (role) {
      case UserRole.eleve:
        return const EleveShell();
      case UserRole.professeur:
        return const ProfesseurShell();
      case UserRole.admin:
        return const AdminShell();
    }
  }
}
