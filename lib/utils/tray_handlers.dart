import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class MyTrayHandler with TrayListener {
  @override
  void onTrayIconMouseDown() async {
    print('Tray icon clicked');
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu(); // 👈 Show menu on right-click
  }


  @override
  void onTrayMenuItemClick(MenuItem item) async {
    print('Tray menu item clicked: ${item.key}');
    if (item.key == 'show') {
      await windowManager.show();
      await windowManager.focus();
    } else if (item.key == 'exit') {
      await trayManager.destroy();
      exit(0);
    }
  }
}

class MyWindowHandler with WindowListener {
  @override
  void onWindowClose() async {
    print('Window close event');
    await windowManager.hide();
  }
}
