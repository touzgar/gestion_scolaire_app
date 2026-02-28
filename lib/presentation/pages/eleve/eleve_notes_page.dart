import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class EleveNotesPage extends StatefulWidget {
  const EleveNotesPage({super.key});

  @override
  State<EleveNotesPage> createState() => _EleveNotesPageState();
}

class _EleveNotesPageState extends State<EleveNotesPage> {
  int _selectedTrimestre = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Notes')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final uid = state.user.uid;

          return Column(
            children: [
              // ─── Sélecteur trimestre ───
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: List.generate(3, (i) {
                    final t = i + 1;
                    final selected = t == _selectedTrimestre;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: i == 0 ? 0 : 4,
                          right: i == 2 ? 0 : 4,
                        ),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTrimestre = t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primaryNavy
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Trimestre $t',
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // ─── Liste des notes ───
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('notes')
                      .where('eleveId', isEqualTo: uid)
                      .where('trimestre', isEqualTo: _selectedTrimestre)
                      .orderBy('date', descending: true)
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
                              Icons.grade,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune note pour le trimestre $_selectedTrimestre',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Calculate average
                    double totalWeighted = 0;
                    double totalCoeff = 0;
                    for (final doc in snapshot.data!.docs) {
                      final d = doc.data() as Map<String, dynamic>;
                      final v = (d['valeur'] as num?)?.toDouble() ?? 0;
                      final c = (d['coefficient'] as num?)?.toDouble() ?? 1;
                      totalWeighted += v * c;
                      totalCoeff += c;
                    }
                    final moyenne = totalCoeff > 0
                        ? totalWeighted / totalCoeff
                        : 0.0;
                    final moyenneColor = AppColors.getNoteColor(moyenne);

                    return Column(
                      children: [
                        // Moyenne card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: moyenneColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: moyenneColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Moyenne: ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: moyenneColor,
                                  ),
                                ),
                                Text(
                                  '${moyenne.toStringAsFixed(2)} / 20',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: moyenneColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Notes list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final data =
                                  snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                              final valeur =
                                  (data['valeur'] as num?)?.toDouble() ?? 0;
                              final coeff =
                                  (data['coefficient'] as num?)?.toDouble() ??
                                  1;
                              final type = data['typeEvaluation'] ?? 'controle';
                              final commentaire = data['commentaire'] ?? '';
                              final date = (data['date'] as Timestamp?)
                                  ?.toDate();
                              final color = AppColors.getNoteColor(valeur);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        valeur.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    type.toString()[0].toUpperCase() +
                                        type.toString().substring(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Coeff. $coeff'),
                                      if (commentaire.isNotEmpty)
                                        Text(
                                          commentaire,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        '/20',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      if (date != null)
                                        Text(
                                          '${date.day}/${date.month}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
