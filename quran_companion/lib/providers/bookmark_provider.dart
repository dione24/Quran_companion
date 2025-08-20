import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/bookmark.dart';
import '../services/local_storage_service.dart';

class BookmarkProvider extends ChangeNotifier {
  final LocalStorageService _localStorage = LocalStorageService();
  
  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  
  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  
  Future<void> loadBookmarks() async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
    
    try {
      _bookmarks = await _localStorage.getBookmarks();
    } catch (e) {
      _bookmarks = [];
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
  
  Future<void> addBookmark({
    required int surahNumber,
    required int verseNumber,
    required String surahName,
    required String verseText,
    String? translation,
    String? note,
  }) async {
    final bookmark = Bookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      surahName: surahName,
      verseText: verseText,
      createdAt: DateTime.now(),
      translation: translation,
      note: note,
    );
    
    await _localStorage.addBookmark(bookmark);
    _bookmarks.add(bookmark);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  Future<void> removeBookmark(String id) async {
    await _localStorage.removeBookmark(id);
    _bookmarks.removeWhere((b) => b.id == id);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
  
  Future<bool> isBookmarked(int surahNumber, int verseNumber) async {
    return await _localStorage.isBookmarked(surahNumber, verseNumber);
  }
  
  Bookmark? getBookmark(int surahNumber, int verseNumber) {
    try {
      return _bookmarks.firstWhere(
        (b) => b.surahNumber == surahNumber && b.verseNumber == verseNumber,
      );
    } catch (e) {
      return null;
    }
  }
}