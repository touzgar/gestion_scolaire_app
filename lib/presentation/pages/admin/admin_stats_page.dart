import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AdminStatsPage extends StatelessWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Répartition par rôle ───
            const Text(
              'Répartition des utilisateurs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildRoleDistribution(),
            const SizedBox(height: 24),

            // ─── Stats classes ───
            const Text(
              'Statistiques des classes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildClassesStats(),
            const SizedBox(height: 24),

            // ─── Moyennes par matière ───
            const Text(
              'Dernières notes enregistrées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecentNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDistribution() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('utilisateurs').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final counts = <String, int>{};
        for (final doc in snapshot.data!.docs) {
          final role =
              (doc.data() as Map<String, dynamic>)['role']?.toString() ??
              'eleve';
          counts[role] = (counts[role] ?? 0) + 1;
        }

        final total = snapshot.data!.docs.length;
        final roles = [
          _RoleData(
            'Élèves',
            counts['eleve'] ?? 0,
            AppColors.roleEleve,
            Icons.school,
          ),
          _RoleData(
            'Professeurs',
            counts['professeur'] ?? 0,
            AppColors.roleProfesseur,
            Icons.cast_for_education,
          ),
          _RoleData(
            'Admins',
            counts['admin'] ?? 0,
            AppColors.roleAdmin,
            Icons.admin_panel_settings,
          ),
        ];

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  '$total utilisateurs au total',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...roles.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: r.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(r.icon, color: r.color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.label,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '${r.count}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: r.color,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: total > 0 ? r.count / total : 0,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation(r.color),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassesStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('classes').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Aucune classe')),
            ),
          );
        }

        int totalEleves = 0;
        int totalCapacity = 0;
        for (final doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          totalEleves += (data['eleveIds'] as List?)?.length ?? 0;
          totalCapacity += (data['capaciteMax'] as int?) ?? 35;
        }

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MiniStat(
                      value: '${snapshot.data!.docs.length}',
                      label: 'Classes',
                      color: AppColors.accentOrange,
                    ),
                    _MiniStat(
                      value: '$totalEleves',
                      label: 'Élèves inscrits',
                      color: AppColors.roleEleve,
                    ),
                    _MiniStat(
                      value: '$totalCapacity',
                      label: 'Capacité totale',
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalCapacity > 0 ? totalEleves / totalCapacity : 0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.roleEleve,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Taux de remplissage: ${totalCapacity > 0 ? (totalEleves / totalCapacity * 100).toStringAsFixed(1) : 0}%',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentNotes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notes')
          .orderBy('date', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Aucune note enregistrée')),
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
              final valeur = (data['valeur'] as num?)?.toDouble() ?? 0;
              final type = data['typeEvaluation'] ?? 'controle';
              final trimestre = data['trimestre'] ?? 1;
              final noteColor = AppColors.getNoteColor(valeur);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: noteColor.withValues(alpha: 0.15),
                  child: Text(
                    valeur.toStringAsFixed(1),
                    style: TextStyle(
                      color: noteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                title: Text(type.toString().toUpperCase()),
                subtitle: Text('Trimestre $trimestre'),
                trailing: Text(
                  '/20',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RoleData {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _RoleData(this.label, this.count, this.color, this.icon);
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
