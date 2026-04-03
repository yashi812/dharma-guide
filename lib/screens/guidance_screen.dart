import 'package:dharma_guide/ai_service.dart' show aiCall;
import 'package:dharma_guide/constants/app_data.dart' show kTopicFallback, kTopics;
import 'package:dharma_guide/models/models.dart' show Topic;
import '../constants/theme.dart';
import 'package:flutter/material.dart';
import '../constants/app_data.dart';
import '../models/models.dart';
import '../../ai_service.dart';
import '../state/app_state.dart';
import '../../shared_widgets.dart';

class GuidanceScreen extends StatefulWidget {
  final AppState state;
  const GuidanceScreen({super.key, required this.state});

  @override
  State<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen> {
  Topic? _topic;
  String _resp = '', _fqResp = '', _fq = '';
  bool _loading = false, _fqLoad = false;
  final _fqController = TextEditingController();

  @override
  void dispose() {
    _fqController.dispose();
    super.dispose();
  }

  Future<void> _pickTopic(Topic t) async {
    setState(() {
      _topic = t;
      _loading = true;
      _resp = '';
      _fqResp = '';
    });
    final r = await aiCall(
      'You are Dharma Guide — a wise Hindu spiritual counselor. '
      'Style: ${widget.state.userStyle}. Give a 3-4 sentence response rooted in Bhagavad Gita wisdom. '
      'Be specific and compassionate. End with one practical action step.',
      'Guide me on: ${t.label}',
    );
    setState(() {
      _resp = r ?? kTopicFallback[t.id] ?? '';
      _loading = false;
    });
  }

  Future<void> _sendFollowUp() async {
    if (_fq.trim().isEmpty) return;
    final q = _fq;
    _fqController.clear();
    setState(() {
      _fq = '';
      _fqLoad = true;
    });
    final r = await aiCall(
      'You are Dharma Guide. The user seeks guidance on: ${_topic?.label}. '
      'Style: ${widget.state.userStyle}. Give a concise 2-3 sentence follow-up rooted in Gita teachings.',
      q,
    );
    setState(() {
      _fqResp = r ??
          'Sit with this question in silence. The answer arises when the mind is still.';
      _fqLoad = false;
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
                children: [
                  // Header
                  Row(children: [
                    if (_topic != null) ...[
                      BackBtn(
                          onTap: () => setState(
                              () {_topic = null; _resp = ''; _fqResp = '';})),
                      const SizedBox(width: 12),
                    ],
                    const Column(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Dharmic Guidance',
                          style: TextStyle(
                              fontSize: 28,
                              color: kText,
                              fontWeight: FontWeight.w400)),
                      Text('Wisdom from the Bhagavad Gita',
                          style: TextStyle(fontSize: 13, color: kDim)),
                    ]),
                  ]),
                  const SizedBox(height: 14),

                  // Topic list
                  if (_topic == null) ...[
                    const Text('What calls for guidance today?',
                        style: TextStyle(color: kDim, fontSize: 14)),
                    const SizedBox(height: 8),
                    ...kTopics.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DharmaCard(
                            onTap: () => _pickTopic(t),
                            child: Row(children: [
                              Text(t.icon,
                                  style: const TextStyle(fontSize: 24)),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: Text(t.label,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: kText,
                                          fontSize: 15))),
                              const Text('›',
                                  style:
                                      TextStyle(color: kDim, fontSize: 18)),
                            ]),
                          ),
                        )),
                  ] else ...[
                    Row(children: [
                      Text(_topic!.icon,
                          style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(_topic!.label,
                          style:
                              const TextStyle(fontSize: 19, color: kText)),
                    ]),
                    const SizedBox(height: 12),

                    // Response
                    if (_loading)
                      DharmaCard(
                        decoration: BoxDecoration(
                            color: kAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kBorder)),
                        child: const Text(
                            'Seeking wisdom from the Gita...',
                            style: TextStyle(
                                color: kDim,
                                fontSize: 14,
                                fontStyle: FontStyle.italic)),
                      )
                    else
                      DharmaCard(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFFF8ED), Color(0xFFF5EDD8)]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: kAccent.withOpacity(0.3)),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✨ DHARMA SAYS',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: kAccent,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 10),
                              Text(_resp,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: kRust,
                                      height: 1.9)),
                            ]),
                      ),

                    // Follow-up
                    if (_resp.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DharmaCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ASK MORE',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: kDim,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w500)),
                              if (_fqResp.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(_fqResp,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: kRust,
                                        height: 1.8)),
                                const SizedBox(height: 14),
                                const Divider(color: kBorder),
                              ],
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _fqController,
                                    onChanged: (v) => _fq = v,
                                    onSubmitted: (_) => _sendFollowUp(),
                                    decoration: InputDecoration(
                                      hintText: 'Ask a follow-up...',
                                      hintStyle:
                                          const TextStyle(color: kDim),
                                      filled: true,
                                      fillColor: kAlt,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          borderSide: const BorderSide(
                                              color: kBorder)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          borderSide: const BorderSide(
                                              color: kBorder)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                    ),
                                    style: const TextStyle(
                                        fontSize: 13, color: kText),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _sendFollowUp,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                        color: kAccent,
                                        shape: BoxShape.circle),
                                    child: Center(
                                        child: Text(
                                            _fqLoad ? '…' : '↑',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16))),
                                  ),
                                ),
                              ]),
                            ]),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            BottomNav(active: 'guidance', state: widget.state),
          ],
        ),
      ),
    );
  }
}
