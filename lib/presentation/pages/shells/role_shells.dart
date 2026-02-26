import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/auth/auth_event.dart';
import '../../../domain/entities/user_role.dart';

/// Shell Élève / Parent — Navigation par BottomNavigationBar
class EleveShell extends StatefulWidget {
  const EleveShell({super.key});

  @override
  State<EleveShell> createState() => _EleveShellState();
}

class _EleveShellState extends State<EleveShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: AppStrings.notes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: AppStrings.emploiDuTemps,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: AppStrings.devoirs,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profil,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _DashboardPlaceholder(title: 'Tableau de bord Élève');
      case 1:
        return const _DashboardPlaceholder(title: 'Mes Notes');
      case 2:
        return const _DashboardPlaceholder(title: 'Emploi du temps');
      case 3:
        return const _DashboardPlaceholder(title: 'Devoirs');
      case 4:
        return _buildProfilePage();
      default:
        return const _DashboardPlaceholder(title: 'Tableau de bord');
    }
  }

  Widget _buildProfilePage() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Scaffold(
            appBar: AppBar(title: const Text(AppStrings.profil)),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryNavy,
                  child: Text(
                    '${user.prenom[0]}${user.nom[0]}',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.nomComplet,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  user.role.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Shell Professeur
class ProfesseurShell extends StatefulWidget {
  const ProfesseurShell({super.key});

  @override
  State<ProfesseurShell> createState() => _ProfesseurShellState();
}

class _ProfesseurShellState extends State<ProfesseurShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.classes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grade),
            label: AppStrings.saisieNotes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppStrings.messages,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: AppStrings.statistiques,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profil,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _DashboardPlaceholder(title: 'Mes Classes');
      case 1:
        return const _DashboardPlaceholder(title: 'Saisie des Notes');
      case 2:
        return const _DashboardPlaceholder(title: 'Messagerie');
      case 3:
        return const _DashboardPlaceholder(title: 'Statistiques');
      case 4:
        return const _DashboardPlaceholder(title: 'Profil Professeur');
      default:
        return const _DashboardPlaceholder(title: 'Mes Classes');
    }
  }
}

/// Shell Administration
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: AppStrings.classes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: AppStrings.statistiques,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _DashboardPlaceholder(title: 'Tableau de bord Admin');
      case 1:
        return const _DashboardPlaceholder(title: 'Gestion Utilisateurs');
      case 2:
        return const _DashboardPlaceholder(title: 'Gestion Classes');
      case 3:
        return const _DashboardPlaceholder(title: 'Statistiques Établissement');
      case 4:
        return const _DashboardPlaceholder(title: 'Paramètres');
      default:
        return const _DashboardPlaceholder(title: 'Admin');
    }
  }
}

/// Shell Vie Scolaire
class VieScolaireShell extends StatefulWidget {
  const VieScolaireShell({super.key});

  @override
  State<VieScolaireShell> createState() => _VieScolaireShellState();
}

class _VieScolaireShellState extends State<VieScolaireShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_off),
            label: 'Absences',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Retards'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événements'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profil,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const _DashboardPlaceholder(title: 'Vie Scolaire');
      case 1:
        return const _DashboardPlaceholder(title: 'Gestion Absences');
      case 2:
        return const _DashboardPlaceholder(title: 'Gestion Retards');
      case 3:
        return const _DashboardPlaceholder(title: 'Événements');
      case 4:
        return const _DashboardPlaceholder(title: 'Profil');
      default:
        return const _DashboardPlaceholder(title: 'Vie Scolaire');
    }
  }
}

/// Placeholder générique pour les pages en cours de développement
class _DashboardPlaceholder extends StatelessWidget {
  final String title;

  const _DashboardPlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: AppColors.accentOrange.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'En cours de développement...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
