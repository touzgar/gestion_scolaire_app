import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ProfEmploiTempsPage extends StatefulWidget {
  const ProfEmploiTempsPage({super.key});

  @override
  State<ProfEmploiTempsPage> createState() => _ProfEmploiTempsPageState();
}

class _ProfEmploiTempsPageState extends State<ProfEmploiTempsPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  int _currentTrimester = 1; // 1, 2, or 3
  final _joursKeys = ['lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'];
  final _joursShort = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
  final _moisNames = ['', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

  @override
  void initState() {
    super.initState();
    _currentTrimester = _getCurrentTrimester();
  }

  int _getCurrentTrimester() {
    final month = DateTime.now().month;
    if (month >= 9 || month <= 12) return 1; // Sept-Dec
    if (month >= 1 && month <= 3) return 2; // Jan-Mar
    return 3; // Apr-Jun
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Column(
        children: [
          _buildHeader(),
          _buildTrimesterSelector(),
          _buildMonthCalendar(),
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is! AuthAuthenticated) return const SizedBox.shrink();
                final profId = state.user.uid;
                return _buildScheduleContent(profId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mon Emploi du Temps',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trimestre $_currentTrimester - ${_moisNames[_currentMonth.month]} ${_currentMonth.year}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _previousMonth,
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _nextMonth,
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _updateTrimester();
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _updateTrimester();
    });
  }

  void _updateTrimester() {
    final month = _currentMonth.month;
    if (month >= 9 || month <= 12) {
      _currentTrimester = 1;
    } else if (month >= 1 && month <= 3) {
      _currentTrimester = 2;
    } else {
      _currentTrimester = 3;
    }
  }

  Widget _buildTrimesterSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: List.generate(3, (index) {
          final trimester = index + 1;
          final isSelected = _currentTrimester == trimester;
          
          String period = '';
          if (trimester == 1) period = 'Sept - Déc';
          if (trimester == 2) period = 'Jan - Mars';
          if (trimester == 3) period = 'Avr - Juin';

          return Expanded(
            child: GestureDetector(
              onTap: () => _selectTrimester(trimester),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Trimestre $trimester',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      period,
                      style: TextStyle(
                        fontSize: 10,
                        color: isSelected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _selectTrimester(int trimester) {
    setState(() {
      _currentTrimester = trimester;
      // Set to first month of trimester
      if (trimester == 1) {
        _currentMonth = DateTime(DateTime.now().year, 9); // September
      } else if (trimester == 2) {
        _currentMonth = DateTime(DateTime.now().year + 1, 1); // January
      } else {
        _currentMonth = DateTime(DateTime.now().year + 1, 4); // April
      }
    });
  }

  Widget _buildMonthCalendar() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = lastDayOfMonth.day;
    final today = DateTime.now();

    // Calculate total cells needed (including empty cells at start)
    final totalCells = firstWeekday - 1 + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Day headers
          Row(
            children: List.generate(7, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    _joursShort[index],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          ...List.generate(rows, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: List.generate(7, (colIndex) {
                  final cellIndex = rowIndex * 7 + colIndex;
                  final dayNumber = cellIndex - (firstWeekday - 2);
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const Expanded(child: SizedBox(height: 40));
                  }

                  final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                  final isSelected = _isSameDay(date, _selectedDate);
                  final isToday = _isSameDay(date, today);
                  final isWeekend = date.weekday == 7; // Sunday

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? const Color(0xFF10B981)
                              : isToday
                                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday && !isSelected
                              ? Border.all(color: const Color(0xFF10B981), width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? const Color(0xFF10B981)
                                      : isWeekend
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(String profId) {
    // Map weekday to jour key: 1=lundi, 2=mardi, ..., 7=dimanche
    int weekdayIndex = _selectedDate.weekday - 1; // 0-6 (lundi-dimanche)
    final selectedDayKey = _joursKeys[weekdayIndex];

    return Column(
      children: [
        // Debug info card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
              Text('Date: $_selectedDate', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
              Text('Weekday: ${_selectedDate.weekday}', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
              Text('Day key: $selectedDayKey', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
              Text('Prof ID: $profId', style: TextStyle(fontSize: 12, color: Colors.blue.shade700)),
            ],
          ),
        ),
        
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('emploi_du_temps')
                .where('jour', isEqualTo: selectedDayKey)
                .snapshots(), // Remove professeurId filter temporarily for debugging
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allDocs = snapshot.data?.docs ?? [];
              
              // Filter by professeurId manually to see all docs first
              final docs = allDocs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return data['professeurId'] == profId;
              }).toList();

              print('Selected date: $_selectedDate');
              print('Weekday: ${_selectedDate.weekday}');
              print('Selected day key: $selectedDayKey');
              print('Total docs for day: ${allDocs.length}');
              print('Docs for this prof: ${docs.length}');
              if (allDocs.isNotEmpty) {
                print('Sample doc: ${(allDocs.first.data() as Map<String, dynamic>)}');
              }

              // Sort by heureDebut
              docs.sort((a, b) {
                final aH = (a.data() as Map<String, dynamic>)['heureDebut'] ?? '';
                final bH = (b.data() as Map<String, dynamic>)['heureDebut'] ?? '';
                return aH.toString().compareTo(bH.toString());
              });

              return Column(
                children: [
                  // Status badge
                  if (docs.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, size: 8, color: Color(0xFFFF6B35)),
                          const SizedBox(width: 6),
                          Text(
                            'EN COURS - ${docs.length} séance(s)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF6B35),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // All sessions info (debug)
                  if (allDocs.isNotEmpty && docs.isEmpty)
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trouvé ${allDocs.length} séance(s) pour $selectedDayKey mais aucune pour ce professeur',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'ProfesseurIds disponibles:',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                          ),
                          ...allDocs.take(3).map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return Text(
                              '- ${data['professeurId'] ?? 'null'} (${data['professeurName'] ?? 'no name'})',
                              style: TextStyle(fontSize: 11, color: Colors.orange.shade700),
                            );
                          }),
                        ],
                      ),
                    ),

                  // Schedule list
                  Expanded(
                    child: docs.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              return _SessionCard(data: data, index: index);
                            },
                          ),
                  ),

                  // Week summary
                  _buildWeekSummary(profId),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final weekdayIndex = _selectedDate.weekday - 1;
    final selectedDayKey = _joursKeys[weekdayIndex];
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.free_breakfast,
              size: 40,
              color: Color(0xFF10B981),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pas de cours ce jour',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune séance pour $selectedDayKey ${_selectedDate.day} ${_moisNames[_selectedDate.month]}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSummary(String profId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emploi_du_temps')
          .where('professeurId', isEqualTo: profId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final allDocs = snapshot.data!.docs;

        // Calculate total hours for trimester
        int totalMinutes = 0;
        int coursCount = 0;

        for (final doc in allDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final heureDebut = data['heureDebut'] ?? '';
          final heureFin = data['heureFin'] ?? '';
          
          if (heureDebut.isNotEmpty && heureFin.isNotEmpty) {
            final debut = _parseTime(heureDebut);
            final fin = _parseTime(heureFin);
            if (debut != null && fin != null) {
              totalMinutes += fin.difference(debut).inMinutes;
              coursCount++;
            }
          }
        }

        final totalHours = totalMinutes ~/ 60;

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
                color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Résumé du Trimestre $_currentTrimester',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryItem(
                      label: 'Total Heures',
                      value: '${totalHours}h',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  Expanded(
                    child: _SummaryItem(
                      label: 'Total Cours',
                      value: '$coursCount',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}

class _SessionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int index;

  const _SessionCard({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final heureDebut = data['heureDebut'] ?? '';
    final heureFin = data['heureFin'] ?? '';
    final matiere = data['matiere'] ?? data['matiereId'] ?? '';
    final className = data['className'] ?? '';
    final salle = data['salle'] ?? '';
    final estAnnule = data['estAnnule'] ?? false;

    // Color based on index
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
    ];
    final color = colors[index % colors.length];

    // Icon based on subject
    IconData icon = Icons.book;
    if (matiere.toLowerCase().contains('math')) {
      icon = Icons.calculate;
    } else if (matiere.toLowerCase().contains('physique') || matiere.toLowerCase().contains('chimie')) {
      icon = Icons.science;
    } else if (matiere.toLowerCase().contains('histoire') || matiere.toLowerCase().contains('géo')) {
      icon = Icons.public;
    } else if (matiere.toLowerCase().contains('français') || matiere.toLowerCase().contains('littérature')) {
      icon = Icons.menu_book;
    } else if (matiere.toLowerCase().contains('anglais') || matiere.toLowerCase().contains('langue')) {
      icon = Icons.language;
    } else if (matiere.toLowerCase().contains('sport') || matiere.toLowerCase().contains('eps')) {
      icon = Icons.sports_soccer;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: estAnnule ? Colors.grey.shade300 : color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: estAnnule ? Colors.transparent : color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Time badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: estAnnule ? Colors.grey.shade200 : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    heureDebut.split(':')[0],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: estAnnule ? Colors.grey : color,
                    ),
                  ),
                  Text(
                    ':${heureDebut.split(':').length > 1 ? heureDebut.split(':')[1] : '00'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: estAnnule ? Colors.grey : color,
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 1,
                    color: estAnnule ? Colors.grey : color,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  Text(
                    heureFin.split(':')[0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: estAnnule ? Colors.grey : color,
                    ),
                  ),
                  Text(
                    ':${heureFin.split(':').length > 1 ? heureFin.split(':')[1] : '00'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: estAnnule ? Colors.grey : color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    matiere,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: estAnnule ? Colors.grey : const Color(0xFF1E293B),
                      decoration: estAnnule ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (salle.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.meeting_room,
                          size: 14,
                          color: estAnnule ? Colors.grey : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          salle,
                          style: TextStyle(
                            fontSize: 12,
                            color: estAnnule ? Colors.grey : const Color(0xFF64748B),
                          ),
                        ),
                        if (className.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Text('•', style: TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  if (className.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 14,
                          color: estAnnule ? Colors.grey : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          className,
                          style: TextStyle(
                            fontSize: 12,
                            color: estAnnule ? Colors.grey : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: estAnnule ? Colors.grey.shade100 : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: estAnnule ? Colors.grey : color,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
