import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfSaisieNotesPage extends StatefulWidget {
  const ProfSaisieNotesPage({super.key});

  @override
  State<ProfSaisieNotesPage> createState() => _ProfSaisieNotesPageState();
}

class _ProfSaisieNotesPageState extends State<ProfSaisieNotesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie des Notes'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle note'),
      ),
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
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.grade,
                          size: 44,
                          color: AppColors.accentOrange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Aucune note saisie',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Appuyez sur + pour ajouter une note',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Sort by date descending in Dart
              final docs = snapshot.data!.docs.toList()
                ..sort((a, b) {
                  final aDate =
                      (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
                  final bDate =
                      (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
                  if (aDate == null || bDate == null) return 0;
                  return bDate.compareTo(aDate);
                });

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  return _NoteCard(
                    data: data,
                    onDelete: () => _confirmDelete(doc.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('Guide de saisie'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Sélectionnez une classe'),
            SizedBox(height: 4),
            Text('2. Choisissez un élève de la classe'),
            SizedBox(height: 4),
            Text('3. Entrez la note, le coefficient et le type'),
            SizedBox(height: 4),
            Text('4. La note sera visible par l\'élève'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) return;
    final profId = state.user.uid;

    final valeurCtrl = TextEditingController();
    final coeffCtrl = TextEditingController(text: '1');
    final commentaireCtrl = TextEditingController();
    String selectedType = 'controle';
    int selectedTrimestre = 1;
    String? selectedClasseId;
    String? selectedEleveId;
    String? selectedEleveName;
    String? selectedClassName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.grade,
                    color: AppColors.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Ajouter une note'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Step 1: Select class ───
                    const Text(
                      '1. Sélectionner la classe',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('classes')
                          .snapshots(),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Text(
                            'Erreur: ${snap.error}',
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          );
                        }
                        if (!snap.hasData) {
                          return const LinearProgressIndicator();
                        }
                        final classes = snap.data!.docs;
                        if (classes.isEmpty) {
                          return const Text(
                            'Aucune classe disponible',
                            style: TextStyle(color: AppColors.textSecondary),
                          );
                        }
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          // ignore: deprecated_member_use
                          value: selectedClasseId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.class_),
                            hintText: 'Choisir une classe',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: classes.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final label =
                                '${d['nom'] ?? ''} (${d['niveau'] ?? ''})';
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(label),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedClasseId = val;
                              selectedEleveId = null;
                              selectedEleveName = null;
                              if (val != null) {
                                final doc = classes.firstWhere(
                                  (d) => d.id == val,
                                );
                                final d = doc.data() as Map<String, dynamic>;
                                selectedClassName = d['nom'] ?? '';
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─── Step 2: Select student from class ───
                    const Text(
                      '2. Sélectionner l\'élève',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (selectedClasseId == null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Sélectionnez d\'abord une classe',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('classes')
                            .doc(selectedClasseId)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData || !snap.data!.exists) {
                            return const LinearProgressIndicator();
                          }
                          final classData =
                              snap.data!.data() as Map<String, dynamic>;
                          final eleveIds = List<String>.from(
                            classData['eleveIds'] ?? [],
                          );

                          if (eleveIds.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Aucun élève dans cette classe',
                                    style: TextStyle(
                                      color: AppColors.warning,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return FutureBuilder<List<DocumentSnapshot>>(
                            future: _fetchStudentsByIds(eleveIds),
                            builder: (context, studentsSnap) {
                              if (!studentsSnap.hasData) {
                                return const LinearProgressIndicator();
                              }
                              final students = studentsSnap.data!;
                              return DropdownButtonFormField<String>(
                                isExpanded: true,
                                // ignore: deprecated_member_use
                                value: selectedEleveId,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.person),
                                  hintText: 'Choisir un élève',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: students.map((doc) {
                                  final d = doc.data() as Map<String, dynamic>;
                                  final name =
                                      '${d['prenom'] ?? ''} ${d['nom'] ?? ''}';
                                  return DropdownMenuItem<String>(
                                    value: doc.id,
                                    child: Text(name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setDialogState(() {
                                    selectedEleveId = val;
                                    if (val != null) {
                                      final s = students.firstWhere(
                                        (d) => d.id == val,
                                      );
                                      final d =
                                          s.data() as Map<String, dynamic>;
                                      selectedEleveName =
                                          '${d['prenom']} ${d['nom']}';
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),

                    // ─── Step 3: Note details ───
                    const Text(
                      '3. Détails de la note',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: valeurCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Note (/20)',
                              prefixIcon: Icon(Icons.grade),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: coeffCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Coeff.',
                              prefixIcon: Icon(Icons.balance),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'controle',
                                child: Text('Contrôle'),
                              ),
                              DropdownMenuItem(
                                value: 'devoir',
                                child: Text('Devoir'),
                              ),
                              DropdownMenuItem(
                                value: 'examen',
                                child: Text('Examen'),
                              ),
                              DropdownMenuItem(
                                value: 'oral',
                                child: Text('Oral'),
                              ),
                              DropdownMenuItem(value: 'tp', child: Text('TP')),
                              DropdownMenuItem(
                                value: 'projet',
                                child: Text('Projet'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => selectedType = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            // ignore: deprecated_member_use
                            value: selectedTrimestre,
                            decoration: const InputDecoration(
                              labelText: 'Trim.',
                              prefixIcon: Icon(Icons.date_range),
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('T1')),
                              DropdownMenuItem(value: 2, child: Text('T2')),
                              DropdownMenuItem(value: 3, child: Text('T3')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setDialogState(() => selectedTrimestre = v);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentaireCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Commentaire (optionnel)',
                        prefixIcon: Icon(Icons.comment),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Ajouter'),
                onPressed: () async {
                  final valeur = double.tryParse(valeurCtrl.text);
                  if (valeur == null || valeur < 0 || valeur > 20) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entrez une note valide (0 - 20)'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  if (selectedEleveId == null || selectedClasseId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sélectionnez une classe et un élève'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }
                  final coeff = double.tryParse(coeffCtrl.text) ?? 1;

                  await FirebaseFirestore.instance.collection('notes').add({
                    'eleveId': selectedEleveId,
                    'eleveName': selectedEleveName ?? '',
                    'classeId': selectedClasseId,
                    'className': selectedClassName ?? '',
                    'matiereId': '',
                    'professeurId': profId,
                    'valeur': valeur,
                    'coefficient': coeff,
                    'typeEvaluation': selectedType,
                    'commentaire': commentaireCtrl.text.trim(),
                    'date': Timestamp.now(),
                    'trimestre': selectedTrimestre,
                    'anneeScolaire': '2025-2026',
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note ajoutée avec succès ✓'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<DocumentSnapshot> results = [];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snap = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snap.docs);
    }
    // Sort alphabetically
    results.sort((a, b) {
      final aN = (a.data() as Map<String, dynamic>)['nom'] ?? '';
      final bN = (b.data() as Map<String, dynamic>)['nom'] ?? '';
      return aN.toString().compareTo(bN.toString());
    });
    return results;
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Supprimer la note'),
          ],
        ),
        content: const Text('Voulez-vous vraiment supprimer cette note ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('notes').doc(noteId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note supprimée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

// ─── Note Card Widget ───
class _NoteCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;

  const _NoteCard({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final valeur = (data['valeur'] as num?)?.toDouble() ?? 0;
    final type = data['typeEvaluation'] ?? 'controle';
    final coeff = (data['coefficient'] as num?)?.toDouble() ?? 1;
    final trimestre = data['trimestre'] ?? 1;
    final date = (data['date'] as Timestamp?)?.toDate();
    final eleveName = data['eleveName'] ?? '';
    final className = data['className'] ?? '';
    final commentaire = data['commentaire'] ?? '';
    final color = AppColors.getNoteColor(valeur);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Note badge
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  valeur.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eleveName.isNotEmpty)
                    Text(
                      eleveName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _typeLabel(type),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Coeff. $coeff',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'T$trimestre',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (className.isNotEmpty) ...[
                        Icon(
                          Icons.class_,
                          size: 12,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          className,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (date != null)
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  if (commentaire.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        commentaire,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 20,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'controle':
        return 'Contrôle';
      case 'devoir':
        return 'Devoir';
      case 'examen':
        return 'Examen';
      case 'oral':
        return 'Oral';
      case 'tp':
        return 'TP';
      case 'projet':
        return 'Projet';
      default:
        return type;
    }
  }
}
