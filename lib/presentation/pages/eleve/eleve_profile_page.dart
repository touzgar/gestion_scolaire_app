import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/entities/user_role.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';

class EleveProfilePage extends StatelessWidget {
  const EleveProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profil)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) return const SizedBox.shrink();
          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ─── Avatar ───
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryNavy,
                  backgroundImage: user.photoUrl != null
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null
                      ? Text(
                          '${user.prenom.isNotEmpty ? user.prenom[0] : ''}${user.nom.isNotEmpty ? user.nom[0] : ''}',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.nomComplet,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _roleColor(
                      user.role.firestoreValue,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _roleColor(user.role.firestoreValue),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Infos ───
                Card(
                  margin: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.email,
                        label: 'E-mail',
                        value: user.email,
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.phone,
                        label: 'Téléphone',
                        value: user.telephone ?? 'Non renseigné',
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.calendar_today,
                        label: 'Inscrit le',
                        value:
                            '${user.dateCreation.day}/${user.dateCreation.month}/${user.dateCreation.year}',
                      ),
                      const Divider(height: 1),
                      _InfoTile(
                        icon: Icons.circle,
                        label: 'Statut',
                        value: user.isActive ? 'Actif' : 'Inactif',
                        valueColor: user.isActive
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ─── Déconnexion ───
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(AppStrings.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static Color _roleColor(String role) {
    switch (role) {
      case 'eleve':
        return AppColors.roleEleve;
      case 'professeur':
        return AppColors.roleProfesseur;
      case 'parent':
        return AppColors.roleParent;
      case 'admin':
        return AppColors.roleAdmin;
      case 'vie_scolaire':
        return AppColors.roleVieScolaire;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryNavy, size: 22),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: valueColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
