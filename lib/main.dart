import 'package:dharma_guide/screens/aarti_detail_screen.dart';
import 'package:dharma_guide/screens/aarti_list_screen.dart';
import 'package:dharma_guide/screens/puja_detail_screen.dart';
import 'package:dharma_guide/screens/puja_vidhi_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dharma_guide/constants/theme.dart';
import 'package:dharma_guide/state/app_state.dart';
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
import 'screens/technique_detail_screen.dart';
import 'screens/manifestation_journal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bklyszfnaebbpkxlmilw.supabase.co',
    anonKey: 'sb_publishable_KDYRXOZbzamE4t3tX2g4yA_h7ViAC-E',
  );

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
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      await _state.loadProfile();
      if (!mounted) return;
      if (_state.onboardingDone) {
        _state.nav('home');
      } else {
        _state.nav('onboarding');
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 2300));
      if (!mounted) return;
      _state.nav('onboarding');
    }
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Widget _buildScreen() {
    switch (_state.screen) {
      case 'technique_detail': return TechniqueDetailScreen(state: _state);
      case 'splash':           return SplashScreen(state: _state);
      case 'onboarding':       return OnboardingScreen(state: _state);
      case 'home':             return HomeScreen(state: _state);
      case 'reflection':       return ReflectionScreen(state: _state);
      case 'guidance':         return GuidanceScreen(state: _state);
      case 'puja_select':      return PujaSelectScreen(state: _state);
      case 'puja_meaning':     return PujaMeaningScreen(state: _state);
      case 'puja_session':     return PujaSessionScreen(state: _state);
      case 'puja_complete':    return PujaCompleteScreen(state: _state);
      case 'profile':          return ProfileScreen(state: _state);
      case 'paywall':          return PaywallScreen(state: _state);
      case 'manifestation_journal': return ManifestationJournalScreen(state: _state);
      case 'aarti_list':   return AartiListScreen(state: _state);
case 'aarti_detail': return AartiDetailScreen(state: _state);
      case 'puja_vidhi':       return PujaVidhiListScreen(state: _state);
      case 'puja_detail':      return PujaDetailScreen(state: _state);
      default:                 return SplashScreen(state: _state);
      
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