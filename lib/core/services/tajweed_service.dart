import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TajweedService {
  static const Map<String, Color> tajweedColors = {
    'idgham': Color(0xFFFF0000), // Red
    'ikhfa': Color(0xFF0000FF), // Blue
    'qalqalah': Color(0xFF00FF00), // Green
    'ghunnah': Color(0xFFFF00FF), // Magenta
    'madd': Color(0xFFFFA500), // Orange
    'iqlab': Color(0xFF800080), // Purple
    'idgham_no_ghunnah': Color(0xFFFF6B6B), // Light Red
    'ikhfa_shafawi': Color(0xFF6B6BFF), // Light Blue
    'madd_laazim': Color(0xFFFFD700), // Gold
    'madd_munfasil': Color(0xFFFF8C00), // Dark Orange
  };

  Map<String, dynamic>? _tajweedData;
  
  Future<void> loadTajweedData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/tajweed/tajweed_rules.json');
      _tajweedData = json.decode(jsonString);
    } catch (e) {
      print('Error loading tajweed data: $e');
    }
  }

  List<TajweedSegment> parseTajweedText(String arabicText, int surahNumber, int verseNumber) {
    if (_tajweedData == null) {
      return [TajweedSegment(text: arabicText, rule: null, color: Colors.black)];
    }

    final List<TajweedSegment> segments = [];
    final verseKey = '$surahNumber:$verseNumber';
    final verseRules = _tajweedData?['verses']?[verseKey];

    if (verseRules == null) {
      return [TajweedSegment(text: arabicText, rule: null, color: Colors.black)];
    }

    int lastIndex = 0;
    final List<dynamic> rules = verseRules['rules'] ?? [];
    
    // Sort rules by start position
    rules.sort((a, b) => a['start'].compareTo(b['start']));

    for (final rule in rules) {
      final int start = rule['start'];
      final int end = rule['end'];
      final String ruleType = rule['type'];
      
      // Add text before the rule
      if (start > lastIndex) {
        segments.add(TajweedSegment(
          text: arabicText.substring(lastIndex, start),
          rule: null,
          color: Colors.black,
        ));
      }
      
      // Add the rule text
      segments.add(TajweedSegment(
        text: arabicText.substring(start, end),
        rule: ruleType,
        color: tajweedColors[ruleType] ?? Colors.black,
      ));
      
      lastIndex = end;
    }
    
    // Add remaining text
    if (lastIndex < arabicText.length) {
      segments.add(TajweedSegment(
        text: arabicText.substring(lastIndex),
        rule: null,
        color: Colors.black,
      ));
    }
    
    return segments;
  }

  Widget buildTajweedRichText(
    String arabicText, 
    int surahNumber, 
    int verseNumber,
    TextStyle baseStyle,
    bool tajweedEnabled,
  ) {
    if (!tajweedEnabled) {
      return Text(arabicText, style: baseStyle);
    }

    final segments = parseTajweedText(arabicText, surahNumber, verseNumber);
    
    return RichText(
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: baseStyle,
        children: segments.map((segment) {
          return TextSpan(
            text: segment.text,
            style: TextStyle(
              color: segment.color,
              backgroundColor: segment.rule != null 
                ? segment.color.withOpacity(0.1) 
                : null,
            ),
          );
        }).toList(),
      ),
    );
  }

  String getTajweedRuleName(String rule, String locale) {
    final Map<String, Map<String, String>> ruleNames = {
      'idgham': {'en': 'Idgham', 'fr': 'Idgham'},
      'ikhfa': {'en': 'Ikhfa', 'fr': 'Ikhfa'},
      'qalqalah': {'en': 'Qalqalah', 'fr': 'Qalqalah'},
      'ghunnah': {'en': 'Ghunnah', 'fr': 'Ghunnah'},
      'madd': {'en': 'Madd', 'fr': 'Madd'},
      'iqlab': {'en': 'Iqlab', 'fr': 'Iqlab'},
      'idgham_no_ghunnah': {'en': 'Idgham without Ghunnah', 'fr': 'Idgham sans Ghunnah'},
      'ikhfa_shafawi': {'en': 'Ikhfa Shafawi', 'fr': 'Ikhfa Shafawi'},
      'madd_laazim': {'en': 'Madd Laazim', 'fr': 'Madd Laazim'},
      'madd_munfasil': {'en': 'Madd Munfasil', 'fr': 'Madd Munfasil'},
    };
    
    return ruleNames[rule]?[locale] ?? rule;
  }

  String getTajweedRuleDescription(String rule, String locale) {
    final Map<String, Map<String, String>> descriptions = {
      'idgham': {
        'en': 'Merging of noon sakinah or tanween with specific letters',
        'fr': 'Fusion du noon sakinah ou tanween avec des lettres spécifiques'
      },
      'ikhfa': {
        'en': 'Concealment of noon sakinah or tanween',
        'fr': 'Dissimulation du noon sakinah ou tanween'
      },
      'qalqalah': {
        'en': 'Echoing sound on specific letters when they have sukoon',
        'fr': 'Son d\'écho sur des lettres spécifiques quand elles ont sukoon'
      },
      'ghunnah': {
        'en': 'Nasal sound held for 2 counts',
        'fr': 'Son nasal maintenu pendant 2 temps'
      },
      'madd': {
        'en': 'Elongation of vowel sounds',
        'fr': 'Élongation des sons de voyelles'
      },
    };
    
    return descriptions[rule]?[locale] ?? '';
  }
}

class TajweedSegment {
  final String text;
  final String? rule;
  final Color color;

  TajweedSegment({
    required this.text,
    required this.rule,
    required this.color,
  });
}