import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VsAbsencesPage extends StatelessWidget {
  const VsAbsencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion Absences')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAbsenceDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('absences')
            .where('type', isEqualTo: 'absence')
            .orderBy('dateDebut', descending: true)
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
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.success.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune absence enregistrée',
                    style: TextStyle(
                      fontSize: 16,
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
              final statut = data['statut'] ?? 'nonJustifie';
              final date = (data['dateDebut'] as Timestamp?)?.toDate();
              final motif = data['motif'] ?? '';

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
                case 'refuse':
                  statusColor = AppColors.error;
                  statusLabel = 'Refusée';
                  break;
                default:
                  statusColor = AppColors.error;
                  statusLabel = 'Non justifiée';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.person_off, color: statusColor),
                  ),
                  title: Text(
                    'Absence${date != null ? ' - ${date.day}/${date.month}/${date.year}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: motif.isNotEmpty ? Text(motif, maxLines: 1) : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      doc.reference.update({'statut': val});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: statusColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'nonJustifie',
                        child: Text('Non justifiée'),
                      ),
                      PopupMenuItem(
                        value: 'enAttente',
                        child: Text('En attente'),
                      ),
                      PopupMenuItem(
                        value: 'justifie',
                        child: Text('Justifiée'),
                      ),
                      PopupMenuItem(value: 'refuse', child: Text('Refusée')),
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

  void _showAddAbsenceDialog(BuildContext context) {
    final eleveIdCtrl = TextEditingController();
    final motifCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle absence'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: eleveIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'ID de l\'élève',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: motifCtrl,
                decoration: const InputDecoration(
                  labelText: 'Motif (optionnel)',
                  prefixIcon: Icon(Icons.note),
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
              if (eleveIdCtrl.text.isEmpty) return;
              await FirebaseFirestore.instance.collection('absences').add({
                'eleveId': eleveIdCtrl.text.trim(),
                'type': 'absence',
                'dateDebut': Timestamp.now(),
                'motif': motifCtrl.text.trim(),
                'statut': 'nonJustifie',
                'dateCreation': Timestamp.now(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
