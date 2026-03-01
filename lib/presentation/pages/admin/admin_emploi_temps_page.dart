import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Page de gestion de l'emploi du temps (Admin)
class AdminEmploiTempsPage extends StatefulWidget {
  const AdminEmploiTempsPage({super.key});

  @override
  State<AdminEmploiTempsPage> createState() => _AdminEmploiTempsPageState();
}

class _AdminEmploiTempsPageState extends State<AdminEmploiTempsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  final _joursKeys = [
    'lundi',
    'mardi',
    'mercredi',
    'jeudi',
    'vendredi',
    'samedi',
  ];

  String? _selectedClasseId;
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    final initialIndex = (today >= 1 && today <= 6) ? today - 1 : 0;
    _tabController = TabController(
      length: 6,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emploi du Temps'),
        actions: [
          if (_selectedClasseId != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(),
              ),
            ),
        ],
        bottom: _selectedClasseId != null
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.accentOrange,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: _jours.map((j) => Tab(text: j)).toList(),
              )
            : null,
      ),
      floatingActionButton: _selectedClasseId != null
          ? FloatingActionButton.extended(
              onPressed: () => _showAddCreneauDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter'),
            )
          : null,
      body: Column(
        children: [
          // ─── Class selector ───
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('classes')
                  .snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const LinearProgressIndicator();
                }
                final classes = snap.data!.docs.toList()
                  ..sort((a, b) {
                    final aN = (a.data() as Map<String, dynamic>)['nom'] ?? '';
                    final bN = (b.data() as Map<String, dynamic>)['nom'] ?? '';
                    return aN.toString().compareTo(bN.toString());
                  });

                if (classes.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune classe. Créez des classes d\'abord.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  // ignore: deprecated_member_use
                  value: _selectedClasseId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.class_),
                    labelText: 'Sélectionner une classe',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: classes.map((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    final label = '${d['nom'] ?? ''} (${d['niveau'] ?? ''})';
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final doc = classes.firstWhere((d) => d.id == val);
                      final d = doc.data() as Map<String, dynamic>;
                      setState(() {
                        _selectedClasseId = val;
                        _selectedClassName = d['nom'] ?? '';
                      });
                    }
                  },
                );
              },
            ),
          ),

          // ─── Schedule content ───
          if (_selectedClasseId == null)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        size: 44,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Sélectionnez une classe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'pour gérer son emploi du temps',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _joursKeys
                    .map((jour) => _buildDaySchedule(jour))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String jour) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emploi_du_temps')
          .where('jour', isEqualTo: jour)
          .where('classeId', isEqualTo: _selectedClasseId)
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
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'Aucun créneau pour ${jour.toLowerCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Appuyez sur + pour ajouter',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Sort by heureDebut in Dart
        final docs = snapshot.data!.docs.toList()
          ..sort((a, b) {
            final aH = (a.data() as Map<String, dynamic>)['heureDebut'] ?? '';
            final bH = (b.data() as Map<String, dynamic>)['heureDebut'] ?? '';
            return aH.toString().compareTo(bH.toString());
          });

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return _CreneauCard(
              data: data,
              docId: doc.id,
              index: index,
              onEdit: () => _showEditCreneauDialog(doc.id, data),
              onDelete: () => _confirmDelete(doc.id),
            );
          },
        );
      },
    );
  }

  // ─── Add créneau dialog ───
  void _showAddCreneauDialog() {
    final matiereCtrl = TextEditingController();
    final salleCtrl = TextEditingController();
    String heureDebut = '08:00';
    String heureFin = '09:00';
    String selectedJour = _joursKeys[_tabController.index];
    String? selectedProfId;
    String? selectedProfName;

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_circle,
                    color: AppColors.primaryNavy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Ajouter un créneau',
                    style: TextStyle(fontSize: 18),
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
                    // Classe info
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.class_,
                            size: 18,
                            color: AppColors.primaryNavy,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Classe: $_selectedClassName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jour dropdown
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedJour,
                      decoration: const InputDecoration(
                        labelText: 'Jour',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: List.generate(_jours.length, (i) {
                        return DropdownMenuItem(
                          value: _joursKeys[i],
                          child: Text(_jours[i]),
                        );
                      }),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedJour = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Matière
                    TextField(
                      controller: matiereCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Matière',
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Professeur dropdown
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('utilisateurs')
                          .where('role', isEqualTo: 'professeur')
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData)
                          return const LinearProgressIndicator();
                        final profs = snap.data!.docs.toList()
                          ..sort((a, b) {
                            final aN =
                                (a.data() as Map<String, dynamic>)['nom'] ?? '';
                            final bN =
                                (b.data() as Map<String, dynamic>)['nom'] ?? '';
                            return aN.toString().compareTo(bN.toString());
                          });

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          // ignore: deprecated_member_use
                          value: selectedProfId,
                          decoration: const InputDecoration(
                            labelText: 'Professeur',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: profs.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final name =
                                '${d['prenom'] ?? ''} ${d['nom'] ?? ''}';
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedProfId = val;
                              if (val != null) {
                                final p = profs.firstWhere((d) => d.id == val);
                                final d = p.data() as Map<String, dynamic>;
                                selectedProfName = '${d['prenom']} ${d['nom']}';
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Heures
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerField(
                            label: 'Début',
                            value: heureDebut,
                            onChanged: (v) =>
                                setDialogState(() => heureDebut = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimePickerField(
                            label: 'Fin',
                            value: heureFin,
                            onChanged: (v) =>
                                setDialogState(() => heureFin = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Salle
                    TextField(
                      controller: salleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Salle (optionnel)',
                        prefixIcon: Icon(Icons.room),
                      ),
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
                label: const Text('Ajouter'),
                onPressed: () async {
                  if (matiereCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez entrer une matière'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('emploi_du_temps')
                      .add({
                        'classeId': _selectedClasseId,
                        'className': _selectedClassName ?? '',
                        'jour': selectedJour,
                        'matiere': matiereCtrl.text.trim(),
                        'matiereId': matiereCtrl.text.trim(),
                        'professeurId': selectedProfId ?? '',
                        'professeurName': selectedProfName ?? '',
                        'heureDebut': heureDebut,
                        'heureFin': heureFin,
                        'salle': salleCtrl.text.trim(),
                        'estAnnule': false,
                        'anneeScolaire': '2025-2026',
                      });

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Créneau ajouté avec succès ✓'),
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

  // ─── Edit créneau dialog ───
  void _showEditCreneauDialog(String docId, Map<String, dynamic> data) {
    final matiereCtrl = TextEditingController(
      text: data['matiere'] ?? data['matiereId'] ?? '',
    );
    final salleCtrl = TextEditingController(text: data['salle'] ?? '');
    String heureDebut = data['heureDebut'] ?? '08:00';
    String heureFin = data['heureFin'] ?? '09:00';
    String selectedJour = data['jour'] ?? 'lundi';
    String? selectedProfId = data['professeurId'];
    String? selectedProfName = data['professeurName'];
    bool estAnnule = data['estAnnule'] ?? false;

    if (selectedProfId != null && selectedProfId.isEmpty) {
      selectedProfId = null;
    }

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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Modifier le créneau',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Jour dropdown
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: selectedJour,
                      decoration: const InputDecoration(
                        labelText: 'Jour',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: List.generate(_jours.length, (i) {
                        return DropdownMenuItem(
                          value: _joursKeys[i],
                          child: Text(_jours[i]),
                        );
                      }),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedJour = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Matière
                    TextField(
                      controller: matiereCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Matière',
                        prefixIcon: Icon(Icons.book),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Professeur dropdown
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('utilisateurs')
                          .where('role', isEqualTo: 'professeur')
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData)
                          return const LinearProgressIndicator();
                        final profs = snap.data!.docs.toList()
                          ..sort((a, b) {
                            final aN =
                                (a.data() as Map<String, dynamic>)['nom'] ?? '';
                            final bN =
                                (b.data() as Map<String, dynamic>)['nom'] ?? '';
                            return aN.toString().compareTo(bN.toString());
                          });

                        // Validate selectedProfId exists in list
                        final validProfIds = profs.map((d) => d.id).toSet();
                        final currentProfId =
                            validProfIds.contains(selectedProfId)
                            ? selectedProfId
                            : null;

                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          // ignore: deprecated_member_use
                          value: currentProfId,
                          decoration: const InputDecoration(
                            labelText: 'Professeur',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: profs.map((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            final name =
                                '${d['prenom'] ?? ''} ${d['nom'] ?? ''}';
                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setDialogState(() {
                              selectedProfId = val;
                              if (val != null) {
                                final p = profs.firstWhere((d) => d.id == val);
                                final d = p.data() as Map<String, dynamic>;
                                selectedProfName = '${d['prenom']} ${d['nom']}';
                              }
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Heures
                    Row(
                      children: [
                        Expanded(
                          child: _TimePickerField(
                            label: 'Début',
                            value: heureDebut,
                            onChanged: (v) =>
                                setDialogState(() => heureDebut = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimePickerField(
                            label: 'Fin',
                            value: heureFin,
                            onChanged: (v) =>
                                setDialogState(() => heureFin = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Salle
                    TextField(
                      controller: salleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Salle (optionnel)',
                        prefixIcon: Icon(Icons.room),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Annulé switch
                    SwitchListTile(
                      title: const Text('Cours annulé'),
                      subtitle: const Text('Marquer comme annulé'),
                      value: estAnnule,
                      activeTrackColor: AppColors.error.withValues(alpha: 0.4),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setDialogState(() => estAnnule = v),
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
                  if (matiereCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Veuillez entrer une matière'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  await FirebaseFirestore.instance
                      .collection('emploi_du_temps')
                      .doc(docId)
                      .update({
                        'jour': selectedJour,
                        'matiere': matiereCtrl.text.trim(),
                        'matiereId': matiereCtrl.text.trim(),
                        'professeurId': selectedProfId ?? '',
                        'professeurName': selectedProfName ?? '',
                        'heureDebut': heureDebut,
                        'heureFin': heureFin,
                        'salle': salleCtrl.text.trim(),
                        'estAnnule': estAnnule,
                      });

                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Créneau modifié ✓'),
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

  // ─── Delete créneau ───
  Future<void> _confirmDelete(String docId) async {
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
        content: const Text('Voulez-vous vraiment supprimer ce créneau ?'),
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
          .collection('emploi_du_temps')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Créneau supprimé'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primaryNavy),
            SizedBox(width: 8),
            Text('Gestion Emploi du Temps'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Sélectionnez une classe'),
            SizedBox(height: 4),
            Text('2. Choisissez le jour de la semaine'),
            SizedBox(height: 4),
            Text('3. Ajoutez des créneaux avec matière, prof, heures, salle'),
            SizedBox(height: 4),
            Text('4. Les élèves et professeurs verront leur emploi du temps'),
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

// ─── Créneau Card Widget ───
class _CreneauCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CreneauCard({
    required this.data,
    required this.docId,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final heureDebut = data['heureDebut'] ?? '';
    final heureFin = data['heureFin'] ?? '';
    final matiere = data['matiere'] ?? data['matiereId'] ?? '';
    final profName = data['professeurName'] ?? '';
    final salle = data['salle'] ?? '';
    final estAnnule = data['estAnnule'] ?? false;

    final colors = [
      AppColors.roleEleve,
      AppColors.roleProfesseur,
      AppColors.accentOrange,
      AppColors.roleAdmin,
      AppColors.info,
      AppColors.success,
    ];
    final color = colors[index % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time badge
              Container(
                width: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: estAnnule
                        ? [Colors.grey, Colors.grey.shade400]
                        : [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      heureDebut,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const Text(
                      '—',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      heureFin,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
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
                            matiere,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              decoration: estAnnule
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: estAnnule
                                  ? Colors.grey
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (estAnnule)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Annulé',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (profName.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (salle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.room,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Salle $salle',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Supprimer',
                      style: TextStyle(color: AppColors.error),
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
}

// ─── Time Picker Field Widget ───
class _TimePickerField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final parts = value.split(':');
        final hour = int.tryParse(parts[0]) ?? 8;
        final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
        if (picked != null) {
          final h = picked.hour.toString().padLeft(2, '0');
          final m = picked.minute.toString().padLeft(2, '0');
          onChanged('$h:$m');
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.access_time),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        child: Text(value),
      ),
    );
  }
}
