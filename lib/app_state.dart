import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  String screen = 'splash';
  int onboardingStep = 0;
  String userName = '';
  String userStyle = 'balanced';
  int streak = 7;
  Mantra? selectedMantra;
  bool isPremium = false;

  void nav(String s) {
    screen = s;
    notifyListeners();
  }

  void setOnboardingStep(int s) {
    onboardingStep = s;
    notifyListeners();
  }

  void setUserName(String n) {
    userName = n;
    notifyListeners();
  }

  void setUserStyle(String s) {
    userStyle = s;
    notifyListeners();
  }

  void setMantra(Mantra? m) {
    selectedMantra = m;
    notifyListeners();
  }

  void setIsPremium(bool v) {
    isPremium = v;
    notifyListeners();
  }
}
