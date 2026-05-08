import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Page de gestion des salles (Admin) - Redesigned to match screenshot
class SallesManagementPage extends StatefulWidget {
  const SallesManagementPage({super.key});

  @override
  State<SallesManagementPage> createState() => _SallesManagementPageState();
}

class _SallesManagementPageState extends State<SallesManagementPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          // Dark Navy Header with Search
          _buildHeader(),
          
          // Main Content
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('salles')
                  .orderBy('nom')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                final salles = snapshot.data?.docs ?? [];
                
                // Filter by search query
                final filteredSalles = salles.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final nom = (data['nom'] ?? '').toString().toLowerCase();
                  final type = (data['type'] ?? '').toString().toLowerCase();
                  return nom.contains(_searchQuery) || type.contains(_searchQuery);
                }).toList();

                if (filteredSalles.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildSallesList(filteredSalles);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Bar
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D4A6F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher une salle...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                ' / ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Text(
                'Gestion des Salles',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Page Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestion des Salles',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Configurez et gérez les espaces d\'apprentissage de votre établissement.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddSalleDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle Salle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Empty State Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(60),
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
                // Large Icon with decorative elements
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circles
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E3A5F).withOpacity(0.05),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E3A5F).withOpacity(0.08),
                      ),
                    ),
                    // Main icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1E3A5F).withOpacity(0.12),
                      ),
                      child: const Icon(
                        Icons.meeting_room_outlined,
                        size: 50,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    // Floating icons
                    Positioned(
                      top: 20,
                      right: 60,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.chair_outlined,
                          size: 20,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 50,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.computer_outlined,
                          size: 20,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Aucune salle créée',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                const SizedBox(
                  width: 500,
                  child: Text(
                    'Votre inventaire de salles est actuellement vide.\nCommencez par ajouter les salles de classe, les\nlaboratoires ou les amphithéâtres pour organiser vos\nemplois du temps.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Add Button
                ElevatedButton.icon(
                  onPressed: () => _showAddSalleDialog(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Ajouter une salle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Help text
                Text(
                  'Appuyez sur + pour ajouter une salle',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Info Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _InfoCard(
                      icon: Icons.info_outline,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Types de salles',
                      description: 'Salles banalisées, labos,\ngymnases ou amphis.',
                    ),
                    const SizedBox(width: 20),
                    _InfoCard(
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFFFF6B35),
                      title: 'Capacité & Équipement',
                      description: 'Définissez le nombre de\nplaces et les ressources\n(VPI, PC).',
                    ),
                    const SizedBox(width: 20),
                    _InfoCard(
                      icon: Icons.auto_awesome_outlined,
                      iconColor: const Color(0xFF8B5CF6),
                      title: 'Attribution auto',
                      description: 'Utilisez ces salles pour la\ngénération automatique.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSallesList(List<QueryDocumentSnapshot> salles) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                ' / ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Text(
                'Gestion des Salles',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFFF6B35),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Page Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestion des Salles',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${salles.length} salle${salles.length > 1 ? 's' : ''} enregistrée${salles.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddSalleDialog(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle Salle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Salles Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
            ),
            itemCount: salles.length,
            itemBuilder: (context, index) {
              final doc = salles[index];
              final data = doc.data() as Map<String, dynamic>;
              return _SalleCard(
                data: data,
                onTap: () => _showEditSalleDialog(doc.id, data),
                onDelete: () => _confirmDelete(doc.id, data['nom'] ?? ''),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddSalleDialog() {
    _showSalleDialog();
  }

  void _showEditSalleDialog(String id, Map<String, dynamic> data) {
    _showSalleDialog(id: id, data: data);
  }

  void _showSalleDialog({String? id, Map<String, dynamic>? data}) {
    final isEdit = id != null;
    final nomCtrl = TextEditingController(text: data?['nom'] ?? '');
    final capaciteCtrl = TextEditingController(
      text: (data?['capacite'] ?? '').toString(),
    );
    final typeCtrl = TextEditingController(text: data?['type'] ?? '');
    final etageCtrl = TextEditingController(text: data?['etage'] ?? '');
    final batimentCtrl = TextEditingController(text: data?['batiment'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isEdit ? Icons.edit : Icons.add_business,
                color: const Color(0xFFFF6B35),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(isEdit ? 'Modifier la salle' : 'Nouvelle salle'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom de la salle *',
                  hintText: 'ex: Salle 101',
                  prefixIcon: Icon(Icons.meeting_room),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: typeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  hintText: 'ex: Laboratoire, Salle de cours',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: capaciteCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Capacité',
                        prefixIcon: Icon(Icons.people),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: etageCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Étage',
                        hintText: 'ex: RDC, 1er',
                        prefixIcon: Icon(Icons.stairs),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: batimentCtrl,
                decoration: const InputDecoration(
                  labelText: 'Bâtiment',
                  hintText: 'ex: Bâtiment A',
                  prefixIcon: Icon(Icons.business),
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
            onPressed: () async {
              if (nomCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Le nom de la salle est obligatoire'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }

              final salleData = {
                'nom': nomCtrl.text.trim(),
                'type': typeCtrl.text.trim(),
                'capacite': int.tryParse(capaciteCtrl.text) ?? 0,
                'etage': etageCtrl.text.trim(),
                'batiment': batimentCtrl.text.trim(),
                'disponible': true,
                'dateCreation': data?['dateCreation'] ??
                    Timestamp.fromDate(DateTime.now()),
              };

              if (isEdit) {
                await FirebaseFirestore.instance
                    .collection('salles')
                    .doc(id)
                    .update(salleData);
              } else {
                await FirebaseFirestore.instance
                    .collection('salles')
                    .add(salleData);
              }

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit ? 'Salle modifiée ✓' : 'Salle créée ✓',
                    ),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: Text(isEdit ? 'Enregistrer' : 'Créer'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String id, String nom) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 12),
            Text('Supprimer'),
          ],
        ),
        content: Text('Voulez-vous vraiment supprimer la salle « $nom » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('salles').doc(id).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salle supprimée'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    }
  }
}

// Info Card Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Salle Card Widget
class _SalleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SalleCard({
    required this.data,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nom = data['nom'] ?? '';
    final type = data['type'] ?? '';
    final capacite = data['capacite'] ?? 0;
    final etage = data['etage'] ?? '';
    final batiment = data['batiment'] ?? '';
    final disponible = data['disponible'] ?? true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.meeting_room,
                        color: Color(0xFF1E3A5F),
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                              SizedBox(width: 8),
                              Text('Supprimer'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  nom,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (type.isNotEmpty)
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '$capacite places',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: disponible
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        disponible ? 'Disponible' : 'Indisponible',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: disponible
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
