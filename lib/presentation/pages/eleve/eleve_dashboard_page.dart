import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_role.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class EleveDashboardPage extends StatelessWidget {
  const EleveDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Bienvenue ───
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryNavy,
                        AppColors.primaryNavyLight,
                      ],
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
                        user.nomComplet,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role.displayName,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Mes dernières notes ───
                const Text(
                  'Mes dernières notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentNotes(user.uid),
                const SizedBox(height: 24),

                // ─── Prochains devoirs ───
                const Text(
                  'Prochains devoirs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildUpcomingDevoirs(user.uid),
                const SizedBox(height: 24),

                // ─── Absences récentes ───
                const Text(
                  'Absences récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentAbsences(user.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentNotes(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .where('eleveId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            icon: Icons.grade,
            message: 'Aucune note pour le moment',
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
              final valeur = (data['valeur'] as num?)?.toDouble() ?? 0;
              final type = data['typeEvaluation'] ?? 'controle';
              final coeff = (data['coefficient'] as num?)?.toDouble() ?? 1;
              final color = AppColors.getNoteColor(valeur);

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      valeur.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  type.toString()[0].toUpperCase() +
                      type.toString().substring(1),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Coeff. $coeff'),
                trailing: const Text(
                  '/20',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildUpcomingDevoirs(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('devoirs')
          .where('dateLimite', isGreaterThan: Timestamp.now())
          .orderBy('dateLimite')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            icon: Icons.assignment,
            message: 'Aucun devoir à venir',
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, j) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final titre = data['titre'] ?? 'Devoir';
              final dateLimite = (data['dateLimite'] as Timestamp?)?.toDate();
              final daysLeft = dateLimite != null
                  ? dateLimite.difference(DateTime.now()).inDays
                  : 0;
              final urgentColor = daysLeft <= 2
                  ? AppColors.error
                  : AppColors.accentOrange;

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: urgentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.assignment, color: urgentColor),
                ),
                title: Text(
                  titre,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: dateLimite != null
                    ? Text(
                        '${dateLimite.day}/${dateLimite.month}/${dateLimite.year}',
                      )
                    : null,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: urgentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysLeft <= 0 ? 'Aujourd\'hui' : 'J-$daysLeft',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: urgentColor,
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

  Widget _buildRecentAbsences(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('absences')
          .where('eleveId', isEqualTo: uid)
          .orderBy('dateDebut', descending: true)
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _EmptyCard(
            icon: Icons.check_circle,
            message: 'Aucune absence enregistrée 🎉',
            color: AppColors.success,
          );
        }

        return Card(
          margin: EdgeInsets.zero,
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, k) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final type = data['type'] ?? 'absence';
              final statut = data['statut'] ?? 'nonJustifie';
              final date = (data['dateDebut'] as Timestamp?)?.toDate();
              final isRetard = type == 'retard';

              Color statusColor;
              String statusLabel;
              switch (statut) {
                case 'justifie':
                  statusColor = AppColors.success;
                  statusLabel = 'Justifiée';
                  break;
                case 'enAttente':
                  statusColor = AppColors.warning;
                  statusLabel = 'En attente';
                  break;
                default:
                  statusColor = AppColors.error;
                  statusLabel = 'Non justifiée';
              }

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isRetard ? AppColors.warning : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isRetard ? Icons.timer : Icons.person_off,
                    color: isRetard ? AppColors.warning : AppColors.error,
                  ),
                ),
                title: Text(isRetard ? 'Retard' : 'Absence'),
                subtitle: date != null
                    ? Text('${date.day}/${date.month}/${date.year}')
                    : null,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
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
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color? color;

  const _EmptyCard({required this.icon, required this.message, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 40, color: c.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              Text(message, style: TextStyle(color: c, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
