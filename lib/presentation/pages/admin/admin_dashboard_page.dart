import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord Admin')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated
              ? state.user.nomComplet
              : 'Admin';
          return RefreshIndicator(
            onRefresh: () async {},
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Bienvenue ───
                  _WelcomeCard(userName: userName),
                  const SizedBox(height: 20),

                  // ─── Stats rapides ───
                  const Text(
                    'Vue d\'ensemble',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatsGrid(),
                  const SizedBox(height: 24),

                  // ─── Derniers utilisateurs ───
                  const Text(
                    'Derniers inscrits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentUsers(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('utilisateurs').snapshots(),
      builder: (context, usersSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('classes').snapshots(),
          builder: (context, classesSnap) {
            final totalUsers = usersSnap.data?.docs.length ?? 0;
            final totalClasses = classesSnap.data?.docs.length ?? 0;

            int eleves = 0, profs = 0;
            if (usersSnap.hasData) {
              for (final doc in usersSnap.data!.docs) {
                final role = (doc.data() as Map<String, dynamic>)['role'] ?? '';
                if (role == 'eleve') eleves++;
                if (role == 'professeur') profs++;
              }
            }

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.people,
                  label: 'Utilisateurs',
                  value: '$totalUsers',
                  color: AppColors.info,
                ),
                _StatCard(
                  icon: Icons.school,
                  label: 'Élèves',
                  value: '$eleves',
                  color: AppColors.roleEleve,
                ),
                _StatCard(
                  icon: Icons.cast_for_education,
                  label: 'Professeurs',
                  value: '$profs',
                  color: AppColors.roleProfesseur,
                ),
                _StatCard(
                  icon: Icons.class_,
                  label: 'Classes',
                  value: '$totalClasses',
                  color: AppColors.accentOrange,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentUsers() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('utilisateurs')
          .orderBy('dateCreation', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('Aucun utilisateur inscrit')),
            ),
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, i) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final nom = data['nom'] ?? '';
              final prenom = data['prenom'] ?? '';
              final email = data['email'] ?? '';
              final role = data['role'] ?? 'eleve';
              final initials =
                  '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
                      .toUpperCase();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _roleColor(role),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                title: Text('$prenom $nom'),
                subtitle: Text(email),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _roleColor(role).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _roleName(role),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _roleColor(role),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  static Color _roleColor(String role) {
    switch (role) {
      case 'eleve':
        return AppColors.roleEleve;
      case 'professeur':
        return AppColors.roleProfesseur;
      case 'admin':
        return AppColors.roleAdmin;
      default:
        return AppColors.textSecondary;
    }
  }

  static String _roleName(String role) {
    switch (role) {
      case 'eleve':
        return 'Élève';
      case 'professeur':
        return 'Professeur';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

class _WelcomeCard extends StatelessWidget {
  final String userName;
  const _WelcomeCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryNavy, AppColors.primaryNavyLight],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bonjour 👋',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Panneau d\'administration DEVMOB-EduLycee',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
