import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:quran_companion/core/services/tajweed_service.dart';

void main() {
  group('TajweedService', () {
    late TajweedService tajweedService;

    setUp(() {
      tajweedService = TajweedService();
    });

    test('parseTajweedText returns correct segments for verse without rules', () {
      const arabicText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      const surahNumber = 1;
      const verseNumber = 1;

      final segments = tajweedService.parseTajweedText(
        arabicText,
        surahNumber,
        verseNumber,
      );

      expect(segments.length, 1);
      expect(segments[0].text, arabicText);
      expect(segments[0].rule, null);
      expect(segments[0].color, Colors.black);
    });

    test('getTajweedRuleName returns correct names for rules', () {
      expect(
        tajweedService.getTajweedRuleName('idgham', 'en'),
        'Idgham',
      );
      expect(
        tajweedService.getTajweedRuleName('idgham', 'fr'),
        'Idgham',
      );
      expect(
        tajweedService.getTajweedRuleName('ikhfa', 'en'),
        'Ikhfa',
      );
      expect(
        tajweedService.getTajweedRuleName('qalqalah', 'en'),
        'Qalqalah',
      );
    });

    test('getTajweedRuleDescription returns correct descriptions', () {
      final englishDesc = tajweedService.getTajweedRuleDescription('idgham', 'en');
      expect(
        englishDesc,
        'Merging of noon sakinah or tanween with specific letters',
      );

      final frenchDesc = tajweedService.getTajweedRuleDescription('idgham', 'fr');
      expect(
        frenchDesc,
        'Fusion du noon sakinah ou tanween avec des lettres spécifiques',
      );
    });

    test('tajweedColors map contains all expected colors', () {
      expect(TajweedService.tajweedColors['idgham'], const Color(0xFFFF0000));
      expect(TajweedService.tajweedColors['ikhfa'], const Color(0xFF0000FF));
      expect(TajweedService.tajweedColors['qalqalah'], const Color(0xFF00FF00));
      expect(TajweedService.tajweedColors['ghunnah'], const Color(0xFFFF00FF));
      expect(TajweedService.tajweedColors['madd'], const Color(0xFFFFA500));
    });

    test('buildTajweedRichText returns plain text when tajweed disabled', () {
      const arabicText = 'test text';
      final baseStyle = const TextStyle(fontSize: 20);
      
      final widget = tajweedService.buildTajweedRichText(
        arabicText,
        1,
        1,
        baseStyle,
        false, // tajweed disabled
      );

      expect(widget, isA<Text>());
      final textWidget = widget as Text;
      expect(textWidget.data, arabicText);
      expect(textWidget.style, baseStyle);
    });

    test('buildTajweedRichText returns RichText when tajweed enabled', () {
      const arabicText = 'test text';
      final baseStyle = const TextStyle(fontSize: 20);
      
      final widget = tajweedService.buildTajweedRichText(
        arabicText,
        1,
        1,
        baseStyle,
        true, // tajweed enabled
      );

      expect(widget, isA<RichText>());
      final richText = widget as RichText;
      expect(richText.textDirection, TextDirection.rtl);
    });
  });
}