import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfMessagesPage extends StatelessWidget {
  const ProfMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messagerie')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeDialog(context),
        child: const Icon(Icons.edit),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final uid = state.user.uid;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('destinataireId', isEqualTo: uid)
                .orderBy('dateEnvoi', descending: true)
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
                      Icon(
                        Icons.mail_outline,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun message',
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  final sujet = data['sujet'] ?? 'Sans objet';
                  final contenu = data['contenu'] ?? '';
                  final estLu = data['estLu'] ?? false;
                  final date = (data['dateEnvoi'] as Timestamp?)?.toDate();

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: estLu
                            ? Colors.grey.shade200
                            : AppColors.primaryNavy.withValues(alpha: 0.15),
                        child: Icon(
                          estLu ? Icons.mail_outline : Icons.mark_email_unread,
                          color: estLu ? Colors.grey : AppColors.primaryNavy,
                          size: 22,
                        ),
                      ),
                      title: Text(
                        sujet,
                        style: TextStyle(
                          fontWeight: estLu
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        contenu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: date != null
                          ? Text(
                              '${date.day}/${date.month}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            )
                          : null,
                      onTap: () {
                        // Mark as read
                        if (!estLu) {
                          snapshot.data!.docs[index].reference.update({
                            'estLu': true,
                          });
                        }
                        _showMessageDetail(context, sujet, contenu, date);
                      },
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

  void _showMessageDetail(
    BuildContext context,
    String sujet,
    String contenu,
    DateTime? date,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                sujet,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (date != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Divider(height: 32),
              Text(contenu, style: const TextStyle(fontSize: 15, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showComposeDialog(BuildContext context) {
    final sujetCtrl = TextEditingController();
    final contenuCtrl = TextEditingController();
    final destCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouveau message'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: destCtrl,
                decoration: const InputDecoration(
                  labelText: 'Destinataire (ID)',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: sujetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Sujet',
                  prefixIcon: Icon(Icons.subject),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contenuCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  alignLabelWithHint: true,
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
              final state = context.read<AuthBloc>().state;
              if (state is! AuthAuthenticated) return;
              if (sujetCtrl.text.isEmpty || contenuCtrl.text.isEmpty) return;

              await FirebaseFirestore.instance.collection('messages').add({
                'expediteurId': state.user.uid,
                'destinataireId': destCtrl.text.trim(),
                'sujet': sujetCtrl.text.trim(),
                'contenu': contenuCtrl.text.trim(),
                'dateEnvoi': Timestamp.now(),
                'estLu': false,
                'piecesJointes': [],
              });
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
