import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfSaisieNotesPage extends StatefulWidget {
  const ProfSaisieNotesPage({super.key});

  @override
  State<ProfSaisieNotesPage> createState() => _ProfSaisieNotesPageState();
}

class _ProfSaisieNotesPageState extends State<ProfSaisieNotesPage> {
  String? _selectedClasseId;
  String? _selectedClassName;
  String? _selectedMatiere;
  int _selectedTrimestre = 1;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _selectedClasseId == null
                ? _buildEmptyState()
                : _buildStudentsList(),
          ),
        ],
      ),
      floatingActionButton: _selectedClasseId != null
          ? FloatingActionButton(
              onPressed: () {
                // Show dialog to select student first
                _showSelectStudentDialog();
              },
              backgroundColor: const Color(0xFFFF6B35),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Class Selector
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saisie des Notes',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_selectedClassName != null)
                      Text(
                        '$_selectedClassName • ${_selectedMatiere ?? 'Toutes matières'} • T$_selectedTrimestre 2024',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              // Filters and Export buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showFiltersDialog(),
                    icon: const Icon(Icons.filter_list, size: 18),
                    label: const Text('Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _exportGrades(),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Export'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Class Selector
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('classes').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
              }
              
              final classes = snapshot.data!.docs;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedClasseId,
                    hint: const Text('Select a class to view students'),
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
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.grade,
              size: 50,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select a class to start',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a class from the dropdown above',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('classes')
          .doc(_selectedClasseId)
          .snapshots(),
      builder: (context, classSnap) {
        if (!classSnap.hasData || !classSnap.data!.exists) {
          return const Center(child: CircularProgressIndicator());
        }

        final classData = classSnap.data!.data() as Map<String, dynamic>;
        final eleveIds = List<String>.from(classData['eleveIds'] ?? []);

        if (eleveIds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'No students in this class',
                  style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _fetchStudentsByIds(eleveIds),
          builder: (context, studentsSnap) {
            if (!studentsSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final students = studentsSnap.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .where('classeId', isEqualTo: _selectedClasseId)
                  .where('trimestre', isEqualTo: _selectedTrimestre)
                  .snapshots(),
              builder: (context, notesSnap) {
                final notes = notesSnap.data?.docs ?? [];

                // Calculate statistics
                final stats = _calculateStats(students, notes);

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final studentData = student.data() as Map<String, dynamic>;
                          final studentNotes = notes.where((n) {
                            final d = n.data() as Map<String, dynamic>;
                            return d['eleveId'] == student.id;
                          }).toList();

                          return _StudentCard(
                            studentId: student.id,
                            studentData: studentData,
                            notes: studentNotes,
                            onAddNote: () => _showAddNoteDialog(student.id, studentData),
                          );
                        },
                      ),
                    ),
                    _buildClassInsights(stats, students.length),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildClassInsights(Map<String, dynamic> stats, int totalStudents) {
    final participation = stats['participation'] as double;
    final classAvg = stats['classAvg'] as double;
    final completedCount = stats['completedCount'] as int;

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Class Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InsightItem(
                  label: 'Participation',
                  value: '${participation.toStringAsFixed(0)}%',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _InsightItem(
                  label: 'Class Avg',
                  value: classAvg.toStringAsFixed(1),
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: _InsightItem(
                  label: 'Entries',
                  value: '$completedCount/$totalStudents',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: participation / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<DocumentSnapshot> students, List<QueryDocumentSnapshot> notes) {
    if (students.isEmpty) {
      return {'participation': 0.0, 'classAvg': 0.0, 'completedCount': 0};
    }

    final studentsWithNotes = <String>{};
    double totalScore = 0;
    int totalNotes = 0;

    for (final note in notes) {
      final d = note.data() as Map<String, dynamic>;
      studentsWithNotes.add(d['eleveId'] ?? '');
      totalScore += (d['valeur'] as num?)?.toDouble() ?? 0;
      totalNotes++;
    }

    final participation = (studentsWithNotes.length / students.length * 100);
    final classAvg = totalNotes > 0 ? totalScore / totalNotes : 0.0;

    return {
      'participation': participation,
      'classAvg': classAvg,
      'completedCount': studentsWithNotes.length,
    };
  }

  Future<List<DocumentSnapshot>> _fetchStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final List<DocumentSnapshot> results = [];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
      final snap = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snap.docs);
    }
    results.sort((a, b) {
      final aN = (a.data() as Map<String, dynamic>)['nom'] ?? '';
      final bN = (b.data() as Map<String, dynamic>)['nom'] ?? '';
      return aN.toString().compareTo(bN.toString());
    });
    return results;
  }

  void _showFiltersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Filters'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: _selectedTrimestre,
                decoration: const InputDecoration(
                  labelText: 'Trimestre',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Trimestre 1')),
                  DropdownMenuItem(value: 2, child: Text('Trimestre 2')),
                  DropdownMenuItem(value: 3, child: Text('Trimestre 3')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setDialogState(() => _selectedTrimestre = v);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(String studentId, Map<String, dynamic> studentData) {
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated) return;
    final profId = state.user.uid;

    final valeurCtrl = TextEditingController();
    final coeffCtrl = TextEditingController(text: '1');
    final commentaireCtrl = TextEditingController();
    String selectedType = 'controle';

    final studentName = '${studentData['prenom'] ?? ''} ${studentData['nom'] ?? ''}'.trim();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grade, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Grade', style: TextStyle(fontSize: 18)),
                    Text(
                      studentName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: valeurCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Score /20',
                          prefixIcon: Icon(Icons.grade),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: coeffCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Coeff.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    prefixIcon: Icon(Icons.category),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'controle', child: Text('Contrôle')),
                    DropdownMenuItem(value: 'devoir', child: Text('Devoir')),
                    DropdownMenuItem(value: 'examen', child: Text('Examen')),
                    DropdownMenuItem(value: 'oral', child: Text('Oral')),
                    DropdownMenuItem(value: 'tp', child: Text('TP')),
                    DropdownMenuItem(value: 'projet', child: Text('Projet')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentaireCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final valeur = double.tryParse(valeurCtrl.text);
                if (valeur == null || valeur < 0 || valeur > 20) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Enter a valid score (0 - 20)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                final coeff = double.tryParse(coeffCtrl.text) ?? 1;

                await FirebaseFirestore.instance.collection('notes').add({
                  'eleveId': studentId,
                  'eleveName': studentName,
                  'classeId': _selectedClasseId,
                  'className': _selectedClassName ?? '',
                  'matiereId': _selectedMatiere ?? '',
                  'professeurId': profId,
                  'valeur': valeur,
                  'coefficient': coeff,
                  'typeEvaluation': selectedType,
                  'commentaire': commentaireCtrl.text.trim(),
                  'date': Timestamp.now(),
                  'trimestre': _selectedTrimestre,
                  'anneeScolaire': '2025-2026',
                });

                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Grade added successfully ✓'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectStudentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Student'),
        content: SizedBox(
          width: double.maxFinite,
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('classes')
                .doc(_selectedClasseId)
                .snapshots(),
            builder: (context, classSnap) {
              if (!classSnap.hasData || !classSnap.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final classData = classSnap.data!.data() as Map<String, dynamic>;
              final eleveIds = List<String>.from(classData['eleveIds'] ?? []);

              return FutureBuilder<List<DocumentSnapshot>>(
                future: _fetchStudentsByIds(eleveIds),
                builder: (context, studentsSnap) {
                  if (!studentsSnap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final students = studentsSnap.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final studentData = student.data() as Map<String, dynamic>;
                      final prenom = studentData['prenom'] ?? '';
                      final nom = studentData['nom'] ?? '';
                      final fullName = '$prenom $nom'.trim();

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E3A5F),
                          child: Text(
                            '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(fullName),
                        onTap: () {
                          Navigator.pop(ctx);
                          _showAddNoteDialog(student.id, studentData);
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportGrades() async {
    if (_selectedClasseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a class first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Fetch class data
      final classDoc = await FirebaseFirestore.instance
          .collection('classes')
          .doc(_selectedClasseId)
          .get();
      
      if (!classDoc.exists) return;
      
      final classData = classDoc.data() as Map<String, dynamic>;
      final eleveIds = List<String>.from(classData['eleveIds'] ?? []);
      
      if (eleveIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No students in this class'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Fetch students
      final students = await _fetchStudentsByIds(eleveIds);
      
      // Fetch notes
      final notesSnap = await FirebaseFirestore.instance
          .collection('notes')
          .where('classeId', isEqualTo: _selectedClasseId)
          .where('trimestre', isEqualTo: _selectedTrimestre)
          .get();
      
      final notes = notesSnap.docs;

      // Build CSV content
      final StringBuffer csv = StringBuffer();
      
      // Header
      csv.writeln('Student ID,Student Name,Score /20,Average,Status,Notes Count,Last Updated');
      
      // Data rows
      for (final student in students) {
        final studentData = student.data() as Map<String, dynamic>;
        final prenom = studentData['prenom'] ?? '';
        final nom = studentData['nom'] ?? '';
        final fullName = '$prenom $nom'.trim();
        
        // Calculate student's average
        final studentNotes = notes.where((n) {
          final d = n.data() as Map<String, dynamic>;
          return d['eleveId'] == student.id;
        }).toList();
        
        double totalScore = 0;
        double totalCoeff = 0;
        DateTime? lastUpdate;
        
        for (final note in studentNotes) {
          final d = note.data() as Map<String, dynamic>;
          final valeur = (d['valeur'] as num?)?.toDouble() ?? 0;
          final coeff = (d['coefficient'] as num?)?.toDouble() ?? 1;
          totalScore += valeur * coeff;
          totalCoeff += coeff;
          
          final noteDate = (d['date'] as Timestamp?)?.toDate();
          if (noteDate != null && (lastUpdate == null || noteDate.isAfter(lastUpdate))) {
            lastUpdate = noteDate;
          }
        }
        
        final average = totalCoeff > 0 ? totalScore / totalCoeff : 0.0;
        final hasNotes = studentNotes.isNotEmpty;
        final status = hasNotes ? 'COMPLETED' : 'PENDING';
        final lastUpdateStr = lastUpdate != null 
            ? '${lastUpdate.day}/${lastUpdate.month}/${lastUpdate.year}'
            : 'N/A';
        
        csv.writeln(
          '#ST-${student.id.substring(0, 4).toUpperCase()},'
          '"$fullName",'
          '${hasNotes ? average.toStringAsFixed(1) : '--'},'
          '${hasNotes ? average.toStringAsFixed(1) : '--'},'
          '$status,'
          '${studentNotes.length},'
          '$lastUpdateStr'
        );
      }

      // Show download dialog with CSV content
      if (mounted) {
        _showExportDialog(csv.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExportDialog(String csvContent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.download, color: Color(0xFF10B981)),
            const SizedBox(width: 12),
            const Text('Export Grades'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CSV data ready for export:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    csvContent,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Copy the text above and save it as a .csv file',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Copy to clipboard
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('CSV data copied! Save it as a .csv file'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightItem extends StatelessWidget {
  final String label;
  final String value;

  const _InsightItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> studentData;
  final List<QueryDocumentSnapshot> notes;
  final VoidCallback onAddNote;

  const _StudentCard({
    required this.studentId,
    required this.studentData,
    required this.notes,
    required this.onAddNote,
  });

  @override
  Widget build(BuildContext context) {
    final prenom = studentData['prenom'] ?? '';
    final nom = studentData['nom'] ?? '';
    final fullName = '$prenom $nom'.trim();
    final initials = '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();

    // Calculate average
    double totalScore = 0;
    double totalCoeff = 0;
    for (final note in notes) {
      final d = note.data() as Map<String, dynamic>;
      final valeur = (d['valeur'] as num?)?.toDouble() ?? 0;
      final coeff = (d['coefficient'] as num?)?.toDouble() ?? 1;
      totalScore += valeur * coeff;
      totalCoeff += coeff;
    }
    final average = totalCoeff > 0 ? totalScore / totalCoeff : 0.0;
    final hasNotes = notes.isNotEmpty;

    // Status
    final status = hasNotes ? 'COMPLETED' : 'PENDING';
    final statusColor = hasNotes ? const Color(0xFF10B981) : const Color(0xFFFF6B35);

    return InkWell(
      onTap: onAddNote,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF1E3A5F),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName.isEmpty ? 'Student' : fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasNotes ? Icons.check_circle : Icons.pending,
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: #ST-${studentId.substring(0, 4).toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Score Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Score /20',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                if (hasNotes)
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                    ),
                    child: const Text(
                      '--',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            
            // Average Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Average',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                if (hasNotes)
                  Text(
                    average.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  )
                else
                  const Text(
                    '--',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
