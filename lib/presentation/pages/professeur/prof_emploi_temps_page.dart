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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final profId = state.user.uid;
        
        return Container(
          color: const Color(0xFFF5F7FA),
          child: Column(
            children: [
              _buildHeader(),
              _buildTrimesterSelector(),
              _buildMonthCalendar(),
              Expanded(
                child: _buildScheduleContent(profId),
              ),
            ],
          ),
        );
      },
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

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final profId = state.user.uid;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('emploi_du_temps')
              .where('professeurId', isEqualTo: profId)
              .snapshots(),
          builder: (context, snapshot) {
            final allSessions = snapshot.data?.docs ?? [];
            
            // Group sessions by date
            Map<String, List<Map<String, dynamic>>> sessionsByDay = {};
            for (var doc in allSessions) {
              final data = doc.data() as Map<String, dynamic>;
              final jour = data['jour'] ?? '';
              if (!sessionsByDay.containsKey(jour)) {
                sessionsByDay[jour] = [];
              }
              sessionsByDay[jour]!.add(data);
            }

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(7, (colIndex) {
                          final cellIndex = rowIndex * 7 + colIndex;
                          final dayNumber = cellIndex - (firstWeekday - 2);
                          
                          if (dayNumber < 1 || dayNumber > daysInMonth) {
                            return const Expanded(child: SizedBox(height: 50));
                          }

                          final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
                          final isSelected = _isSameDay(date, _selectedDate);
                          final isToday = _isSameDay(date, today);
                          final isWeekend = date.weekday == 7; // Sunday
                          
                          // Get sessions for this day
                          final dayKey = _joursKeys[date.weekday - 1];
                          final daySessions = sessionsByDay[dayKey] ?? [];
                          final sessionCount = daySessions.length;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedDate = date),
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF10B981)
                                      : isToday
                                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isToday && !isSelected
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFE2E8F0),
                                    width: isToday && !isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    // Day number
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontSize: 12,
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
                                    // Session count badge
                                    if (sessionCount > 0)
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? Colors.white
                                                : const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '$sessionCount',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected 
                                                  ? const Color(0xFF10B981)
                                                  : Colors.white,
                                            ),
                                          ),
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
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScheduleContent(String profId) {
    // Map weekday to jour key: 1=lundi, 2=mardi, ..., 7=dimanche
    int weekdayIndex = _selectedDate.weekday - 1; // 0-6 (lundi-dimanche)
    final selectedDayKey = _joursKeys[weekdayIndex];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emploi_du_temps')
          .where('jour', isEqualTo: selectedDayKey)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        final allDocs = snapshot.data?.docs ?? [];
        
        // Filter by professeurId manually
        final docs = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['professeurId'] == profId;
        }).toList();

        // Sort by heureDebut
        docs.sort((a, b) {
          final aH = (a.data() as Map<String, dynamic>)['heureDebut'] ?? '';
          final bH = (b.data() as Map<String, dynamic>)['heureDebut'] ?? '';
          return aH.toString().compareTo(bH.toString());
        });

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return Container(
          color: const Color(0xFFF5F7FA),
          child: Column(
            children: [
              // Day header with date
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: const Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_joursKeys[weekdayIndex].toUpperCase()} ${_selectedDate.day} ${_moisNames[_selectedDate.month]}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '${docs.length} séance(s) programmée(s)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Time-based schedule grid
              Expanded(
                child: _buildTimeGrid(docs),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeGrid(List<QueryDocumentSnapshot> docs) {
    // Define time slots from 8h to 18h
    final timeSlots = List.generate(11, (index) => 8 + index); // 8h to 18h

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final hour = timeSlots[index];
        
        // Find sessions that start in this hour
        final sessionsInHour = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final heureDebut = data['heureDebut'] ?? '';
          if (heureDebut.isEmpty) return false;
          final startHour = int.tryParse(heureDebut.split(':')[0]) ?? 0;
          return startHour == hour;
        }).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time label
              SizedBox(
                width: 60,
                child: Text(
                  '${hour}h00',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              // Sessions or empty slot
              Expanded(
                child: sessionsInHour.isEmpty
                    ? Container(
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Column(
                        children: sessionsInHour.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return _TimeSlotCard(data: data);
                        }).toList(),
                      ),
              ),
            ],
          ),
        );
      },
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

}

class _TimeSlotCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TimeSlotCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final heureDebut = data['heureDebut'] ?? '';
    final heureFin = data['heureFin'] ?? '';
    final matiere = data['matiere'] ?? data['matiereId'] ?? '';
    final className = data['className'] ?? '';
    final salle = data['salle'] ?? '';

    // Calculate duration in minutes
    int durationMinutes = 60; // default
    if (heureDebut.isNotEmpty && heureFin.isNotEmpty) {
      try {
        final startParts = heureDebut.split(':');
        final endParts = heureFin.split(':');
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
        durationMinutes = endMinutes - startMinutes;
      } catch (e) {
        // Keep default
      }
    }

    // Height based on duration (1 minute = 1 pixel, minimum 60px)
    final height = durationMinutes.toDouble().clamp(60.0, 300.0);

    // Color based on subject
    Color color = const Color(0xFF10B981);
    if (matiere.toLowerCase().contains('math')) {
      color = const Color(0xFF6366F1);
    } else if (matiere.toLowerCase().contains('physique') || matiere.toLowerCase().contains('chimie')) {
      color = const Color(0xFFEC4899);
    } else if (matiere.toLowerCase().contains('français') || matiere.toLowerCase().contains('littérature')) {
      color = const Color(0xFFF59E0B);
    } else if (matiere.toLowerCase().contains('anglais') || matiere.toLowerCase().contains('langue')) {
      color = const Color(0xFF8B5CF6);
    } else if (matiere.toLowerCase().contains('histoire') || matiere.toLowerCase().contains('géo')) {
      color = const Color(0xFF3B82F6);
    }

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time range
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  '$heureDebut - $heureFin',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Subject
            Text(
              matiere,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Room and class
            Row(
              children: [
                if (salle.isNotEmpty) ...[
                  Icon(Icons.meeting_room, size: 12, color: const Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Text(
                    salle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
                if (salle.isNotEmpty && className.isNotEmpty)
                  const Text(' • ', style: TextStyle(color: Color(0xFF64748B))),
                if (className.isNotEmpty) ...[
                  Icon(Icons.people, size: 12, color: const Color(0xFF64748B)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      className,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
