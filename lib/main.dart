import 'package:flutter/material.dart';
import 'constants/theme.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/guidance_screen.dart';
import 'screens/puja_select_screen.dart';
import 'screens/puja_meaning_screen.dart';
import 'screens/puja_session_screen.dart';
import 'screens/puja_complete_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/paywall_screen.dart';

void main() {
  runApp(const DharmaGuideApp());
}

class DharmaGuideApp extends StatefulWidget {
  const DharmaGuideApp({super.key});

  @override
  State<DharmaGuideApp> createState() => _DharmaGuideAppState();
}

class _DharmaGuideAppState extends State<DharmaGuideApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.addListener(() => setState(() {}));
    // Auto-advance from splash after 2.3 seconds
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) _state.nav('onboarding');
    });
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _buildScreen() {
    switch (_state.screen) {
      case 'splash':        return SplashScreen(state: _state);
      case 'onboarding':    return OnboardingScreen(state: _state);
      case 'home':          return HomeScreen(state: _state);
      case 'reflection':    return ReflectionScreen(state: _state);
      case 'guidance':      return GuidanceScreen(state: _state);
      case 'puja_select':   return PujaSelectScreen(state: _state);
      case 'puja_meaning':  return PujaMeaningScreen(state: _state);
      case 'puja_session':  return PujaSessionScreen(state: _state);
      case 'puja_complete': return PujaCompleteScreen(state: _state);
      case 'profile':       return ProfileScreen(state: _state);
      case 'paywall':       return PaywallScreen(state: _state);
      default:              return SplashScreen(state: _state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dharma Guide',
      theme: ThemeData(
        scaffoldBackgroundColor: kBg,
        fontFamily: 'DMSans',
        colorScheme: ColorScheme.fromSeed(seedColor: kAccent),
      ),
      home: _buildScreen(),
    );
  }
}
