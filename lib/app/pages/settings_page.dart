import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/progress/data/local_study_progress.dart';
import '../../features/reminders/data/local_reminder_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/theme_palette.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    required this.reminderService,
    required this.studyProgress,
    super.key,
  });

  final LocalReminderService reminderService;
  final LocalStudyProgress studyProgress;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _enabled = widget.reminderService.isEnabled;
  late TimeOfDay _time = TimeOfDay(
    hour: widget.reminderService.hour,
    minute: widget.reminderService.minute,
  );
  bool _updating = false;
  late int _dailyLimit = widget.studyProgress.dailyLimit;

  Future<void> _chooseDailyLimit() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (_) => _DailyLimitDialog(initialLimit: _dailyLimit),
    );
    if (selected == null) return;
    await widget.studyProgress.setDailyLimit(selected);
    if (mounted) setState(() => _dailyLimit = selected);
  }

  Future<void> _toggleReminder(bool enabled) async {
    setState(() => _updating = true);
    try {
      final saved = await widget.reminderService.setEnabled(enabled);
      if (!mounted) return;
      setState(() => _enabled = saved && enabled);
      if (!saved) _showPermissionMessage();
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  Future<void> _chooseTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected == null) return;
    await widget.reminderService.setTime(
      hour: selected.hour,
      minute: selected.minute,
    );
    if (mounted) setState(() => _time = selected);
  }

  void _showPermissionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Разреши уведомления в настройках устройства.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Настройки',
      children: [
        GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 4, 8, 4),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _chooseDailyLimit,
              leading: const Icon(
                Icons.format_list_numbered_rounded,
                color: accentColor,
              ),
              title: const Text('Слов в день'),
              subtitle: const Text('Один учтённый ответ на слово в день'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_dailyLimit',
                    style: const TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: mutedColor),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 8, 12, 8),
          child: Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _enabled,
              onChanged: _updating ? null : _toggleReminder,
              activeTrackColor: accentColor,
              title: const Text(
                'Ежедневное напоминание',
                style: TextStyle(color: inkColor, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Локальное уведомление на этом устройстве'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(18, 4, 8, 4),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              enabled: !_updating,
              onTap: _chooseTime,
              leading: const Icon(
                Icons.access_time_rounded,
                color: accentColor,
              ),
              title: const Text('Время'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _time.format(context),
                    style: const TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, color: mutedColor),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyLimitDialog extends StatefulWidget {
  const _DailyLimitDialog({required this.initialLimit});

  final int initialLimit;

  @override
  State<_DailyLimitDialog> createState() => _DailyLimitDialogState();
}

class _DailyLimitDialogState extends State<_DailyLimitDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.initialLimit}',
  );
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final limit = int.tryParse(_controller.text);
    if (limit == null || limit < 1) {
      setState(() => _errorText = 'Укажи число больше нуля.');
      return;
    }
    Navigator.of(context).pop(limit);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Слов в день'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: 'Дневной лимит',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }
}
