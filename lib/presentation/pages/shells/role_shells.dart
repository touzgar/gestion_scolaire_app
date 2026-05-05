import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

// ─── Élève pages ───
import '../eleve/eleve_dashboard_page.dart';
import '../eleve/eleve_notes_page.dart';
import '../eleve/eleve_emploi_du_temps_page.dart';
import '../eleve/eleve_devoirs_page.dart';
import '../eleve/eleve_profile_page.dart';

// ─── Professeur pages ───
import '../professeur/prof_classes_page.dart';
import '../professeur/prof_saisie_notes_page.dart';
import '../professeur/prof_emploi_temps_page.dart';
import '../professeur/prof_messages_page.dart';
import '../professeur/prof_profile_page.dart';

// ─── Admin pages ───
import '../admin/admin_dashboard_page.dart';
import '../admin/users_management_page.dart';
import '../admin/classes_management_page.dart';
import '../admin/admin_emploi_temps_page.dart';
import '../admin/salles_management_page.dart';
import '../admin/admin_settings_page.dart';

/// Shell Élève / Parent — Navigation par BottomNavigationBar
class EleveShell extends StatefulWidget {
  const EleveShell({super.key});

  @override
  State<EleveShell> createState() => _EleveShellState();
}

class _EleveShellState extends State<EleveShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    EleveDashboardPage(),
    EleveNotesPage(),
    EleveEmploiDuTempsPage(),
    EleveDevoirsPage(),
    EleveProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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
}

/// Shell Professeur
class ProfesseurShell extends StatefulWidget {
  const ProfesseurShell({super.key});

  @override
  State<ProfesseurShell> createState() => _ProfesseurShellState();
}

class _ProfesseurShellState extends State<ProfesseurShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    ProfClassesPage(),
    ProfSaisieNotesPage(),
    ProfEmploiTempsPage(),
    ProfMessagesPage(),
    ProfProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
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
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Emploi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: AppStrings.messages,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profil,
          ),
        ],
      ),
    );
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

  final _pages = const <Widget>[
    AdminDashboardPage(),
    UsersManagementPage(),
    ClassesManagementPage(),
    SallesManagementPage(),
    AdminEmploiTempsPage(),
    AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outlined),
            selectedIcon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          NavigationDestination(
            icon: Icon(Icons.class_outlined),
            selectedIcon: Icon(Icons.class_),
            label: 'Classes',
          ),
          NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room),
            label: 'Salles',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Emploi',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}
