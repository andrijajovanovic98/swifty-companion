import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/project_tile.dart';
import '../widgets/skill_radar.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  final String login;

  const ProfileScreen({super.key, required this.login});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  String? _error;
  List<dynamic> _cursusList = [];
  Map<String, dynamic>? _selectedCursus;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await ApiService.getAccessToken();
    if (token == null) {
      setState(() => _error = "Failed to fetch token.");
      return;
    }

    final userData = await ApiService.fetchUserProfile(widget.login, token);
    if (userData == null) {
      setState(() => _error = "User not found.");
      return;
    }

    final cursusUsers = userData['cursus_users'] ?? [];

    setState(() {
      _user = userData;
      _cursusList = cursusUsers;
      _selectedCursus = cursusUsers.isNotEmpty ? cursusUsers[0] : null;
    });
  }

  void _onCursusChanged(Map<String, dynamic>? selected) {
    setState(() {
      _selectedCursus = selected;
    });
  }

  bool get isBlackholed {
    final selectedUser = _selectedCursus?['user'];
    final isActive = selectedUser?['active?'] ?? true;
    final blackholedAtRaw = _selectedCursus?['blackholed_at'];
    final blackholedAt =
        blackholedAtRaw != null ? DateTime.tryParse(blackholedAtRaw) : null;

    if (isActive == false &&
        blackholedAt != null &&
        blackholedAt.isBefore(DateTime.now())) {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.login)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final level = _selectedCursus?['level']?.toStringAsFixed(2) ?? 'N/A';
    final cursusName = _selectedCursus?['cursus']?['name'] ?? 'unknown';

    final skills = (_selectedCursus?['skills'] as List?) ?? [];
    final skillNames = <String>[];
    final skillValues = <double>[];

    for (var skill in skills) {
      final name = skill['name'] ?? '';
      final value = (skill['level'] as num?)?.toDouble() ?? 0.0;
      skillNames.add(name);
      skillValues.add((value * 5).clamp(0.0, 100.0));
    }

    return Scaffold(
      appBar: AppBar(title: const SizedBox.shrink()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBlackholed)
                const Center(
                  child: Text(
                    'BLACKHOLED',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: _user!['image']?['link'] != null
                      ? NetworkImage(_user!['image']['link'])
                      : null,
                  child: _user!['image']?['link'] == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Text('Name: ${_user!['displayname'] ?? 'N/A'}'),
              Text('Username: ${_user!['login'] ?? 'N/A'}'),
              Text('Email: ${_user!['email'] ?? 'N/A'}'),
              Text('Wallet: ${_user!['wallet'] ?? 'N/A'}'),
              Text('Location: ${_user!['location'] ?? 'N/A'}'),
              const SizedBox(height: 12),
              if (_cursusList.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    DropdownButton<Map<String, dynamic>>(
                      isExpanded: true,
                      value: _selectedCursus,
                      items: _cursusList
                          .map<DropdownMenuItem<Map<String, dynamic>>>(
                        (cursus) {
                          final name = cursus['cursus']?['name'] ?? 'unknown';
                          return DropdownMenuItem(
                            value: cursus,
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ).toList(),
                      onChanged: _onCursusChanged,
                    ),
                  ],
                ),
                Text('Level: $level'),
                const SizedBox(height: 24),
                const Text('Skills:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                if (skillNames.isNotEmpty)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double size =
                          math.min(constraints.maxWidth * 0.7, 300);
                      return Center(
                        child: SizedBox(
                          width: size,
                          height: size,
                          child: SkillRadarChart(
                            skillNames: skillNames,
                            skillValues: skillValues,
                          ),
                        ),
                      );
                    },
                  )
                else
                  const Text('No skills available.'),
              ],
              const SizedBox(height: 24),
              const Text('Projekt:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final allProjects = _user!['projects_users'] as List?;
                  final cursusId = _selectedCursus?['cursus_id'];

                  if (allProjects == null || allProjects.isEmpty) {
                    return const Text('No projects available.');
                  }

                  final filteredProjects = allProjects.where((project) {
                    final ids = project['cursus_ids'] as List?;
                    if (_selectedCursus == null) {
                      return ids == null || ids.isEmpty;
                    }
                    return ids != null && ids.contains(cursusId);
                  }).toList();

                  if (filteredProjects.isEmpty) {
                    return const Text('No projects available.');
                  }

                  return Column(
                    children: filteredProjects.map<Widget>((project) {
                      final name = project['project']?['name'] ?? 'unknown';
                      final mark = project['final_mark'];
                      final status = project['status'] ?? 'unknown';
                      final validated = project['validated?'];

                      return ProjectTile(
                        name: name,
                        finalMark: mark,
                        status: status,
                        validated: validated,
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
