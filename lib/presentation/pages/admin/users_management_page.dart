import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/user_role.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  String _selectedFilter = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Utilisateurs'),
        actions: [
          // Stats badge
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('utilisateurs')
                .snapshots(),
            builder: (context, snap) {
              final count = snap.data?.docs.length ?? 0;
              return Center(
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Search + filters ───
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) =>
                        setState(() => _searchQuery = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un utilisateur...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        icon: Icons.people,
                        selected: _selectedFilter == 'all',
                        onTap: () => setState(() => _selectedFilter = 'all'),
                      ),
                      _FilterChip(
                        label: 'Élèves',
                        icon: Icons.school,
                        selected: _selectedFilter == 'eleve',
                        color: AppColors.roleEleve,
                        onTap: () => setState(() => _selectedFilter = 'eleve'),
                      ),
                      _FilterChip(
                        label: 'Professeurs',
                        icon: Icons.cast_for_education,
                        selected: _selectedFilter == 'professeur',
                        color: AppColors.roleProfesseur,
                        onTap: () =>
                            setState(() => _selectedFilter = 'professeur'),
                      ),
                      _FilterChip(
                        label: 'Admins',
                        icon: Icons.admin_panel_settings,
                        selected: _selectedFilter == 'admin',
                        color: AppColors.roleAdmin,
                        onTap: () => setState(() => _selectedFilter = 'admin'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ─── Liste utilisateurs ───
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erreur: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person_off,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final d = doc.data() as Map<String, dynamic>;
                  final nom = (d['nom'] ?? '').toString().toLowerCase();
                  final prenom = (d['prenom'] ?? '').toString().toLowerCase();
                  final email = (d['email'] ?? '').toString().toLowerCase();
                  return nom.contains(_searchQuery) ||
                      prenom.contains(_searchQuery) ||
                      email.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('Aucun résultat'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _UserCard(
                      uid: docs[index].id,
                      data: data,
                      onEdit: () =>
                          _showEditDialog(context, docs[index].id, data),
                      onToggleActive: () => _toggleActive(docs[index].id, data),
                      onDelete: () =>
                          _confirmDelete(context, docs[index].id, data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    if (_selectedFilter != 'all') {
      return FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('role', isEqualTo: _selectedFilter)
          .snapshots();
    }
    return FirebaseFirestore.instance.collection('utilisateurs').snapshots();
  }

  // ─── Edit user dialog ───
  void _showEditDialog(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) {
    final nomCtrl = TextEditingController(text: data['nom'] ?? '');
    final prenomCtrl = TextEditingController(text: data['prenom'] ?? '');
    final telCtrl = TextEditingController(text: data['telephone'] ?? '');
    String selectedRole = data['role'] ?? 'eleve';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.accentOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Modifier l\'utilisateur'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Email (read-only)
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: data['email'] ?? '',
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: prenomCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: nomCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: telCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        // ignore: deprecated_member_use
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Rôle',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'eleve',
                            child: Text('Élève'),
                          ),
                          DropdownMenuItem(
                            value: 'professeur',
                            child: Text('Professeur'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() => selectedRole = v);
                          }
                        },
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
                ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Enregistrer'),
                  onPressed: () async {
                    if (nomCtrl.text.isEmpty || prenomCtrl.text.isEmpty) {
                      return;
                    }
                    await FirebaseFirestore.instance
                        .collection('utilisateurs')
                        .doc(uid)
                        .update({
                          'nom': nomCtrl.text.trim(),
                          'prenom': prenomCtrl.text.trim(),
                          'telephone': telCtrl.text.trim(),
                          'role': selectedRole,
                        });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Utilisateur modifié ✓'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleActive(String uid, Map<String, dynamic> data) async {
    final current = data['isActive'] ?? true;
    await FirebaseFirestore.instance.collection('utilisateurs').doc(uid).update(
      {'isActive': !current},
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            current ? 'Utilisateur désactivé' : 'Utilisateur activé ✓',
          ),
          backgroundColor: current ? AppColors.warning : AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String uid,
    Map<String, dynamic> data,
  ) async {
    final nom = '${data['prenom']} ${data['nom']}';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Supprimer'),
          ],
        ),
        content: Text('Voulez-vous vraiment supprimer $nom ?'),
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
      await FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(uid)
          .delete();
    }
  }
}

// ─── Filter Chip ───
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryNavy;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? chipColor : chipColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? chipColor : chipColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : chipColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : chipColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── User Card ───
class _UserCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _UserCard({
    required this.uid,
    required this.data,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nom = data['nom'] ?? '';
    final prenom = data['prenom'] ?? '';
    final email = data['email'] ?? '';
    final role = data['role'] ?? 'eleve';
    final isActive = data['isActive'] ?? true;
    final telephone = data['telephone'] ?? '';
    final initials =
        '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
            .toUpperCase();
    final roleColor = _roleColor(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar with gradient
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isActive
                        ? [roleColor, roleColor.withValues(alpha: 0.7)]
                        : [Colors.grey.shade400, Colors.grey.shade300],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$prenom $nom',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: isActive
                                  ? AppColors.textPrimary
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _roleName(role),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 13,
                          color: isActive
                              ? AppColors.textSecondary
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: isActive
                                  ? AppColors.textSecondary
                                  : Colors.grey.shade400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (telephone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            telephone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⛔ Désactivé',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'toggle') onToggleActive();
                  if (val == 'delete') onDelete();
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
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          size: 18,
                          color: isActive
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(isActive ? 'Désactiver' : 'Activer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _roleColor(String role) {
    switch (role) {
      case 'eleve':
        return AppColors.roleEleve;
      case 'professeur':
        return AppColors.roleProfesseur;
      case 'admin':
        return AppColors.roleAdmin;
      default:
        return AppColors.textSecondary;
    }
  }

  static String _roleName(String role) {
    return UserRoleExtension.fromString(role).displayName;
  }
}
