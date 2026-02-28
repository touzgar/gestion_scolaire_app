import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class VsDashboardPage extends StatelessWidget {
  const VsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vie Scolaire')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final userName = state is AuthAuthenticated
              ? state.user.nomComplet
              : '';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.roleVieScolaire,
                        AppColors.accentOrangeLight,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vie Scolaire',
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
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick stats
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('absences')
                      .snapshots(),
                  builder: (context, snap) {
                    int totalAbsences = 0;
                    int nonJustifiees = 0;
                    int retards = 0;

                    if (snap.hasData) {
                      for (final doc in snap.data!.docs) {
                        final d = doc.data() as Map<String, dynamic>;
                        final type = d['type'] ?? 'absence';
                        final statut = d['statut'] ?? 'nonJustifie';
                        if (type == 'retard') {
                          retards++;
                        } else {
                          totalAbsences++;
                        }
                        if (statut == 'nonJustifie') nonJustifiees++;
                      }
                    }

                    return Row(
                      children: [
                        _QuickStat(
                          label: 'Absences',
                          value: '$totalAbsences',
                          color: AppColors.error,
                          icon: Icons.person_off,
                        ),
                        const SizedBox(width: 12),
                        _QuickStat(
                          label: 'Retards',
                          value: '$retards',
                          color: AppColors.warning,
                          icon: Icons.timer,
                        ),
                        const SizedBox(width: 12),
                        _QuickStat(
                          label: 'Non justifiées',
                          value: '$nonJustifiees',
                          color: AppColors.accentOrangeDark,
                          icon: Icons.warning,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                const Text(
                  'Absences récentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentAbsences(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentAbsences() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('absences')
          .orderBy('dateDebut', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 48,
                      color: AppColors.success.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text('Aucune absence enregistrée'),
                  ],
                ),
              ),
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
              final type = data['type'] ?? 'absence';
              final statut = data['statut'] ?? 'nonJustifie';
              final date = (data['dateDebut'] as Timestamp?)?.toDate();
              final eleveId = data['eleveId'] ?? '';
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (isRetard ? AppColors.warning : AppColors.error)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isRetard ? Icons.timer : Icons.person_off,
                    color: isRetard ? AppColors.warning : AppColors.error,
                    size: 20,
                  ),
                ),
                title: Text(
                  isRetard ? 'Retard' : 'Absence',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Élève: ${eleveId.length > 8 ? '${eleveId.substring(0, 8)}...' : eleveId}'
                  '${date != null ? ' • ${date.day}/${date.month}/${date.year}' : ''}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
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

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
