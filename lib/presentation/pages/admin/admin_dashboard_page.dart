import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csv/csv.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import 'users_management_page.dart';
import 'classes_management_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName = state is AuthAuthenticated ? state.user.nomComplet : 'Admin';
        
        return Container(
          color: const Color(0xFFF5F7FA),
          child: Column(
            children: [
              // Dark Navy Header with Search
              _buildHeader(context),
              
              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dashboard refreshed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        _WelcomeCard(userName: userName),
                        const SizedBox(height: 32),

                        // Stats Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Vue d\'ensemble',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                _showAnalyticsDialog(context);
                              },
                              icon: const Icon(Icons.analytics_outlined, size: 18),
                              label: const Text('View Analytics'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFFF6B35),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Stats Grid
                        _buildStatsGrid(),
                        const SizedBox(height: 32),

                        // Recent Users Section
                        _buildRecentUsersSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _performSearch(context, value);
                  }
                },
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search dashboard...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 20),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Icons
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              _showNotifications(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () {
              _showHelp(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              _showSettings(context);
            },
          ),
          const SizedBox(width: 8),
          
          // Profile Avatar
          PopupMenuButton<String>(
            offset: const Offset(0, 50),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFF6B35),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, size: 18),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              _handleProfileMenu(context, value);
            },
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search Results'),
        content: Text('Searching for: "$query"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: Color(0xFFFF6B35)),
            SizedBox(width: 12),
            Text('Notifications'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF3B82F6),
                child: Icon(Icons.person_add, color: Colors.white, size: 18),
              ),
              title: const Text('New user registered'),
              subtitle: const Text('2 minutes ago'),
              dense: true,
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF10B981),
                child: Icon(Icons.class_, color: Colors.white, size: 18),
              ),
              title: const Text('New class created'),
              subtitle: const Text('1 hour ago'),
              dense: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Color(0xFF3B82F6)),
            SizedBox(width: 12),
            Text('Help & Support'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 12),
            Text('📧 Email: support@edulycee.com'),
            Text('📞 Phone: +212 XXX XXX XXX'),
            Text('💬 Chat: Available 24/7'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening settings...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleProfileMenu(BuildContext context, String value) {
    switch (value) {
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening profile...')),
        );
        break;
      case 'settings':
        _showSettings(context);
        break;
      case 'logout':
        _confirmLogout(context);
        break;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCSV(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Generating CSV file...'),
            ],
          ),
        ),
      );

      // Fetch all users from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('utilisateurs')
          .orderBy('dateCreation', descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No users to export'),
              backgroundColor: Color(0xFFF59E0B),
            ),
          );
        }
        return;
      }

      // Prepare CSV data
      List<List<dynamic>> csvData = [
        ['Name', 'Email', 'Role', 'Status', 'Join Date'], // Headers
      ];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final nom = data['nom'] ?? '';
        final prenom = data['prenom'] ?? '';
        final email = data['email'] ?? '';
        final role = _roleName(data['role'] ?? 'eleve');
        final isActive = data['isActive'] ?? true;
        final status = isActive ? 'Active' : 'Inactive';
        
        String formattedDate = 'N/A';
        if (data['dateCreation'] != null) {
          final dateCreation = data['dateCreation'] as Timestamp;
          final date = dateCreation.toDate();
          formattedDate = '${_monthName(date.month)} ${date.day}, ${date.year}';
        }

        csvData.add([
          '$prenom $nom',
          email,
          role,
          status,
          formattedDate,
        ]);
      }

      // Convert to CSV string
      String csvString = const ListToCsvConverter().convert(csvData);

      // Create blob and download for web
      final bytes = utf8.encode(csvString);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'users_export.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ CSV file downloaded successfully!'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) Navigator.pop(context);
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting CSV: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _viewAllUsers(BuildContext context) {
    // Navigate to users management page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Users Management...'),
        duration: Duration(seconds: 1),
      ),
    );
    // In a real app, you would navigate to the users page
    // Navigator.push(context, MaterialPageRoute(builder: (_) => UsersManagementPage()));
  }

  void _showUserActions(BuildContext context, String userId, String userName) {
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
            Text(
              'Actions for $userName',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.visibility, color: Color(0xFF3B82F6)),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Viewing details for $userName')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFFF6B35)),
              title: const Text('Edit User'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Editing $userName')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF10B981)),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sending email to $userName')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete User'),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteUser(context, userId, userName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$userName deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAnalyticsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Color(0xFFFF6B35)),
            SizedBox(width: 12),
            Text('Analytics Overview'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Total Users Growth: +15%'),
            SizedBox(height: 8),
            Text('📈 Active Classes: 100%'),
            SizedBox(height: 8),
            Text('👥 New Registrations: +25 this week'),
            SizedBox(height: 8),
            Text('⭐ System Performance: Excellent'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Full analytics coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('View Full Report'),
          ),
        ],
      ),
    );
  }

  void _showStatDetails(BuildContext context, String title, int value, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              title == 'Utilisateurs' ? Icons.people :
              title == 'Élèves' ? Icons.school :
              title == 'Professeurs' ? Icons.person :
              Icons.class_,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Quick Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (title == 'Utilisateurs' || title == 'Élèves' || title == 'Professeurs')
              const Text('• View all users'),
            if (title == 'Utilisateurs' || title == 'Élèves' || title == 'Professeurs')
              const Text('• Add new user'),
            if (title == 'Classes')
              const Text('• View all classes'),
            if (title == 'Classes')
              const Text('• Create new class'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening $title management...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
            ),
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('utilisateurs').snapshots(),
      builder: (context, usersSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('classes').snapshots(),
          builder: (context, classesSnap) {
            final totalUsers = usersSnap.data?.docs.length ?? 0;
            final totalClasses = classesSnap.data?.docs.length ?? 0;

            int eleves = 0, profs = 0;
            if (usersSnap.hasData) {
              for (final doc in usersSnap.data!.docs) {
                final role = (doc.data() as Map<String, dynamic>)['role'] ?? '';
                if (role == 'eleve') eleves++;
                if (role == 'professeur') profs++;
              }
            }

            // Calculate trends (mock data for now)
            const userTrend = 2;
            const eleveTrend = 10;

            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _StatCard(
                  icon: Icons.people_outline,
                  label: 'UTILISATEURS',
                  value: '$totalUsers',
                  trend: userTrend,
                  trendLabel: '$userTrend%',
                  color: const Color(0xFF3B82F6),
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () {
                    _showStatDetails(context, 'Utilisateurs', totalUsers, 'Total users in the system');
                  },
                ),
                _StatCard(
                  icon: Icons.school_outlined,
                  label: 'ÉLÈVES',
                  value: '$eleves',
                  trend: eleveTrend,
                  trendLabel: '$eleveTrend%',
                  color: const Color(0xFF8B5CF6),
                  bgColor: const Color(0xFFF5F3FF),
                  onTap: () {
                    _showStatDetails(context, 'Élèves', eleves, 'Total students enrolled');
                  },
                ),
                _StatCard(
                  icon: Icons.person_outline,
                  label: 'PROFESSEURS',
                  value: '$profs',
                  trend: 0,
                  trendLabel: 'Stable',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () {
                    _showStatDetails(context, 'Professeurs', profs, 'Total teachers in the system');
                  },
                ),
                _StatCard(
                  icon: Icons.class_outlined,
                  label: 'CLASSES',
                  value: '$totalClasses',
                  trend: 0,
                  trendLabel: 'Active',
                  color: const Color(0xFFFF6B35),
                  bgColor: const Color(0xFFFFF7ED),
                  onTap: () {
                    _showStatDetails(context, 'Classes', totalClasses, 'Total active classes');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentUsersSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Derniers inscrits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recently joined members of the institution.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        _exportToCSV(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Export CSV'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        _viewAllUsers(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A5F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Table
          _buildRecentUsersTable(),
        ],
      ),
    );
  }

  Widget _buildRecentUsersTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('utilisateurs')
          .orderBy('dateCreation', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                'Aucun utilisateur inscrit',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    flex: 3,
                    child: Text(
                      'USER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'JOIN DATE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 2,
                    child: Text(
                      'ROLE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(width: 40),
                ],
              ),
            ),
            
            // Table Rows
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final nom = data['nom'] ?? '';
                final prenom = data['prenom'] ?? '';
                final email = data['email'] ?? '';
                final role = data['role'] ?? 'eleve';
                final isActive = data['isActive'] ?? true;
                final dateCreation = data['dateCreation'] as Timestamp?;
                
                final initials = '${prenom.isNotEmpty ? prenom[0] : ''}${nom.isNotEmpty ? nom[0] : ''}'.toUpperCase();
                
                String formattedDate = 'N/A';
                if (dateCreation != null) {
                  final date = dateCreation.toDate();
                  formattedDate = '${_monthName(date.month)} ${date.day}, ${date.year}';
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      // User Info
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _roleColor(role),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$prenom $nom',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E293B),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Status
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFF59E0B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? 'Active' : 'Pending',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Join Date
                      Expanded(
                        flex: 2,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      
                      // Role Badge
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _roleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _roleName(role).toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _roleColor(role),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      
                      // Actions
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.more_vert, size: 18),
                          onPressed: () {
                            _showUserActions(context, snapshot.data!.docs[index].id, '$prenom $nom');
                          },
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Affichage de ${_currentPage * _itemsPerPage + 1}-${(_currentPage + 1) * _itemsPerPage} sur ${snapshot.data!.docs.length} résultats',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, size: 20),
                        onPressed: _currentPage > 0
                            ? () {
                                setState(() {
                                  _currentPage--;
                                });
                              }
                            : null,
                        color: _currentPage > 0 ? Colors.grey.shade600 : Colors.grey.shade300,
                      ),
                      Text(
                        'Page ${_currentPage + 1}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, size: 20),
                        onPressed: (_currentPage + 1) * _itemsPerPage < snapshot.data!.docs.length
                            ? () {
                                setState(() {
                                  _currentPage++;
                                });
                              }
                            : null,
                        color: (_currentPage + 1) * _itemsPerPage < snapshot.data!.docs.length
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  static Color _roleColor(String role) {
    switch (role) {
      case 'eleve':
        return const Color(0xFF3B82F6);
      case 'professeur':
        return const Color(0xFF10B981);
      case 'admin':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  static String _roleName(String role) {
    switch (role) {
      case 'eleve':
        return 'Élève';
      case 'professeur':
        return 'Professeur';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

class _WelcomeCard extends StatelessWidget {
  final String userName;
  const _WelcomeCard({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D4A6F), Color(0xFF1E3A5F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Text(
                'Bonjour',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '👋',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Panneau d\'administration DEVMOB-EduLycée',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int trend;
  final String trendLabel;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.trend,
    required this.trendLabel,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  if (trend != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: trend > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            trend > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trendLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: trend > 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        trendLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
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
