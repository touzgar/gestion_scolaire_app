import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

/// Page emploi du temps du professeur
class ProfEmploiTempsPage extends StatefulWidget {
  const ProfEmploiTempsPage({super.key});

  @override
  State<ProfEmploiTempsPage> createState() => _ProfEmploiTempsPageState();
}

class _ProfEmploiTempsPageState extends State<ProfEmploiTempsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  final _joursKeys = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    final initialIndex = (today >= 1 && today <= 6) ? today - 1 : 0;
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Emploi du Temps'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentOrange,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _jours.map((j) => Tab(text: j)).toList(),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final profId = state.user.uid;

          return TabBarView(
            controller: _tabController,
            children: _joursKeys
                .map((jour) => _buildDaySchedule(jour, profId))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildDaySchedule(String jour, String profId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emploi_du_temps')
          .where('jour', isEqualTo: jour)
          .where('professeurId', isEqualTo: profId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.free_breakfast,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pas de cours ce jour',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort by heureDebut in Dart
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aH = (a.data() as Map<String, dynamic>)['heureDebut'] ?? '';
            final bH = (b.data() as Map<String, dynamic>)['heureDebut'] ?? '';
            return aH.toString().compareTo(bH.toString());
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final heureDebut = data['heureDebut'] ?? '';
            final heureFin = data['heureFin'] ?? '';
            final matiere = data['matiere'] ?? data['matiereId'] ?? '';
            final className = data['className'] ?? '';
            final salle = data['salle'] ?? '';
            final estAnnule = data['estAnnule'] ?? false;

            final colors = [
              AppColors.roleEleve,
              AppColors.roleProfesseur,
              AppColors.accentOrange,
              AppColors.roleAdmin,
              AppColors.info,
              AppColors.success,
            ];
            final color = colors[index % colors.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time column
                  SizedBox(
                    width: 55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          heureDebut,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          heureFin,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Color bar
                  Container(
                    width: 4,
                    height: 80,
                    decoration: BoxDecoration(
                      color: estAnnule ? Colors.grey : color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: estAnnule
                            ? Colors.grey.shade100
                            : color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: estAnnule
                            ? null
                            : Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  matiere,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: estAnnule
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: estAnnule
                                        ? Colors.grey
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (estAnnule)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Annulé',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (className.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.class_,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  className,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (salle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.room,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Salle $salle',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
