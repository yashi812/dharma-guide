import 'package:flutter/material.dart';
import '../../models/models.dart';

class AppState extends ChangeNotifier {
  String screen = 'splash';

  // Onboarding
  int    onboardingStep = 0;        // ← add this
  String userName       = '';
  String tradition      = '';
  String userStyle      = '';
  bool   isPremium      = false;
  int    streak         = 0;

  // Puja flow
  String  selectedPuja   = '';
  int     pujaStep       = 0;
  Mantra? selectedMantra;

  // Guidance flow
  String selectedMood    = '';
  String selectedTopic   = '';
  String selectedStyleId = '';

  void nav(String screenName)    { screen = screenName; notifyListeners(); }
  void setUserName(String name)  { userName = name;     notifyListeners(); }
  void setTradition(String t)    { tradition = t;       notifyListeners(); }
  void setPremium(bool value)    { isPremium = value;   notifyListeners(); }
  void setMantra(Mantra m)       { selectedMantra = m;  notifyListeners(); }
  void incrementStreak()         { streak++;            notifyListeners(); }
  void setUserStyle(String s)    { userStyle = s;       notifyListeners(); }
  void setMood(String moodId)    { selectedMood = moodId;     notifyListeners(); }
  void setTopic(String topicId)  { selectedTopic = topicId;   notifyListeners(); }
  void setStyle(String styleId)  { selectedStyleId = styleId; notifyListeners(); }

  void nextOnboardingStep(int i) {        // ← add this
    onboardingStep++;
    notifyListeners();
  }

  void selectPuja(String puja) {
    selectedPuja = puja;
    pujaStep     = 0;
    notifyListeners();
  }

  void nextPujaStep() { pujaStep++; notifyListeners(); }

  void resetPuja() {
    selectedPuja   = '';
    selectedMantra = null;
    pujaStep       = 0;
    notifyListeners();
  }
}