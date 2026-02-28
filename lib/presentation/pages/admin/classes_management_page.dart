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
        onPressed: () => _showAddClasseDialog(context),
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
              final nom = data['nom'] ?? '';
              final niveau = data['niveau'] ?? '';
              final filiere = data['filiere'] ?? '';
              final eleveIds = List<String>.from(data['eleveIds'] ?? []);
              final capacite = data['capaciteMax'] ?? 35;
              final annee = data['anneeScolaire'] ?? '';

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
                              color: AppColors.accentOrange.withValues(
                                alpha: 0.15,
                              ),
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
                              if (v == 'delete')
                                _confirmDelete(context, id, nom);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
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
                      // Progress bar effectif
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
                                value: capacite > 0
                                    ? eleveIds.length / capacite
                                    : 0,
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
            },
          );
        },
      ),
    );
  }

  void _showAddClasseDialog(BuildContext context) {
    final nomCtrl = TextEditingController();
    final niveauCtrl = TextEditingController();
    final filiereCtrl = TextEditingController();
    final anneeCtrl = TextEditingController(text: '2025-2026');
    final capaciteCtrl = TextEditingController(text: '35');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle classe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom (ex: Term S1)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: niveauCtrl,
                decoration: const InputDecoration(
                  labelText: 'Niveau (ex: Terminale)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: filiereCtrl,
                decoration: const InputDecoration(
                  labelText: 'Filière (ex: S, ES)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: anneeCtrl,
                decoration: const InputDecoration(labelText: 'Année scolaire'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: capaciteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacité max'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nomCtrl.text.isEmpty || niveauCtrl.text.isEmpty) return;
              await FirebaseFirestore.instance.collection('classes').add({
                'nom': nomCtrl.text.trim(),
                'niveau': niveauCtrl.text.trim(),
                'filiere': filiereCtrl.text.trim(),
                'anneeScolaire': anneeCtrl.text.trim(),
                'capaciteMax': int.tryParse(capaciteCtrl.text) ?? 35,
                'eleveIds': [],
                'matiereIds': [],
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
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
