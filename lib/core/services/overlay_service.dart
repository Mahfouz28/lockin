import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static const String overlayChannel = "com.lockin/overlay_channel";

  // عرض شاشة القفل
  static Future<void> showLockScreen(String blockedAppName) async {
    if (await FlutterOverlayWindow.isPermissionGranted()) {
      await FlutterOverlayWindow.showOverlay(
        enableDrag: true,
        overlayTitle: "وضع التركيز مفعل",
        overlayContent: "تم حظر $blockedAppName مؤقتًا لمساعدتك على التركيز",
        flag: OverlayFlag.flagNotTouchable, // عشان ما يقدرش يضغط تحتها
        visibility: NotificationVisibility.visibilityPublic,
        positionGravity: PositionGravity.auto,
      );
    }
  }

  // إخفاء الـ overlay
  static Future<void> hideOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  // التحقق من الصلاحية
  static Future<bool> requestPermission() async {
    return (await FlutterOverlayWindow.requestPermission()) ?? false;
  }

  static Future<bool> isActive() async {
    return await FlutterOverlayWindow.isActive();
  }
}
