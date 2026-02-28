import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VsEventsPage extends StatelessWidget {
  const VsEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Événements')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('annonces')
            .orderBy('datePublication', descending: true)
            .limit(20)
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
                  Icon(Icons.event, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun événement',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur + pour créer une annonce',
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
              final data =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              final titre = data['titre'] ?? 'Annonce';
              final contenu = data['contenu'] ?? '';
              final estImportante = data['estImportante'] ?? false;
              final date = (data['datePublication'] as Timestamp?)?.toDate();

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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  (estImportante
                                          ? AppColors.error
                                          : AppColors.info)
                                      .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              estImportante
                                  ? Icons.priority_high
                                  : Icons.campaign,
                              color: estImportante
                                  ? AppColors.error
                                  : AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (date != null)
                                  Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (estImportante)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Important',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (contenu.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          contenu,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
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

  void _showAddEventDialog(BuildContext context) {
    final titreCtrl = TextEditingController();
    final contenuCtrl = TextEditingController();
    bool estImportante = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nouvelle annonce'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contenuCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Contenu',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: estImportante,
                  onChanged: (v) =>
                      setDialogState(() => estImportante = v ?? false),
                  title: const Text('Annonce importante'),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
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
                if (titreCtrl.text.isEmpty) return;
                await FirebaseFirestore.instance.collection('annonces').add({
                  'auteurId': '',
                  'titre': titreCtrl.text.trim(),
                  'contenu': contenuCtrl.text.trim(),
                  'datePublication': Timestamp.now(),
                  'destinataireRoles': [],
                  'estImportante': estImportante,
                });
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Publier'),
            ),
          ],
        ),
      ),
    );
  }
}
