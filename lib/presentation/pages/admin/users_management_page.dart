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
      appBar: AppBar(title: const Text('Gestion Utilisateurs')),
      body: Column(
        children: [
          // ─── Barre de recherche ───
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
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

          // ─── Filtres par rôle ───
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Tous',
                  selected: _selectedFilter == 'all',
                  onTap: () => setState(() => _selectedFilter = 'all'),
                ),
                _FilterChip(
                  label: 'Élèves',
                  selected: _selectedFilter == 'eleve',
                  color: AppColors.roleEleve,
                  onTap: () => setState(() => _selectedFilter = 'eleve'),
                ),
                _FilterChip(
                  label: 'Professeurs',
                  selected: _selectedFilter == 'professeur',
                  color: AppColors.roleProfesseur,
                  onTap: () => setState(() => _selectedFilter = 'professeur'),
                ),
                _FilterChip(
                  label: 'Parents',
                  selected: _selectedFilter == 'parent',
                  color: AppColors.roleParent,
                  onTap: () => setState(() => _selectedFilter = 'parent'),
                ),
                _FilterChip(
                  label: 'Admins',
                  selected: _selectedFilter == 'admin',
                  color: AppColors.roleAdmin,
                  onTap: () => setState(() => _selectedFilter = 'admin'),
                ),
                _FilterChip(
                  label: 'Vie Scolaire',
                  selected: _selectedFilter == 'vie_scolaire',
                  color: AppColors.roleVieScolaire,
                  onTap: () => setState(() => _selectedFilter = 'vie_scolaire'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ─── Liste utilisateurs ───
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(),
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
                          Icons.person_off,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text('Aucun utilisateur trouvé'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _UserCard(
                      uid: docs[index].id,
                      data: data,
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
    var query = FirebaseFirestore.instance
        .collection('utilisateurs')
        .orderBy('dateCreation', descending: true);

    if (_selectedFilter != 'all') {
      query = FirebaseFirestore.instance
          .collection('utilisateurs')
          .where('role', isEqualTo: _selectedFilter)
          .orderBy('dateCreation', descending: true);
    }

    return query.snapshots();
  }

  Future<void> _toggleActive(String uid, Map<String, dynamic> data) async {
    final current = data['isActive'] ?? true;
    await FirebaseFirestore.instance.collection('utilisateurs').doc(uid).update(
      {'isActive': !current},
    );
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
        title: const Text('Supprimer l\'utilisateur'),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primaryNavy;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? chipColor : chipColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : chipColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String uid;
  final Map<String, dynamic> data;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const _UserCard({
    required this.uid,
    required this.data,
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
    final initials =
        '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'
            .toUpperCase();
    final roleColor = _roleColor(role);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isActive ? roleColor : Colors.grey.shade400,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _roleName(role),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: isActive
                          ? AppColors.textSecondary
                          : Colors.grey.shade400,
                    ),
                  ),
                  if (!isActive)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '⛔ Compte désactivé',
                        style: TextStyle(fontSize: 11, color: AppColors.error),
                      ),
                    ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'toggle') onToggleActive();
                if (val == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        size: 18,
                        color: isActive ? AppColors.error : AppColors.success,
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

  static String _roleName(String role) {
    return UserRoleExtension.fromString(role).displayName;
  }
}
