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
      appBar: AppBar(title: const Text('Saisie des Notes')),
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
                .orderBy('date', descending: true)
                .limit(30)
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
                      Icon(Icons.grade, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune note saisie',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
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

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final doc = snapshot.data!.docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final valeur = (data['valeur'] as num?)?.toDouble() ?? 0;
                  final type = data['typeEvaluation'] ?? 'controle';
                  final coeff = (data['coefficient'] as num?)?.toDouble() ?? 1;
                  final trimestre = data['trimestre'] ?? 1;
                  final date = (data['date'] as Timestamp?)?.toDate();
                  final color = AppColors.getNoteColor(valeur);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
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
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '${type.toString()[0].toUpperCase()}${type.toString().substring(1)} • Coeff. $coeff',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        'T$trimestre${date != null ? ' • ${date.day}/${date.month}/${date.year}' : ''}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () => _confirmDelete(doc.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Ajouter une note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: valeurCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Note (/20)',
                    prefixIcon: Icon(Icons.grade),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coeffCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Coefficient',
                    prefixIcon: Icon(Icons.balance),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'controle',
                      child: Text('Contrôle'),
                    ),
                    DropdownMenuItem(value: 'devoir', child: Text('Devoir')),
                    DropdownMenuItem(value: 'examen', child: Text('Examen')),
                    DropdownMenuItem(value: 'oral', child: Text('Oral')),
                    DropdownMenuItem(value: 'tp', child: Text('TP')),
                    DropdownMenuItem(value: 'projet', child: Text('Projet')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedType = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedTrimestre,
                  decoration: const InputDecoration(
                    labelText: 'Trimestre',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Trimestre 1')),
                    DropdownMenuItem(value: 2, child: Text('Trimestre 2')),
                    DropdownMenuItem(value: 3, child: Text('Trimestre 3')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => selectedTrimestre = v);
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentaireCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire (optionnel)',
                    prefixIcon: Icon(Icons.comment),
                  ),
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
                final valeur = double.tryParse(valeurCtrl.text);
                if (valeur == null || valeur < 0 || valeur > 20) return;
                final coeff = double.tryParse(coeffCtrl.text) ?? 1;

                await FirebaseFirestore.instance.collection('notes').add({
                  'eleveId': '', // would need to select student
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
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String noteId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la note'),
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
    }
  }
}
