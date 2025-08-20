import 'package:hive/hive.dart';

part 'bookmark.g.dart';

@HiveType(typeId: 0)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final int surahNumber;
  
  @HiveField(2)
  final int verseNumber;
  
  @HiveField(3)
  final String surahName;
  
  @HiveField(4)
  final String verseText;
  
  @HiveField(5)
  final DateTime createdAt;
  
  @HiveField(6)
  String? note;
  
  @HiveField(7)
  String? translation;

  Bookmark({
    required this.id,
    required this.surahNumber,
    required this.verseNumber,
    required this.surahName,
    required this.verseText,
    required this.createdAt,
    this.note,
    this.translation,
  });

  String get verseKey => '$surahNumber:$verseNumber';
}