import 'package:flutter/material.dart';

class WelcomeBanner extends StatelessWidget {
  /// Number of non-completed tasks today — drives the tagline.
  final int pendingCount;

  const WelcomeBanner({super.key, this.pendingCount = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();

    final greeting = switch (now.hour) {
      >= 5 && <= 11 => 'Good morning',
      >= 12 && <= 16 => 'Good afternoon',
      _ => 'Good evening',
    };

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Decorative circles — purely cosmetic
          Positioned(
            right: -24,
            top: -24,
            child: _Circle(size: 120, opacity: 0.10),
          ),
          Positioned(
            right: 40,
            bottom: -36,
            child: _Circle(size: 80, opacity: 0.07),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, Developer 👋',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      pendingCount == 0
                          ? "You're all caught up today! 🎉"
                          : "You have $pendingCount task${pendingCount == 1 ? '' : 's'} today. Let's get it done!",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: opacity),
    ),
  );
}
