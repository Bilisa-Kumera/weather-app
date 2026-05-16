import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/ai/ai_bloc.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/gradient_background.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({
    super.key,
    required this.cityName,
    required this.initialWeatherData,
    required this.themeColors,
  });

  final String cityName;
  final String initialWeatherData;
  final List<Color> themeColors;

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<AIChatMessage> _messages = const [];
  var _isSending = false;

  static List<String> getSuggestions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.aiSuggestion1,
      l10n.aiSuggestion2,
      l10n.aiSuggestion3,
      l10n.aiSuggestion4,
    ];
  }

  @override
  void initState() {
    super.initState();
    final state = context.read<AIBloc>().state;
    if (state is AIChatLoaded) {
      _messages = state.messages;
    } else if (state is AILoading) {
      _messages = state.chatMessages;
      _isSending = state.fromChat;
    } else if (state is AIError) {
      _messages = state.chatMessages;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GradientBackground(
      colors: widget.themeColors,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            AppLocalizations.of(context)!.aiChatTitle(widget.cityName),
            style: TextStyle(color: Colors.white, fontSize: r.sp(16)),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocListener<AIBloc, AIState>(
          listener: (context, state) {
            if (state is AILoading) {
              setState(() {
                _messages = state.chatMessages;
                _isSending = state.fromChat;
              });
              _scrollToBottom();
            } else if (state is AIChatLoaded) {
              setState(() {
                _messages = state.messages;
                _isSending = false;
              });
              _scrollToBottom();
            } else if (state is AIError) {
              setState(() {
                _messages = state.chatMessages;
                _isSending = false;
              });
              _scrollToBottom();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(r.w(14), r.h(6), r.w(14), r.h(8)),
                child: GlassCard(
                  borderRadius: r.r(16),
                  padding: EdgeInsets.all(r.w(10)),
                  child: Wrap(
                    spacing: r.w(8),
                    runSpacing: r.h(8),
                    children: getSuggestions(context).map((q) {
                      return ActionChip(
                        label: Text(
                          q,
                          style: TextStyle(fontSize: r.sp(12), color: Colors.white),
                        ),
                        onPressed: _isSending ? null : () => _sendMessage(q),
                        backgroundColor: Colors.white.withOpacity(0.16),
                        side: BorderSide(color: Colors.white.withOpacity(0.35)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(8)),
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isSending && index == _messages.length) {
                      return _typingBubble(r);
                    }

                    final msg = _messages[index];
                    return _messageBubble(r, msg);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(r.w(12), r.h(8), r.w(12), r.h(10)),
                  child: GlassCard(
                    borderRadius: r.r(16),
                    padding: EdgeInsets.symmetric(horizontal: r.w(8), vertical: r.h(8)),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendCurrent(),
                            style: TextStyle(color: Colors.white, fontSize: r.sp(13)),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.aiChatHint,
                              hintStyle: TextStyle(color: Colors.white70, fontSize: r.sp(13)),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: r.w(10),
                                vertical: r.h(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: r.w(42),
                          height: r.w(42),
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendCurrent,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.r(12)),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Icon(Icons.send_rounded, size: r.w(20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messageBubble(Responsive r, AIChatMessage msg) {
    final alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
    final background = msg.isUser ? Colors.white.withOpacity(0.22) : Colors.white.withOpacity(0.14);

    return Align(
      alignment: alignment,
      child: Container(
        margin: EdgeInsets.only(bottom: r.h(8)),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(10)),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(r.r(14)),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: r.sp(13),
            color: Colors.white,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _typingBubble(Responsive r) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: r.h(8)),
        padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(10)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(r.r(14)),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: r.w(16),
              height: r.w(16),
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: r.w(8)),
            Text(
              AppLocalizations.of(context)!.aiPreparing,
              style: TextStyle(fontSize: r.sp(12), color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  void _sendCurrent() {
    _sendMessage(_controller.text);
  }

  void _sendMessage(String text) {
    final message = text.trim();
    if (message.isEmpty || _isSending) return;

    _controller.clear();
    context.read<AIBloc>().add(
          SendChatMessage(
            userMessage: message,
            weatherData: widget.initialWeatherData,
          ),
        );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }
}
