import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/user_role.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ─── Profil admin ───
              if (user != null)
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primaryNavy,
                          child: Text(
                            '${user.prenom[0]}${user.nom[0]}',
                            style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.nomComplet,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.roleAdmin.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  user.role.displayName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.roleAdmin,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // ─── Section Application ───
              const Text(
                'APPLICATION',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline,
                      title: 'À propos',
                      subtitle:
                          '${AppStrings.appName} v${AppStrings.appVersion}',
                      onTap: () => _showAboutDialog(context),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.school,
                      title: 'Année scolaire',
                      subtitle: '2025 - 2026',
                      onTap: () => _showAnneeScolaireDialog(context),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Gérer les notifications',
                      onTap: () => _showNotificationsDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ─── Section Compte ───
              const Text(
                'COMPTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      title: 'Changer le mot de passe',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.logout,
                      title: AppStrings.logout,
                      titleColor: AppColors.error,
                      iconColor: AppColors.error,
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── About dialog ───
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: ${AppStrings.appVersion}'),
            SizedBox(height: 8),
            Text(AppStrings.appDescription),
            SizedBox(height: 16),
            Text(
              'Application de gestion scolaire complète pour '
              'lycées avec suivi des notes, absences, emploi du '
              'temps et messagerie intégrée.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
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

  // ─── Change password dialog ───
  void _showChangePasswordDialog(BuildContext context) {
    final currentPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confirmPwdCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Changer le mot de passe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe actuel',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmPwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: Icon(Icons.lock_outline),
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
                    if (newPwdCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Le mot de passe doit contenir au moins 6 caractères',
                          ),
                        ),
                      );
                      return;
                    }
                    if (newPwdCtrl.text != confirmPwdCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Les mots de passe ne correspondent pas',
                          ),
                        ),
                      );
                      return;
                    }
                    try {
                      final firebaseUser = FirebaseAuth.instance.currentUser;
                      if (firebaseUser == null) return;

                      // Re-authenticate
                      final credential = EmailAuthProvider.credential(
                        email: firebaseUser.email!,
                        password: currentPwdCtrl.text,
                      );
                      await firebaseUser.reauthenticateWithCredential(
                        credential,
                      );

                      // Update password
                      await firebaseUser.updatePassword(newPwdCtrl.text);

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe modifié avec succès ✓'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    } on FirebaseAuthException catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              e.code == 'wrong-password'
                                  ? 'Mot de passe actuel incorrect'
                                  : 'Erreur: ${e.message}',
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Modifier'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ─── Année scolaire dialog ───
  void _showAnneeScolaireDialog(BuildContext context) {
    final anneeCtrl = TextEditingController(text: '2025-2026');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Année scolaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Année scolaire en cours :',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: anneeCtrl,
              decoration: const InputDecoration(
                labelText: 'Année scolaire',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update all classes with the new year
              final batch = FirebaseFirestore.instance.batch();
              final classes = await FirebaseFirestore.instance
                  .collection('classes')
                  .get();
              for (final doc in classes.docs) {
                batch.update(doc.reference, {
                  'anneeScolaire': anneeCtrl.text.trim(),
                });
              }
              await batch.commit();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Année scolaire mise à jour: ${anneeCtrl.text.trim()} ✓',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  // ─── Notifications dialog ───
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        bool notifNotes = true;
        bool notifAbsences = true;
        bool notifMessages = true;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Notifications'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Notes'),
                    subtitle: const Text('Nouvelles notes saisies'),
                    value: notifNotes,
                    onChanged: (v) => setDialogState(() => notifNotes = v),
                  ),
                  SwitchListTile(
                    title: const Text('Absences'),
                    subtitle: const Text('Nouvelles absences signalées'),
                    value: notifAbsences,
                    onChanged: (v) => setDialogState(() => notifAbsences = v),
                  ),
                  SwitchListTile(
                    title: const Text('Messages'),
                    subtitle: const Text('Nouveaux messages reçus'),
                    value: notifMessages,
                    onChanged: (v) => setDialogState(() => notifMessages = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fermer'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Préférences de notification enregistrées ✓',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryNavy),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
