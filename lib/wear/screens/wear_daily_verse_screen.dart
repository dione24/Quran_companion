import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WearDailyVerseScreen extends StatefulWidget {
  const WearDailyVerseScreen({super.key});

  @override
  State<WearDailyVerseScreen> createState() => _WearDailyVerseScreenState();
}

class _WearDailyVerseScreenState extends State<WearDailyVerseScreen> {
  String _arabicText = '';
  String _translation = '';
  String _reference = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyVerse();
  }

  Future<void> _loadDailyVerse() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _arabicText = prefs.getString('daily_verse_arabic') ?? 
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      _translation = prefs.getString('daily_verse_translation') ?? 
          'Au nom d\'Allah, le Tout Miséricordieux';
      _reference = prefs.getString('daily_verse_reference') ?? 
          'Al-Fatiha 1';
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.teal,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Verset du Jour',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _arabicText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontFamily: 'Amiri',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _translation,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _reference,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.teal,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}