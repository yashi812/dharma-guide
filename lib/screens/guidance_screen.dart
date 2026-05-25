import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../constants/app_data.dart';
import '../../models/models.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';
import '../ai_service.dart';
import '../../services/supabase_service.dart';

class _ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  _ChatMessage({required this.role, required this.content});
}

class GuidanceScreen extends StatefulWidget {
  final AppState state;
  const GuidanceScreen({super.key, required this.state});

  @override
  State<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen> {
  Topic? _topic;
  String? _sessionId;
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickTopic(Topic t) async {
    setState(() {
      _topic = t;
      _messages.clear();
      _loading = true;
    });

    // Start session in Supabase
    try {
      _sessionId = await GuidanceService.startSession(
        topicId: t.id,
        topicLabel: t.label,
        guidanceStyle: widget.state.userStyle,
      );
    } catch (_) {}

    String kundliContext = '';
    if (widget.state.kundliData != null && widget.state.kundliData!.isNotEmpty) {
      kundliContext = 'User\'s Vedic Astrology Kundli Analysis: ${widget.state.kundliData}. Use this information subtly to make your greeting very personalized and convincing, but NEVER explicitly mention their Kundli, astrology, or birth details. Make them feel understood. ';
    }

    // Initial AI greeting for the topic
    final r = await aiCall(
      'You are Dharma Guide — a wise Hindu spiritual counselor rooted in Bhagavad Gita. '
      'Style: ${widget.state.userStyle}. $kundliContext'
      'First, warmly acknowledge the topic. Then ask the user to share more about their specific situation so you can give deeply personal guidance. Keep it to 2-3 sentences.',
      'The user has chosen the topic: "${t.label}". Greet them and invite them to share their situation.',
    );

    final greeting = r ?? 'I am here to guide you. Please share what is weighing on your heart regarding "${t.label}".';

    setState(() {
      _messages.add(_ChatMessage(role: 'assistant', content: greeting));
      _loading = false;
    });

    // Save to Supabase
    if (_sessionId != null) {
      try {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'assistant',
          content: greeting,
        );
      } catch (_) {}
    }

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text));
      _loading = true;
    });
    _scrollToBottom();

    // Save user message
    if (_sessionId != null) {
      try {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'user',
          content: text,
        );
      } catch (_) {}
    }

    // Build conversation history for context
    final history = _messages.map((m) => '${m.role == 'user' ? 'User' : 'Dharma Guide'}: ${m.content}').join('\n');

    String kundliContext = '';
    if (widget.state.kundliData != null && widget.state.kundliData!.isNotEmpty) {
      kundliContext = 'User\'s Vedic Astrology Kundli Analysis: ${widget.state.kundliData}. Formulate your guidance considering their astrological strengths and weaknesses, but NEVER explicitly state that you are using their Kundli or astrology. The guidance must feel deeply intuitive and convincing. ';
    }

    final r = await aiCall(
      'You are Dharma Guide — a deeply compassionate Hindu spiritual counselor rooted in Bhagavad Gita wisdom. '
      'Style: ${widget.state.userStyle}. Topic: "${_topic?.label}". $kundliContext'
      'Give a heartfelt, specific response using Gita teachings. '
      'Reference specific verses when relevant. '
      'Be convincing and leave the user feeling their problem has a clear spiritual path forward. '
      'End with one concrete action step they can take today. '
      'Keep response to 4-5 sentences max.',
      'Conversation so far:\n$history\n\nUser just said: $text',
      tokens: 300,
    );

    final reply = r ?? kTopicFallback[_topic?.id ?? ''] ?? 'The Gita teaches us that every challenge is an invitation to grow. Sit with this feeling and act from your highest self.';

    setState(() {
      _messages.add(_ChatMessage(role: 'assistant', content: reply));
      _loading = false;
    });

    // Save assistant reply
    if (_sessionId != null) {
      try {
        await GuidanceService.appendMessage(
          sessionId: _sessionId!,
          role: 'assistant',
          content: reply,
        );
      } catch (_) {}
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _topic == null ? _buildTopicList() : _buildChat(),
            ),
            BottomNav(active: 'guidance', state: widget.state),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicList() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      children: [
        const Text('Dharmic Guidance',
            style: TextStyle(fontSize: 28, color: kText, fontWeight: FontWeight.w400)),
        const Text('Wisdom from the Bhagavad Gita',
            style: TextStyle(fontSize: 13, color: kDim)),
        const SizedBox(height: 14),
        const Text('What calls for guidance today?',
            style: TextStyle(color: kDim, fontSize: 14)),
        const SizedBox(height: 8),
        ...kTopics.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DharmaCard(
                onTap: () => _pickTopic(t),
                child: Row(children: [
                  Text(t.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 16),
                  Expanded(child: Text(t.label,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: kText, fontSize: 15))),
                  const Text('›', style: TextStyle(color: kDim, fontSize: 18)),
                ]),
              ),
            )),
      ],
    );
  }

  Widget _buildChat() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(children: [
            BackBtn(onTap: () => setState(() {
              _topic = null;
              _messages.clear();
              _sessionId = null;
            })),
            const SizedBox(width: 12),
            Text(_topic!.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(child: Text(_topic!.label,
                style: const TextStyle(fontSize: 18, color: kText, fontWeight: FontWeight.w400))),
          ]),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) {
                // Loading bubble
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kAccent.withOpacity(0.3)),
                    ),
                    child: const Text('Seeking wisdom from the Gita...',
                        style: TextStyle(color: kDim, fontSize: 13, fontStyle: FontStyle.italic)),
                  ),
                );
              }

              final msg = _messages[i];
              final isUser = msg.role == 'user';

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(colors: [kAccent, kRust])
                        : const LinearGradient(colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                    borderRadius: BorderRadius.circular(16),
                    border: isUser ? null : Border.all(color: kAccent.withOpacity(0.3)),
                  ),
                  child: isUser
                      ? Text(msg.content,
                          style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.6))
                      : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('✨ DHARMA GUIDE',
                              style: TextStyle(fontSize: 9, color: kAccent, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(msg.content,
                              style: const TextStyle(fontSize: 15, color: kRust, height: 1.8)),
                        ]),
                ),
              );
            },
          ),
        ),

        // Input box
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: kSurface,
            border: Border(top: BorderSide(color: kBorder)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Share your situation...',
                  hintStyle: const TextStyle(color: kDim),
                  filled: true,
                  fillColor: kAlt,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: kAccent)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                style: const TextStyle(fontSize: 14, color: kText),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
                child: Center(
                  child: Text(_loading ? '…' : '↑',
                      style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }
}