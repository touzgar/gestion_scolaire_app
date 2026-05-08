import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_strings.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Dark Navy Header
          _buildHeader(context),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final user = state is AuthAuthenticated ? state.user : null;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Page Title
                      const Text(
                        'Paramètres',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Gérez vos préférences et les informations de votre compte.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Profile Card
                      if (user != null) _buildProfileCard(user),
                      const SizedBox(height: 24),
                      
                      // Application Section
                      _buildSectionHeader('APPLICATION'),
                      const SizedBox(height: 12),
                      _buildApplicationSection(context),
                      const SizedBox(height: 24),
                      
                      // Account Section
                      _buildSectionHeader('COMPTE'),
                      const SizedBox(height: 12),
                      _buildAccountSection(context),
                      const SizedBox(height: 24),
                      
                      // Security Card
                      _buildSecurityCard(),
                      const SizedBox(height: 32),
                      
                      // Footer
                      Center(
                        child: Text(
                          'EduLycée v2.4.0 — © 2024 Système d\'Information Académique',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
      ),
      child: Row(
        children: [
          const Icon(Icons.settings, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Paramètres',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildProfileCard(dynamic user) {
    // Get role display name from UserRole enum
    String getRoleDisplayName(dynamic role) {
      final roleStr = role.toString().split('.').last.toLowerCase();
      switch (roleStr) {
        case 'admin':
          return 'ADMINISTRATEUR';
        case 'professeur':
          return 'PROFESSEUR';
        case 'eleve':
          return 'ÉLÈVE';
        default:
          return roleStr.toUpperCase();
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with badge
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1E3A5F),
                child: Text(
                  '${user.prenom[0]}${user.nom[0]}',
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nomComplet,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    getRoleDisplayName(user.role),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEF4444),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              _showEditProfileDialog(context, user);
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1E3A5F)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Modifier le profil',
              style: TextStyle(
                color: Color(0xFF1E3A5F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.info_outline,
            iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
            title: 'À propos',
            subtitle: '${AppStrings.appName} v${AppStrings.appVersion}',
            onTap: () => _showAboutDialog(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _SettingsTile(
            icon: Icons.calendar_today,
            iconColor: const Color(0xFF8B5CF6),
            iconBgColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            title: 'Année scolaire',
            subtitle: '2023/2024',
            onTap: () => _showAnneeScolaireDialog(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFF59E0B).withOpacity(0.1),
            title: 'Notifications',
            subtitle: 'Gérer les notifications',
            onTap: () => _showNotificationsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.key_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
            title: 'Modifier le mot de passe',
            subtitle: 'Changez votre mot de passe',
            onTap: () => _showChangePasswordDialog(context),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _SettingsTile(
            icon: Icons.logout,
            iconColor: const Color(0xFFEF4444),
            iconBgColor: const Color(0xFFEF4444).withOpacity(0.1),
            title: 'Déconnexion',
            subtitle: 'Se déconnecter de l\'application',
            titleColor: const Color(0xFFEF4444),
            onTap: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D4A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _show2FADialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Double Authentification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sécurisez davantage votre compte administrateur.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ─── About dialog ───
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.appName),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: ${AppStrings.appVersion}',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(AppStrings.appDescription),
            SizedBox(height: 16),
            Text(
              'Application de gestion scolaire complète pour '
              'lycées avec suivi des notes, absences, emploi du '
              'temps et messagerie intégrée.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.key_outlined,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Changer le mot de passe'),
                ],
              ),
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
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPwdCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirmer le mot de passe',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  onPressed: () async {
                    if (newPwdCtrl.text.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Le mot de passe doit contenir au moins 6 caractères',
                          ),
                          backgroundColor: Color(0xFFEF4444),
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
                          backgroundColor: Color(0xFFEF4444),
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
                            backgroundColor: Color(0xFF10B981),
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
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur: $e'),
                            backgroundColor: const Color(0xFFEF4444),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF8B5CF6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Année scolaire'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Année scolaire en cours :',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
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
                    backgroundColor: const Color(0xFF10B981),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFFF59E0B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Notifications'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Notes'),
                    subtitle: const Text('Nouvelles notes saisies'),
                    value: notifNotes,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setDialogState(() => notifNotes = v),
                  ),
                  SwitchListTile(
                    title: const Text('Absences'),
                    subtitle: const Text('Nouvelles absences signalées'),
                    value: notifAbsences,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (v) => setDialogState(() => notifAbsences = v),
                  ),
                  SwitchListTile(
                    title: const Text('Messages'),
                    subtitle: const Text('Nouveaux messages reçus'),
                    value: notifMessages,
                    activeColor: const Color(0xFF10B981),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Préférences de notification enregistrées ✓',
                        ),
                        backgroundColor: Color(0xFF10B981),
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
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: titleColor ?? const Color(0xFF1E293B),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF64748B),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}
