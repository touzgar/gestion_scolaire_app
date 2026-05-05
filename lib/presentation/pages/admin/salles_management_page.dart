import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Page de gestion des salles (Admin)
class SallesManagementPage extends StatelessWidget {
  const SallesManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Salles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSalleDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Salle'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 12),
                  Text(
                    'Erreur: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.meeting_room_outlined,
                        size: 52, color: AppColors.primaryNavy),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Aucune salle créée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Appuyez sur + pour ajouter une salle',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final salles = snapshot.data!.docs;

          // Group by type
          final Map<String, List<QueryDocumentSnapshot>> grouped = {};
          for (final doc in salles) {
            final data = doc.data() as Map<String, dynamic>;
            final type = (data['type'] as String?)?.isNotEmpty == true
                ? data['type'] as String
                : 'Autre';
            grouped.putIfAbsent(type, () => []).add(doc);
          }
          final sortedTypes = grouped.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats row
              _buildStatsRow(salles),
              const SizedBox(height: 20),
              // Grouped salles
              for (final type in sortedTypes) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 6),
                  child: Row(
                    children: [
                      Icon(_getTypeIcon(type),
                          size: 20, color: AppColors.primaryNavy),
                      const SizedBox(width: 8),
                      Text(
                        type,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${grouped[type]!.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...grouped[type]!.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _SalleCard(
                    data: data,
                    onEdit: () =>
                        _showSalleDialog(context, id: doc.id, data: data),
                    onDelete: () =>
                        _confirmDelete(context, doc.id, data['nom'] ?? ''),
                  );
                }),
              ],
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(List<QueryDocumentSnapshot> salles) {
    int totalCapacity = 0;
    int disponibles = 0;
    for (final doc in salles) {
      final data = doc.data() as Map<String, dynamic>;
      totalCapacity += (data['capacite'] as int?) ?? 0;
      if (data['disponible'] == true) disponibles++;
    }

    return Row(
      children: [
        Expanded(
          child: _StatMiniCard(
            icon: Icons.meeting_room,
            label: 'Total',
            value: '${salles.length}',
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMiniCard(
            icon: Icons.check_circle,
            label: 'Disponibles',
            value: '$disponibles',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatMiniCard(
            icon: Icons.people,
            label: 'Places',
            value: '$totalCapacity',
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'laboratoire':
        return Icons.science;
      case 'informatique':
        return Icons.computer;
      case 'sport':
        return Icons.sports_soccer;
      case 'bibliothèque':
        return Icons.local_library;
      case 'amphithéâtre':
        return Icons.stadium;
      default:
        return Icons.meeting_room;
    }
  }

  void _showSalleDialog(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) {
    final isEdit = id != null;
    final nomCtrl = TextEditingController(text: data?['nom'] ?? '');
    final capaciteCtrl = TextEditingController(
      text: (data?['capacite'] ?? 30).toString(),
    );
    final etageCtrl = TextEditingController(text: data?['etage'] ?? '');
    final batimentCtrl = TextEditingController(text: data?['batiment'] ?? '');
    final descCtrl = TextEditingController(text: data?['description'] ?? '');

    String selectedType = data?['type'] ?? 'Salle de cours';
    bool disponible = data?['disponible'] ?? true;
    List<String> equipements =
        List<String>.from(data?['equipements'] ?? []);
    final equipCtrl = TextEditingController();

    final types = [
      'Salle de cours',
      'Laboratoire',
      'Informatique',
      'Sport',
      'Bibliothèque',
      'Amphithéâtre',
      'Autre',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isEdit
                          ? [AppColors.accentOrange, const Color(0xFFF39C12)]
                          : [AppColors.primaryNavy, AppColors.primaryNavyLight],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEdit ? Icons.edit : Icons.add_business,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isEdit ? 'Modifier la salle' : 'Nouvelle salle',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    TextField(
                      controller: nomCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nom de la salle *',
                        hintText: 'ex: Salle 101',
                        prefixIcon: Icon(Icons.meeting_room),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Type dropdown
                    DropdownButtonFormField<String>(
                      value: types.contains(selectedType)
                          ? selectedType
                          : 'Autre',
                      decoration: const InputDecoration(
                        labelText: 'Type',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: types
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedType = v);
                        }
                      },
                    ),
                    const SizedBox(height: 14),

                    // Capacité & Étage
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: capaciteCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Capacité',
                              prefixIcon: Icon(Icons.people),
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
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bâtiment
                    TextField(
                      controller: batimentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bâtiment',
                        hintText: 'ex: Bâtiment A',
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Équipements
                    const Text(
                      'Équipements',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: equipCtrl,
                            decoration: const InputDecoration(
                              hintText: 'ex: Projecteur',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add_circle,
                              color: AppColors.success),
                          onPressed: () {
                            if (equipCtrl.text.trim().isNotEmpty) {
                              setDialogState(() {
                                equipements.add(equipCtrl.text.trim());
                                equipCtrl.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    if (equipements.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: equipements.map((e) {
                          return Chip(
                            label: Text(e, style: const TextStyle(fontSize: 12)),
                            deleteIcon:
                                const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setDialogState(() => equipements.remove(e));
                            },
                            backgroundColor:
                                AppColors.primaryNavy.withValues(alpha: 0.08),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Disponible switch
                    SwitchListTile(
                      title: const Text('Disponible'),
                      subtitle: Text(
                        disponible ? 'Salle active' : 'Salle indisponible',
                        style: TextStyle(
                          color: disponible
                              ? AppColors.success
                              : AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                      value: disponible,
                      activeColor: AppColors.success,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) =>
                          setDialogState(() => disponible = v),
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
                icon: Icon(isEdit ? Icons.save : Icons.add, size: 18),
                label: Text(isEdit ? 'Enregistrer' : 'Créer'),
                onPressed: () async {
                  if (nomCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Le nom de la salle est obligatoire'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final salleData = {
                    'nom': nomCtrl.text.trim(),
                    'type': selectedType,
                    'capacite': int.tryParse(capaciteCtrl.text) ?? 30,
                    'etage': etageCtrl.text.trim(),
                    'batiment': batimentCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'equipements': equipements,
                    'disponible': disponible,
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
                            isEdit ? 'Salle modifiée ✓' : 'Salle créée ✓'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, String nom) async {
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
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.error, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Supprimer'),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('salles').doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salle supprimée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('Gestion des Salles'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Créez et gérez les salles de votre établissement'),
            SizedBox(height: 4),
            Text('• Définissez le type, la capacité et les équipements'),
            SizedBox(height: 4),
            Text('• Les salles peuvent être liées à l\'emploi du temps'),
            SizedBox(height: 4),
            Text('• Marquez les salles comme indisponibles si besoin'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Mini Card ───
class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Salle Card Widget ───
class _SalleCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SalleCard({
    required this.data,
    required this.onEdit,
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
    final equipements = List<String>.from(data['equipements'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: disponible
                            ? [AppColors.primaryNavy, AppColors.primaryNavyLight]
                            : [Colors.grey, Colors.grey.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(type),
                      color: Colors.white,
                      size: 24,
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
                                nom,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: disponible
                                      ? AppColors.textPrimary
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: disponible
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                disponible ? 'Disponible' : 'Indisponible',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: disponible
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (batiment.isNotEmpty) batiment,
                            if (etage.isNotEmpty) 'Étage: $etage',
                          ].join(' • '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit,
                                size: 18, color: AppColors.primaryNavy),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                size: 18, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Info row
              Row(
                children: [
                  const Icon(Icons.people, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$capacite places',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  if (equipements.isNotEmpty) ...[
                    const SizedBox(width: 14),
                    const Icon(Icons.devices,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        equipements.join(', '),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'laboratoire':
        return Icons.science;
      case 'informatique':
        return Icons.computer;
      case 'sport':
        return Icons.sports_soccer;
      case 'bibliothèque':
        return Icons.local_library;
      case 'amphithéâtre':
        return Icons.stadium;
      default:
        return Icons.meeting_room;
    }
  }
}
