import 'package:workmanager/workmanager.dart';
import 'widget_service.dart';

class BackgroundService {
  static Future<bool> handleBackgroundTask(String task, Map<String, dynamic>? inputData) async {
    switch (task) {
      case 'updateDailyVerse':
        await WidgetService.updateDailyVerse();
        return true;
      case 'syncProgress':
        await _syncProgress();
        return true;
      case 'cleanupCache':
        await _cleanupCache();
        return true;
      default:
        return false;
    }
  }
  
  static Future<void> _syncProgress() async {
    // Sync reading progress, memorization data, etc.
    // This would typically sync with a backend service
    print('Syncing progress in background...');
  }
  
  static Future<void> _cleanupCache() async {
    // Clean up old cached files, temporary downloads, etc.
    print('Cleaning up cache in background...');
  }
  
  static Future<void> registerBackgroundTasks() async {
    // Register daily verse update
    await Workmanager().registerPeriodicTask(
      'daily-verse-update',
      'updateDailyVerse',
      frequency: const Duration(hours: 24),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
    
    // Register progress sync
    await Workmanager().registerPeriodicTask(
      'sync-progress',
      'syncProgress',
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    
    // Register cache cleanup
    await Workmanager().registerPeriodicTask(
      'cleanup-cache',
      'cleanupCache',
      frequency: const Duration(days: 7),
      constraints: Constraints(
        networkType: NetworkType.not_required,
      ),
    );
  }
  
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
  
  static Future<void> cancelTask(String uniqueName) async {
    await Workmanager().cancelByUniqueName(uniqueName);
  }
}