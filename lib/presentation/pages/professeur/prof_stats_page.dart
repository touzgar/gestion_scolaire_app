import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfStatsPage extends StatelessWidget {
  const ProfStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final profId = state.user.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notes')
                .where('professeurId', isEqualTo: profId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.analytics,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Pas de données pour les statistiques',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Compute stats
              double total = 0;
              int count = docs.length;
              double highest = 0;
              double lowest = 20;
              final distributionMap = <String, int>{
                'Excellent (≥16)': 0,
                'Bien (14-16)': 0,
                'Assez Bien (12-14)': 0,
                'Passable (10-12)': 0,
                'Insuffisant (<10)': 0,
              };
              final distributionColors = [
                AppColors.noteExcellent,
                AppColors.noteBien,
                AppColors.noteAssezBien,
                AppColors.notePassable,
                AppColors.noteInsuffisant,
              ];

              for (final doc in docs) {
                final d = doc.data() as Map<String, dynamic>;
                final v = (d['valeur'] as num?)?.toDouble() ?? 0;
                total += v;
                if (v > highest) highest = v;
                if (v < lowest) lowest = v;
                if (v >= 16) {
                  distributionMap['Excellent (≥16)'] =
                      distributionMap['Excellent (≥16)']! + 1;
                } else if (v >= 14) {
                  distributionMap['Bien (14-16)'] =
                      distributionMap['Bien (14-16)']! + 1;
                } else if (v >= 12) {
                  distributionMap['Assez Bien (12-14)'] =
                      distributionMap['Assez Bien (12-14)']! + 1;
                } else if (v >= 10) {
                  distributionMap['Passable (10-12)'] =
                      distributionMap['Passable (10-12)']! + 1;
                } else {
                  distributionMap['Insuffisant (<10)'] =
                      distributionMap['Insuffisant (<10)']! + 1;
                }
              }
              final moyenne = count > 0 ? total / count : 0.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Summary cards ───
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _StatBox(
                          label: 'Notes saisies',
                          value: '$count',
                          icon: Icons.grade,
                          color: AppColors.info,
                        ),
                        _StatBox(
                          label: 'Moyenne générale',
                          value: moyenne.toStringAsFixed(1),
                          icon: Icons.trending_up,
                          color: AppColors.getNoteColor(moyenne),
                        ),
                        _StatBox(
                          label: 'Note max',
                          value: highest.toStringAsFixed(1),
                          icon: Icons.arrow_upward,
                          color: AppColors.success,
                        ),
                        _StatBox(
                          label: 'Note min',
                          value: lowest.toStringAsFixed(1),
                          icon: Icons.arrow_downward,
                          color: AppColors.error,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── Distribution ───
                    const Text(
                      'Distribution des notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: List.generate(distributionMap.length, (i) {
                            final entry = distributionMap.entries.elementAt(i);
                            final fraction = count > 0
                                ? entry.value / count
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: fraction,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation(
                                          distributionColors[i],
                                        ),
                                        minHeight: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      '${entry.value}',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: distributionColors[i],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 8,
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
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
