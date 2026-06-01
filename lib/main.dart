import 'package:dharma_guide/screens/aarti_detail_screen.dart';
import 'package:dharma_guide/screens/aarti_list_screen.dart';
import 'package:dharma_guide/screens/puja_detail_screen.dart';
import 'package:dharma_guide/screens/puja_vidhi_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
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

  // Enables background audio playback with lock-screen/notification controls.
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.dharmaguide.dharma_guide.audio',
    androidNotificationChannelName: 'Dharma Guide Audio',
    androidNotificationOngoing: true,
  );

  await Supabase.initialize(
    url: 'https://bklyszfnaebbpkxlmilw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJrbHlzemZuYWViYnBreGxtaWx3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU0NTI5MDQsImV4cCI6MjA5MTAyODkwNH0.z14EBElS6PeTZQOHkoVLYdPebjIUigRLeHdd4X6bI2I',
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
    _state.addListener(_onStateChanged);
    _bootstrap();
  }

  void _onStateChanged() => setState(() {});

  Future<void> _bootstrap() async {
    // ── Ensure there is always an authenticated user ──────────
    // If no session exists, sign in anonymously so every
    // Supabase call has a valid auth.uid() and RLS passes.
    var session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      try {
        await Supabase.instance.client.auth.signInAnonymously();
        session = Supabase.instance.client.auth.currentSession;
      } catch (e) {
        debugPrint('Anonymous sign-in failed: $e');
      }
    }

    if (!mounted) return;

    if (session != null) {
      // Load profile — this tells us if onboarding was completed before
      await _state.loadProfile();
      if (!mounted) return;
      if (_state.onboardingDone) {
        _state.nav('home');
      } else {
        _state.nav('onboarding');
      }
    } else {
      // No session even after anon sign-in (offline?) — show splash
      // briefly then go to onboarding without Supabase calls
      await Future.delayed(const Duration(milliseconds: 2300));
      if (!mounted) return;
      _state.nav('onboarding');
    }
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  Widget _buildScreen() {
    switch (_state.screen) {
      case 'technique_detail':      return TechniqueDetailScreen(state: _state);
      case 'splash':                return SplashScreen(state: _state);
      case 'onboarding':            return OnboardingScreen(state: _state);
      case 'home':                  return HomeScreen(state: _state);
      case 'reflection':            return ReflectionScreen(state: _state);
      case 'guidance':              return GuidanceScreen(state: _state);
      case 'puja_select':           return PujaSelectScreen(state: _state);
      case 'puja_meaning':          return PujaMeaningScreen(state: _state);
      case 'puja_session':          return PujaSessionScreen(state: _state);
      case 'puja_complete':         return PujaCompleteScreen(state: _state);
      case 'profile':               return ProfileScreen(state: _state);
      case 'paywall':               return PaywallScreen(state: _state);
      case 'manifestation_journal': return ManifestationJournalScreen(state: _state);
      case 'aarti_list':            return AartiListScreen(state: _state);
      case 'aarti_detail':          return AartiDetailScreen(state: _state);
      case 'puja_vidhi':            return PujaVidhiListScreen(state: _state);
      case 'puja_detail':           return PujaDetailScreen(state: _state);
      default:                      return SplashScreen(state: _state);
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