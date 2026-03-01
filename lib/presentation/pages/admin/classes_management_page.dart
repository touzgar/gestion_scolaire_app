import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ClassesManagementPage extends StatelessWidget {
  const ClassesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des Classes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClasseDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('classes')
            .orderBy('niveau')
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
                  Icon(Icons.class_, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune classe créée',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur + pour ajouter une classe',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final classes = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final data = classes[index].data() as Map<String, dynamic>;
              final id = classes[index].id;
              return _ClassCard(
                id: id,
                data: data,
                onEdit: () => _showClasseDialog(context, id: id, data: data),
                onDelete: () => _confirmDelete(context, id, data['nom'] ?? ''),
                onViewStudents: () => _showStudentsDialog(context, id, data),
              );
            },
          );
        },
      ),
    );
  }

  // ─── Add / Edit dialog ───
  void _showClasseDialog(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) {
    final isEdit = id != null;
    final nomCtrl = TextEditingController(text: data?['nom'] ?? '');
    final niveauCtrl = TextEditingController(text: data?['niveau'] ?? '');
    final filiereCtrl = TextEditingController(text: data?['filiere'] ?? '');
    final anneeCtrl = TextEditingController(
      text: data?['anneeScolaire'] ?? '2025-2026',
    );
    final capaciteCtrl = TextEditingController(
      text: (data?['capaciteMax'] ?? 35).toString(),
    );

    String? selectedProfId = data?['professeurPrincipalId'];
    List<String> selectedEleveIds = List<String>.from(data?['eleveIds'] ?? []);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Modifier la classe' : 'Nouvelle classe'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nom (ex: Term S1)',
                          prefixIcon: Icon(Icons.class_),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: niveauCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Niveau (ex: Terminale)',
                          prefixIcon: Icon(Icons.layers),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: filiereCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Filière (ex: S, ES)',
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: anneeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Année scolaire',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: capaciteCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Capacité max',
                          prefixIcon: Icon(Icons.people),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),

                      // ─── Professeur principal dropdown ───
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Professeur principal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('utilisateurs')
                            .where('role', isEqualTo: 'professeur')
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
                          final profs = snap.data!.docs
                            ..sort((a, b) {
                              final aN =
                                  (a.data() as Map<String, dynamic>)['nom'] ??
                                  '';
                              final bN =
                                  (b.data() as Map<String, dynamic>)['nom'] ??
                                  '';
                              return aN.toString().compareTo(bN.toString());
                            });
                          return DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: selectedProfId,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: 'Sélectionner un professeur',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('— Aucun —'),
                              ),
                              ...profs.map((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<String>(
                                  value: doc.id,
                                  child: Text(
                                    '${d['prenom'] ?? ''} ${d['nom'] ?? ''}',
                                  ),
                                );
                              }),
                            ],
                            onChanged: (val) {
                              setDialogState(() {
                                selectedProfId = val;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // ─── Élèves multi-select ───
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Élèves de la classe',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('utilisateurs')
                            .where('role', isEqualTo: 'eleve')
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
                          final eleves = snap.data!.docs
                            ..sort((a, b) {
                              final aN =
                                  (a.data() as Map<String, dynamic>)['nom'] ??
                                  '';
                              final bN =
                                  (b.data() as Map<String, dynamic>)['nom'] ??
                                  '';
                              return aN.toString().compareTo(bN.toString());
                            });
                          if (eleves.isEmpty) {
                            return const Text(
                              'Aucun élève inscrit',
                              style: TextStyle(color: AppColors.textSecondary),
                            );
                          }
                          return Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: eleves.length,
                              itemBuilder: (_, i) {
                                final doc = eleves[i];
                                final d = doc.data() as Map<String, dynamic>;
                                final isSelected = selectedEleveIds.contains(
                                  doc.id,
                                );
                                return CheckboxListTile(
                                  dense: true,
                                  title: Text(
                                    '${d['prenom'] ?? ''} ${d['nom'] ?? ''}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    d['email'] ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  value: isSelected,
                                  onChanged: (val) {
                                    setDialogState(() {
                                      if (val == true) {
                                        selectedEleveIds.add(doc.id);
                                      } else {
                                        selectedEleveIds.remove(doc.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${selectedEleveIds.length} élève(s) sélectionné(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
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
                ElevatedButton(
                  onPressed: () async {
                    if (nomCtrl.text.isEmpty || niveauCtrl.text.isEmpty) {
                      return;
                    }

                    final classData = {
                      'nom': nomCtrl.text.trim(),
                      'niveau': niveauCtrl.text.trim(),
                      'filiere': filiereCtrl.text.trim(),
                      'anneeScolaire': anneeCtrl.text.trim(),
                      'capaciteMax': int.tryParse(capaciteCtrl.text) ?? 35,
                      'professeurPrincipalId': selectedProfId,
                      'eleveIds': selectedEleveIds,
                      'matiereIds': data?['matiereIds'] ?? [],
                    };

                    if (isEdit) {
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .doc(id)
                          .update(classData);
                    } else {
                      await FirebaseFirestore.instance
                          .collection('classes')
                          .add(classData);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(isEdit ? 'Modifier' : 'Créer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── View students dialog ───
  void _showStudentsDialog(
    BuildContext context,
    String classId,
    Map<String, dynamic> data,
  ) {
    final eleveIds = List<String>.from(data['eleveIds'] ?? []);
    final className = data['nom'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Élèves de $className'),
        content: SizedBox(
          width: double.maxFinite,
          child: eleveIds.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Aucun élève dans cette classe',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : FutureBuilder<List<DocumentSnapshot>>(
                  future: _fetchStudents(eleveIds),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final students = snap.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: students.length,
                      itemBuilder: (_, i) {
                        final d = students[i].data() as Map<String, dynamic>?;
                        if (d == null) return const SizedBox.shrink();
                        final name = '${d['prenom'] ?? ''} ${d['nom'] ?? ''}';
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.roleEleve,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(
                            d['email'] ?? '',
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchStudents(List<String> ids) async {
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
    return results;
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String nom,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la classe'),
        content: Text('Supprimer « $nom » ?'),
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
      await FirebaseFirestore.instance.collection('classes').doc(id).delete();
    }
  }
}

// ─── Class Card Widget ───
class _ClassCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewStudents;

  const _ClassCard({
    required this.id,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.onViewStudents,
  });

  @override
  Widget build(BuildContext context) {
    final nom = data['nom'] ?? '';
    final niveau = data['niveau'] ?? '';
    final filiere = data['filiere'] ?? '';
    final eleveIds = List<String>.from(data['eleveIds'] ?? []);
    final capacite = data['capaciteMax'] ?? 35;
    final annee = data['anneeScolaire'] ?? '';
    final profId = data['professeurPrincipalId'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.class_,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nom,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$niveau${filiere.isNotEmpty ? ' - $filiere' : ''} • $annee',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'students') onViewStudents();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.primaryNavy,
                          ),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'students',
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 18,
                            color: AppColors.accentOrange,
                          ),
                          SizedBox(width: 8),
                          Text('Voir élèves'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.error),
                          SizedBox(width: 8),
                          Text('Supprimer'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ─── Professor info ───
            if (profId != null && profId.toString().isNotEmpty)
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('utilisateurs')
                    .doc(profId)
                    .get(),
                builder: (context, snap) {
                  if (!snap.hasData || !snap.data!.exists) {
                    return const SizedBox.shrink();
                  }
                  final d = snap.data!.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.roleProfesseur,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'PP: ${d['prenom'] ?? ''} ${d['nom'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.roleProfesseur,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            // ─── Progress bar effectif ───
            Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${eleveIds.length} / $capacite élèves',
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: capacite > 0 ? eleveIds.length / capacite : 0,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        eleveIds.length >= capacite
                            ? AppColors.error
                            : AppColors.success,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
