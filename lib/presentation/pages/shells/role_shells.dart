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
import '../professeur/prof_messages_page.dart';
import '../professeur/prof_stats_page.dart';
import '../professeur/prof_profile_page.dart';

// ─── Admin pages ───
import '../admin/admin_dashboard_page.dart';
import '../admin/users_management_page.dart';
import '../admin/classes_management_page.dart';
import '../admin/admin_stats_page.dart';
import '../admin/admin_settings_page.dart';

// ─── Vie Scolaire pages ───
import '../vie_scolaire/vs_dashboard_page.dart';
import '../vie_scolaire/vs_absences_page.dart';
import '../vie_scolaire/vs_retards_page.dart';
import '../vie_scolaire/vs_events_page.dart';
import '../vie_scolaire/vs_profile_page.dart';

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
    ProfMessagesPage(),
    ProfStatsPage(),
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
    AdminStatsPage(),
    AdminSettingsPage(),
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
}

/// Shell Vie Scolaire
class VieScolaireShell extends StatefulWidget {
  const VieScolaireShell({super.key});

  @override
  State<VieScolaireShell> createState() => _VieScolaireShellState();
}

class _VieScolaireShellState extends State<VieScolaireShell> {
  int _currentIndex = 0;

  final _pages = const <Widget>[
    VsDashboardPage(),
    VsAbsencesPage(),
    VsRetardsPage(),
    VsEventsPage(),
    VsProfilePage(),
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
}
