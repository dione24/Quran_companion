import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  static Future<bool> requestInitialPermissions() async {
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.notification,
      Permission.location,
      Permission.locationWhenInUse,
    ].request();
    
    return statuses.values.every((status) => 
      status == PermissionStatus.granted || 
      status == PermissionStatus.limited
    );
  }
  
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return true;
    }
    
    final status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestLocationPermission() async {
    if (await Permission.location.isGranted) {
      return true;
    }
    
    final status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<bool> requestNotificationPermission() async {
    if (await Permission.notification.isGranted) {
      return true;
    }
    
    final status = await Permission.notification.request();
    return status == PermissionStatus.granted;
  }
  
  static Future<void> showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    Permission permission,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
    
    if (result == true) {
      await permission.request();
    }
  }
  
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}