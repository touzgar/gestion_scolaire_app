import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Page de gestion de l'emploi du temps (Admin) - Professional Design
class AdminEmploiTempsPage extends StatefulWidget {
  const AdminEmploiTempsPage({super.key});

  @override
  State<AdminEmploiTempsPage> createState() => _AdminEmploiTempsPageState();
}

class _AdminEmploiTempsPageState extends State<AdminEmploiTempsPage> {
  bool _showCalendarView = true;
  final _jours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
  final _joursKeys = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
  
  String? _selectedClasseId;
  String? _selectedClassName;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Class Selector Card
                  _buildClassSelectorCard(),
                  const SizedBox(height: 24),
                  
                  // Schedule Content
                  if (_selectedClasseId != null) ...[
                    _buildScheduleContent(),
                  ] else
                    _buildEmptyState(),
                ],
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
          const Icon(Icons.calendar_month, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Text(
            'Emploi du Temps',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_selectedClasseId != null) ...[
            // View Toggle
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2D4A6F),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _ViewToggleButton(
                    icon: Icons.calendar_view_week,
                    label: 'Grid',
                    isSelected: _showCalendarView,
                    onTap: () => setState(() => _showCalendarView = true),
                  ),
                  _ViewToggleButton(
                    icon: Icons.view_list,
                    label: 'List',
                    isSelected: !_showCalendarView,
                    onTap: () => setState(() => _showCalendarView = false),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Print Button
            IconButton(
              icon: const Icon(Icons.print, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Print functionality coming soon')),
                );
              },
              tooltip: 'Print Schedule',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.class_, color: Color(0xFF3B82F6), size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Class',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('classes').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final classes = snap.data!.docs.toList()
                ..sort((a, b) {
                  final aN = (a.data() as Map<String, dynamic>)['nom'] ?? '';
                  final bN = (b.data() as Map<String, dynamic>)['nom'] ?? '';
                  return aN.toString().compareTo(bN.toString());
                });

              if (classes.isEmpty) {
                return const Text(
                  'No classes available. Please create classes first.',
                  style: TextStyle(color: Color(0xFF64748B)),
                );
              }

              return DropdownButtonFormField<String>(
                isExpanded: true,
                value: _selectedClasseId,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school, color: Color(0xFF3B82F6)),
                  hintText: 'Choose a class to manage schedule',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 50,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select a class to view schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a class from the dropdown above to manage its timetable',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Schedule Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedClassName ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Weekly Schedule',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => _showAddCreneauDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Schedule Grid or List
        if (_showCalendarView)
          _buildWeeklyCalendar()
        else
          _buildDaysList(),
      ],
    );
  }

  // ─── Weekly Calendar Grid View ───
  Widget _buildWeeklyCalendar() {
    final timeSlots = List.generate(7, (i) => '${(8 + i).toString().padLeft(2, '0')}:00');
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF6B35),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emploi_du_temps')
          .where('classeId', isEqualTo: _selectedClasseId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final docs = snapshot.data?.docs ?? [];
        
        // Group by day
        final Map<String, List<QueryDocumentSnapshot>> byDay = {};
        for (final key in _joursKeys) {
          byDay[key] = [];
        }
        for (final doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          final jour = d['jour'] ?? '';
          byDay.putIfAbsent(jour, () => []).add(doc);
        }

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
              // Day Headers
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 60), // time column
                    ...List.generate(_jours.length, (i) {
                      final isToday = DateTime.now().weekday == i + 1;
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(0xFFFF6B35).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _jours[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isToday ? const Color(0xFFFF6B35) : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              // Time Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: timeSlots.map((time) {
                    final hour = int.parse(time.split(':')[0]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Time label
                            SizedBox(
                              width: 60,
                              child: Text(
                                time,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Day cells
                            ...List.generate(_joursKeys.length, (dayIdx) {
                              final dayCourses = byDay[_joursKeys[dayIdx]] ?? [];
                              final coursesAtTime = dayCourses.where((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                final startH = int.tryParse((d['heureDebut'] ?? '').split(':')[0]) ?? 0;
                                return startH == hour;
                              }).toList();

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  constraints: const BoxConstraints(minHeight: 60),
                                  decoration: BoxDecoration(
                                    color: coursesAtTime.isEmpty
                                        ? const Color(0xFFF8FAFC)
                                        : null,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: coursesAtTime.isEmpty
                                      ? const SizedBox.shrink()
                                      : Column(
                                          children: coursesAtTime.map((doc) {
                                            final d = doc.data() as Map<String, dynamic>;
                                            final matiere = d['matiere'] ?? d['matiereId'] ?? '';
                                            final salle = d['salle'] ?? '';
                                            final prof = d['professeurName'] ?? '';
                                            final estAnnule = d['estAnnule'] ?? false;
                                            final cIdx = docs.indexOf(doc);
                                            final color = colors[cIdx % colors.length];

                                            return InkWell(
                                              onTap: () => _showEditCreneauDialog(doc.id, d),
                                              onLongPress: () => _showSessionMenu(context, doc.id, d),
                                              child: Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: estAnnule
                                                      ? Colors.grey.shade300
                                                      : color,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          matiere,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.white,
                                                            decoration: estAnnule ? TextDecoration.lineThrough : null,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        if (salle.isNotEmpty) ...[
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            '📍 $salle',
                                                            style: const TextStyle(
                                                              fontSize: 9,
                                                              color: Colors.white70,
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                        if (prof.isNotEmpty) ...[
                                                          const SizedBox(height: 2),
                                                          Text(
                                                            '👤 $prof',
                                                            style: const TextStyle(
                                                              fontSize: 9,
                                                              color: Colors.white70,
                                                            ),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: PopupMenuButton<String>(
                                                        icon: const Icon(
                                                          Icons.more_vert,
                                                          size: 14,
                                                          color: Colors.white,
                                                        ),
                                                        padding: EdgeInsets.zero,
                                                        onSelected: (value) {
                                                          if (value == 'edit') {
                                                            _showEditCreneauDialog(doc.id, d);
                                                          } else if (value == 'delete') {
                                                            _confirmDelete(doc.id);
                                                          }
                                                        },
                                                        itemBuilder: (context) => [
                                                          const PopupMenuItem(
                                                            value: 'edit',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.edit, size: 16, color: Color(0xFF3B82F6)),
                                                                SizedBox(width: 8),
                                                                Text('Edit'),
                                                              ],
                                                            ),
                                                          ),
                                                          const PopupMenuItem(
                                                            value: 'delete',
                                                            child: Row(
                                                              children: [
                                                                Icon(Icons.delete, size: 16, color: Colors.red),
                                                                SizedBox(width: 8),
                                                                Text('Delete'),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDaysList() {
    return Column(
      children: _joursKeys.asMap().entries.map((entry) {
        final index = entry.key;
        final jour = entry.value;
        final jourName = _jours[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      jourName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Day Schedule
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('emploi_du_temps')
                    .where('jour', isEqualTo: jour)
                    .where('classeId', isEqualTo: _selectedClasseId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No classes scheduled for $jourName',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }

                  // Sort by heureDebut
                  final docs = snapshot.data!.docs.toList()
                    ..sort((a, b) {
                      final aH = (a.data() as Map<String, dynamic>)['heureDebut'] ?? '';
                      final bH = (b.data() as Map<String, dynamic>)['heureDebut'] ?? '';
                      return aH.toString().compareTo(bH.toString());
                    });

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Add créneau dialog ───
  void _showAddCreneauDialog() {
    final matiereCtrl = TextEditingController();
    final salleCtrl = TextEditingController();
    String heureDebut = '08:00';
    String heureFin = '09:00';
    String selectedJour = _joursKeys[0];
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
                    color: const Color(0xFF1E3A5F).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add_circle,
                    color: Color(0xFF1E3A5F),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Add New Entry',
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
                        color: const Color(0xFF1E3A5F).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.class_,
                            size: 18,
                            color: Color(0xFF1E3A5F),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Class: $_selectedClassName',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jour dropdown
                    DropdownButtonFormField<String>(
                      value: selectedJour,
                      decoration: const InputDecoration(
                        labelText: 'Day',
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
                        labelText: 'Subject',
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
                        if (!snap.hasData) {
                          return const LinearProgressIndicator();
                        }
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
                          value: selectedProfId,
                          decoration: const InputDecoration(
                            labelText: 'Teacher',
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
                            label: 'Start',
                            value: heureDebut,
                            onChanged: (v) =>
                                setDialogState(() => heureDebut = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimePickerField(
                            label: 'End',
                            value: heureFin,
                            onChanged: (v) =>
                                setDialogState(() => heureFin = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Salle dropdown from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salles')
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final sallesDocs = snap.data!.docs;
                        
                        if (sallesDocs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'No rooms available. Create rooms first.',
                                    style: TextStyle(fontSize: 12, color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: null,
                          decoration: const InputDecoration(
                            labelText: 'Room (optional)',
                            prefixIcon: Icon(Icons.meeting_room),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('— None —'),
                            ),
                            ...sallesDocs.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final nom = d['nom'] ?? 'Room ${doc.id}';
                              final capacite = d['capacite'] ?? 0;
                              return DropdownMenuItem<String>(
                                value: nom,
                                child: Text('$nom${capacite > 0 ? ' ($capacite seats)' : ''}'),
                              );
                            }),
                          ],
                          onChanged: (v) => setDialogState(() => salleCtrl.text = v ?? ''),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                ),
                onPressed: () async {
                  if (matiereCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a subject'),
                        backgroundColor: Color(0xFFEF4444),
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
                        content: Text('Entry added successfully ✓'),
                        backgroundColor: Color(0xFF10B981),
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
                    color: const Color(0xFFFF6B35).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFFFF6B35),
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

                    // Salle dropdown from Firestore
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('salles')
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        
                        final sallesDocs = snap.data!.docs;
                        
                        if (sallesDocs.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Aucune salle disponible. Créez des salles d\'abord.',
                                    style: TextStyle(fontSize: 12, color: Colors.orange),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        final currentSalle = salleCtrl.text.trim();
                        
                        return DropdownButtonFormField<String>(
                          isExpanded: true,
                          value: currentSalle.isEmpty ? '' : currentSalle,
                          decoration: const InputDecoration(
                            labelText: 'Salle (optionnel)',
                            prefixIcon: Icon(Icons.meeting_room),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: '',
                              child: Text('— Aucune —'),
                            ),
                            ...sallesDocs.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final nom = d['nom'] ?? 'Salle ${doc.id}';
                              final capacite = d['capacite'] ?? 0;
                              return DropdownMenuItem<String>(
                                value: nom,
                                child: Text('$nom${capacite > 0 ? ' ($capacite pl.)' : ''}'),
                              );
                            }),
                          ],
                          onChanged: (v) => setDialogState(() => salleCtrl.text = v ?? ''),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Annulé switch
                    SwitchListTile(
                      title: const Text('Cours annulé'),
                      subtitle: const Text('Marquer comme annulé'),
                      value: estAnnule,
                      activeTrackColor: const Color(0xFFEF4444).withOpacity(0.4),
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
                        backgroundColor: const Color(0xFFEF4444),
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
                        backgroundColor: const Color(0xFF10B981),
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

  // ─── Show session menu ───
  void _showSessionMenu(BuildContext context, String docId, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              data['matiere'] ?? 'Session',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditCreneauDialog(docId, data);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(docId);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
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
                color: const Color(0xFFEF4444).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Entry'),
          ],
        ),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
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
            content: Text('Entry deleted'),
            backgroundColor: Color(0xFF10B981),
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
            Icon(Icons.info_outline, color: Color(0xFF1E3A5F)),
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

// ─── View Toggle Button Widget ───
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFFF6B35),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];
    final color = colors[index % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Time badge
              Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: estAnnule ? Colors.grey : color,
                  borderRadius: BorderRadius.circular(10),
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
                                  : const Color(0xFF1E293B),
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
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Cancelled',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFEF4444),
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
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
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
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Room $salle',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
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
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFEF4444)),
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
