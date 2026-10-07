import 'package:flutter/material.dart';
import 'package:voxpilot/services/task_storage_service.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> showAiAssistSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _AiAssistSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

class _AiAssistSheet extends StatefulWidget {
  const _AiAssistSheet();

  @override
  State<_AiAssistSheet> createState() => _AiAssistSheetState();
}

class _AiAssistSheetState extends State<_AiAssistSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  bool _loading = true;
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;

  // Chat history: (isUser, message)
  final List<(bool, String)> _messages = [];

  static const _suggestions = [
    '📋  What should I focus on today?',
    '📊  Summarise my task progress',
    '⚡  Which tasks are high priority?',
    '💡  Give me a productivity tip',
  ];

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadContext() async {
    final items = await TaskStorageService.instance.loadItems();
    if (!mounted) return;
    setState(() {
      _totalTasks = items.length;
      _completedTasks = items.where((i) => i.task.isDone).length;
      _pendingTasks = items
          .where((i) => !i.task.isDone)
          .length;
      _loading = false;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    _controller.clear();
    setState(() => _messages.add((true, text.trim())));
    _scrollToBottom();

    // Simulate AI response after a short delay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _messages.add((false, _generateResponse(text.trim()))));
      _scrollToBottom();
    });
  }

  String _generateResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('focus') || q.contains('today')) {
      if (_pendingTasks == 0) {
        return "🎉 You've completed everything! Great work. Consider adding new tasks or taking a well-deserved break.";
      }
      return "You have $_pendingTasks task${_pendingTasks == 1 ? '' : 's'} left today. I'd suggest starting with your high-priority items first — knock those out while your energy is highest!";
    }

    if (q.contains('progress') || q.contains('summar')) {
      final rate = _totalTasks == 0
          ? 0
          : (_completedTasks / _totalTasks * 100).round();
      return "📊 Here's your summary:\n• Total tasks: $_totalTasks\n• Completed: $_completedTasks\n• Pending: $_pendingTasks\n• Completion rate: $rate%\n\n${rate >= 80 ? '🔥 Outstanding progress!' : rate >= 50 ? '💪 Keep going — more than halfway there!' : '🚀 Great start! Stay focused and you\'ll get there.'}";
    }

    if (q.contains('high priority') || q.contains('priority')) {
      return "⚡ Focus on your high-priority tasks first — they have the highest impact. Use time-blocking: dedicate your first 2 hours to these before checking messages or emails.";
    }

    if (q.contains('tip') || q.contains('productivity')) {
      const tips = [
        "🍅 Try the Pomodoro technique: 25 minutes of focused work, then a 5-minute break. It helps maintain concentration without burnout.",
        "📝 Write down your top 3 tasks the night before. Starting the day with a clear plan reduces decision fatigue.",
        "🔕 Turn off notifications during deep work sessions. Even a brief interruption can cost up to 23 minutes of focus time.",
        "✅ Tackle your hardest task first ('eat the frog'). Once it's done, everything else feels easier.",
      ];
      tips.shuffle();
      return tips.first;
    }

    return "I'm your AI productivity assistant! I can help you:\n• Prioritise your tasks\n• Summarise your progress\n• Share productivity tips\n\nTry asking me something like \"What should I focus on today?\"";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.85,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            // ── Drag handle ─────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.teal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI Assist', style: theme.textTheme.titleLarge),
                      Text(
                        'Powered by VoxPilot AI',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Chat area ────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? _WelcomeView(
                          suggestions: _suggestions,
                          onSuggestion: _sendMessage,
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final (isUser, text) = _messages[i];
                            return _ChatBubble(isUser: isUser, text: text);
                          },
                        ),
            ),

            const Divider(height: 1),

            // ── Input bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sendMessage,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything...',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: cs.surfaceContainerLow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _sendMessage(_controller.text),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      minimumSize: Size.zero,
                    ),
                    child: const Icon(Icons.send_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome / suggestion view
// ---------------------------------------------------------------------------

class _WelcomeView extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestion;

  const _WelcomeView({
    required this.suggestions,
    required this.onSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.teal,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How can I help you?',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Ask me about your tasks, progress, or get productivity tips.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: suggestions
                .map(
                  (s) => ActionChip(
                    label: Text(s),
                    onPressed: () => onSuggestion(s),
                    backgroundColor:
                        cs.surfaceContainerLow,
                    side: BorderSide(color: cs.outlineVariant),
                    labelStyle: theme.textTheme.labelMedium,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Chat bubble
// ---------------------------------------------------------------------------

class _ChatBubble extends StatelessWidget {
  final bool isUser;
  final String text;

  const _ChatBubble({required this.isUser, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.teal.withValues(alpha: 0.15),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.teal, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : cs.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? cs.onPrimary : cs.onSurface,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: cs.primaryContainer,
              child: Text(
                'D',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
