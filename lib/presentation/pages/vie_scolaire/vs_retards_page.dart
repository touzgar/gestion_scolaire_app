import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VsRetardsPage extends StatelessWidget {
  const VsRetardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion Retards')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRetardDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('absences')
            .where('type', isEqualTo: 'retard')
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
                  Icon(Icons.timer_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun retard enregistré',
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
                  statusLabel = 'Justifié';
                  break;
                case 'enAttente':
                  statusColor = AppColors.warning;
                  statusLabel = 'En attente';
                  break;
                default:
                  statusColor = AppColors.warning;
                  statusLabel = 'Non justifié';
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.timer, color: AppColors.warning),
                  ),
                  title: Text(
                    'Retard${date != null ? ' - ${date.day}/${date.month}/${date.year}' : ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: motif.isNotEmpty ? Text(motif, maxLines: 1) : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddRetardDialog(BuildContext context) {
    final eleveIdCtrl = TextEditingController();
    final motifCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau retard'),
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
                'type': 'retard',
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
