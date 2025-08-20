import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WearHomeScreen extends StatefulWidget {
  const WearHomeScreen({super.key});

  @override
  State<WearHomeScreen> createState() => _WearHomeScreenState();
}

class _WearHomeScreenState extends State<WearHomeScreen> {
  String _greeting = '';
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = DateTime.now().hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Bonjour';
    } else if (hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }
    
    setState(() {
      _greeting = greeting;
      _stats = {
        'streak': prefs.getInt('reading_streak') ?? 0,
        'versesRead': prefs.getInt('verses_read_today') ?? 0,
        'memorized': prefs.getInt('verses_memorized') ?? 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _greeting,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            Icons.local_fire_department,
            '${_stats['streak']} jours',
            'Série',
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            Icons.book,
            '${_stats['versesRead']}',
            'Versets lus',
          ),
          const SizedBox(height: 8),
          _buildStatItem(
            Icons.psychology,
            '${_stats['memorized']}',
            'Mémorisés',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.teal),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}