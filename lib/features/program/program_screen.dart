import 'package:flutter/material.dart';

import '../../data/services/program_data.dart';
import '../../theme/app_theme.dart';

class ProgramScreen extends StatelessWidget {
  final int currentDay;

  const ProgramScreen({super.key, required this.currentDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programme de 90 jours')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: programDays.length,
        itemBuilder: (context, i) {
          final day = programDays[i];
          final isToday = day.day == currentDay;
          final isCompleted = day.day < currentDay;
          final isLocked = day.day > currentDay;

          return _ProgramDayCard(
            day: day,
            isToday: isToday,
            isCompleted: isCompleted,
            isLocked: isLocked,
          );
        },
      ),
    );
  }
}

class _ProgramDayCard extends StatelessWidget {
  final dynamic day;
  final bool isToday;
  final bool isCompleted;
  final bool isLocked;

  const _ProgramDayCard({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    Color bgColor = Colors.white;
    Color dayColor = AppTheme.textSecondary;

    if (isToday) {
      borderColor = AppTheme.accent;
      bgColor = AppTheme.accent.withOpacity(0.05);
      dayColor = AppTheme.accent;
    } else if (isCompleted) {
      bgColor = AppTheme.success.withOpacity(0.04);
      dayColor = AppTheme.success;
    } else if (isLocked) {
      bgColor = Colors.grey.shade50;
      dayColor = AppTheme.textSecondary.withOpacity(0.5);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.success
                  : isToday
                      ? AppTheme.accent
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : isLocked
                      ? Icon(Icons.lock_outline,
                          color: Colors.grey.shade400, size: 16)
                      : Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isToday ? Colors.white : dayColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
            ),
          ),
          title: Text(
            'Jour ${day.day} : ${day.title}',
            style: TextStyle(
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
              fontSize: 14,
              color: isLocked
                  ? AppTheme.textSecondary.withOpacity(0.5)
                  : AppTheme.textPrimary,
            ),
          ),
          subtitle: isToday
              ? const Text(
                  'Défi du jour',
                  style: TextStyle(
                    color: AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
          children: isLocked
              ? []
              : [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                day.tip,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🏋️ ',
                                  style: TextStyle(fontSize: 16)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Exercice',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      day.exercise,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
