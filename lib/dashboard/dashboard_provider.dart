import 'package:flutter/cupertino.dart';

class DashboardProvider with ChangeNotifier {
  int currentIndex = 0;
  bool isRefreshing = false;
  void setCurrentIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void setRefreshing(bool value) {
    isRefreshing = value;
    notifyListeners();
  }
}