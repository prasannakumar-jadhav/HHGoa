import 'dart:math' as math;
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Entry point
// ---------------------------------------------------------------------------

Future<void> showVoiceInputSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _VoiceInputSheet(),
  );
}

// ---------------------------------------------------------------------------
// Sheet
// ---------------------------------------------------------------------------

class _VoiceInputSheet extends StatefulWidget {
  const _VoiceInputSheet();

  @override
  State<_VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<_VoiceInputSheet>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _waveCtrl;

  _ListenState _state = _ListenState.idle;

  // Simulated transcript phrases
  static const _phrases = [
    'Add a task to review the Flutter PR...',
    'Remind me to write unit tests at 2 PM...',
    'Create a high priority task for the auth bug...',
    'Schedule a meeting preparation task...',
  ];
  String _transcript = '';
  int _phraseIndex = 0;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _onMicTap() {
    if (_state == _ListenState.idle) {
      setState(() {
        _state = _ListenState.listening;
        _transcript = '';
        _charIndex = 0;
      });
      _typePhrase();
    } else if (_state == _ListenState.listening) {
      setState(() => _state = _ListenState.done);
    } else {
      setState(() {
        _state = _ListenState.idle;
        _transcript = '';
        _phraseIndex = (_phraseIndex + 1) % _phrases.length;
      });
    }
  }

  void _typePhrase() async {
    final phrase = _phrases[_phraseIndex];
    while (_charIndex < phrase.length && _state == _ListenState.listening) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (!mounted || _state != _ListenState.listening) break;
      setState(() {
        _charIndex++;
        _transcript = phrase.substring(0, _charIndex);
      });
    }
    if (mounted && _state == _ListenState.listening) {
      setState(() => _state = _ListenState.done);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mic_rounded,
                    color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Voice Input', style: theme.textTheme.titleLarge),
            ],
          ),

          const SizedBox(height: 32),

          // Animated mic button
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, child) {
              final isListening = _state == _ListenState.listening;
              final scale = isListening
                  ? 1.0 + _pulseCtrl.value * 0.12
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _MicButton(
              state: _state,
              waveCtrl: _waveCtrl,
              onTap: _onMicTap,
            ),
          ),

          const SizedBox(height: 12),

          // State label
          Text(
            switch (_state) {
              _ListenState.idle => 'Tap to speak',
              _ListenState.listening => 'Listening...',
              _ListenState.done => 'Tap to try again',
            },
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 28),

          // Transcript card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: _transcript.isEmpty
                ? Text(
                    'Your speech will appear here...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.35),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    _transcript,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _state == _ListenState.done
                      ? () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Voice task creation — coming soon'),
                            behavior: SnackBarBehavior.floating,
                            action: SnackBarAction(label: 'OK', onPressed: () {}),
                          ));
                        }
                      : null,
                  icon: const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text('Create Task'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mic button with wave rings
// ---------------------------------------------------------------------------

enum _ListenState { idle, listening, done }

class _MicButton extends StatelessWidget {
  final _ListenState state;
  final AnimationController waveCtrl;
  final VoidCallback onTap;

  const _MicButton({
    required this.state,
    required this.waveCtrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _ListenState.idle => Colors.purple,
      _ListenState.listening => Colors.red.shade600,
      _ListenState.done => Colors.green.shade600,
    };
    final icon = switch (state) {
      _ListenState.idle => Icons.mic_rounded,
      _ListenState.listening => Icons.stop_rounded,
      _ListenState.done => Icons.check_rounded,
    };

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated wave rings when listening
          if (state == _ListenState.listening)
            AnimatedBuilder(
              animation: waveCtrl,
              builder: (_, _) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: _WaveRingPainter(
                    progress: waveCtrl.value,
                    color: color,
                  ),
                );
              },
            ),
          // Core button
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 34),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wave ring painter
// ---------------------------------------------------------------------------

class _WaveRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _WaveRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final wave = ((progress + i / 3) % 1.0);
      final radius = 40 + wave * 30;
      final opacity = (1.0 - wave) * 0.35;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_WaveRingPainter old) =>
      old.progress != progress || old.color != color;
}

// Unused import guard
// ignore: unused_element
final _pi = math.pi;
