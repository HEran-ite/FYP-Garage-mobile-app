import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/error/user_friendly_errors.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../availability/data/models/availability_slot_model.dart';
import '../../../availability/domain/repositories/availability_repository.dart';

/// Day label for display
const List<String> _dayLabels = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _dayOfWeekValues = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

/// One time slot (opening/closing) for a day
class _TimeSlot {
  _TimeSlot({this.opening = '08:00', this.closing = '18:00'});
  String opening;
  String closing;
}

/// One day's state: open or closed, list of time slots (empty = no default)
class _DayState {
  _DayState({this.isOpen = true, List<_TimeSlot>? slots}) : slots = slots ?? [];
  bool isOpen;
  List<_TimeSlot> slots;
}

/// Parse "HH:mm" to minutes since midnight. Returns 0-1439.
int _timeToMinutes(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return 0;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return (h.clamp(0, 23) * 60 + m.clamp(0, 59)).clamp(0, 1439);
}

/// Format minutes since midnight to "HH:mm" (24h, for API).
String _minutesToTime(int minutes) {
  final m = minutes.clamp(0, 1439);
  final h = m ~/ 60;
  final min = m % 60;
  return '${h.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')}';
}

/// Format "HH:mm" (24h) to 12-hour display e.g. "2:30 PM", "12:00 AM".
String _formatTime24To12(String time24) {
  final parts = time24.split(':');
  if (parts.length < 2) return time24;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  final hour = h.clamp(0, 23);
  final minute = m.clamp(0, 59);
  final period = hour >= 12 ? 'PM' : 'AM';
  final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$hour12:${minute.toString().padLeft(2, '0')} $period';
}

/// Merge overlapping or adjacent time slots (same day). Returns new list.
List<_TimeSlot> _mergeSlots(List<_TimeSlot> slots) {
  if (slots.isEmpty) return [];
  final withMinutes = slots
      .where((s) => s.opening.isNotEmpty && s.closing.isNotEmpty)
      .map((s) => (_timeToMinutes(s.opening), _timeToMinutes(s.closing)))
      .where((p) => p.$1 < p.$2)
      .toList();
  if (withMinutes.isEmpty) return [];
  withMinutes.sort((a, b) => a.$1.compareTo(b.$1));
  final merged = <({int start, int end})>[];
  var start = withMinutes[0].$1;
  var end = withMinutes[0].$2;
  for (var i = 1; i < withMinutes.length; i++) {
    final nextStart = withMinutes[i].$1;
    final nextEnd = withMinutes[i].$2;
    if (nextStart <= end) {
      if (nextEnd > end) end = nextEnd;
    } else {
      merged.add((start: start, end: end));
      start = nextStart;
      end = nextEnd;
    }
  }
  merged.add((start: start, end: end));
  return merged
      .map((p) => _TimeSlot(
            opening: _minutesToTime(p.start),
            closing: _minutesToTime(p.end),
          ))
      .toList();
}

/// Set Availability screen: configure working hours per day.
class SetAvailabilityPage extends StatefulWidget {
  const SetAvailabilityPage({
    super.key,
    required this.repository,
  });

  final AvailabilityRepository repository;

  @override
  State<SetAvailabilityPage> createState() => _SetAvailabilityPageState();
}

class _SetAvailabilityPageState extends State<SetAvailabilityPage> {
  late List<_DayState> _days;
  bool _loading = true;
  String? _error;
  bool _saving = false;
  List<AvailabilitySlotModel> _existingSlots = [];

  @override
  void initState() {
    super.initState();
    _days = List.generate(7, (_) => _DayState(isOpen: true, slots: []));
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final slots = await widget.repository.listSlots();
      setState(() {
        _existingSlots = slots;
        _applySlotsToDays(slots);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _applySlotsToDays(List<AvailabilitySlotModel> slots) {
    for (var i = 0; i < 7; i++) {
      final dayValue = _dayOfWeekValues[i];
      final daySlots = slots.where((s) => s.dayOfWeek == dayValue).toList();
      if (daySlots.isEmpty) {
        _days[i] = _DayState(isOpen: true, slots: []);
        continue;
      }
      final raw = daySlots
          .map((s) => _TimeSlot(opening: s.startTime, closing: s.endTime))
          .toList();
      _days[i] = _DayState(isOpen: true, slots: _mergeSlots(raw));
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      for (final slot in _existingSlots) {
        await widget.repository.deleteSlot(slot.id);
      }
      for (var i = 0; i < 7; i++) {
        if (!_days[i].isOpen) continue;
        final merged = _mergeSlots(_days[i].slots);
        for (final ts in merged) {
          if (ts.opening.isEmpty || ts.closing.isEmpty) continue;
          await widget.repository.createSlot(
            dayOfWeek: _dayOfWeekValues[i],
            startTime: ts.opening,
            endTime: ts.closing,
          );
        }
      }
      _existingSlots = await widget.repository.listSlots();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(toUserFriendlyMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Availability',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            Text(
              'Configure your working hours.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton(
                          onPressed: _loadSlots,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < 7; i++) ...[
                        _DayCard(
                          dayLabel: _dayLabels[i],
                          state: _days[i],
                          onToggle: (open) {
                            setState(() {
                              _days[i] = _DayState(
                                isOpen: open,
                                slots: _days[i].slots,
                              );
                            });
                          },
                          onSlotsChanged: () => setState(() {}),
                          onAddSlot: () {
                            setState(() => _days[i].slots.add(_TimeSlot()));
                          },
                          onDeleteSlot: (slotIndex) {
                            setState(() {
                              _days[i].slots.removeAt(slotIndex);
                            });
                          },
                        ),
                        if (i < 6) const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppBorderRadius.md),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textPrimary,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.dayLabel,
    required this.state,
    required this.onToggle,
    required this.onSlotsChanged,
    required this.onAddSlot,
    required this.onDeleteSlot,
  });

  final String dayLabel;
  final _DayState state;
  final ValueChanged<bool> onToggle;
  final VoidCallback onSlotsChanged;
  final VoidCallback onAddSlot;
  final ValueChanged<int> onDeleteSlot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                dayLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
              ),
              const Spacer(),
              _OpenClosedPill(
                isOpen: state.isOpen,
                onTap: () => onToggle(!state.isOpen),
              ),
            ],
          ),
          if (state.isOpen) ...[
            const SizedBox(height: AppSpacing.md),
            ...state.slots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Time Slot ${index + 1}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => onDeleteSlot(index),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 22,
                            color: AppColors.error,
                          ),
                          tooltip: 'Remove time slot',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeField(
                            label: 'Opening',
                            value: slot.opening,
                            onChanged: (v) {
                              slot.opening = v;
                              onSlotsChanged();
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _TimeField(
                            label: 'Closing',
                            value: slot.closing,
                            onChanged: (v) {
                              slot.closing = v;
                              onSlotsChanged();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: onAddSlot,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Time Slot'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpenClosedPill extends StatelessWidget {
  const _OpenClosedPill({required this.isOpen, this.onTap});

  final bool isOpen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isOpen
                ? AppColors.success
                : AppColors.textSecondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Text(
            isOpen ? 'Open' : 'Closed',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isOpen ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = _formatTime24To12(value);
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: displayValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.access_time, size: 20, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      onTap: () async {
        final parts = value.split(':');
        final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 8 : 8;
        final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: hour, minute: minute),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          },
        );
        if (time != null) {
          final s = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          onChanged(s);
        }
      },
      onChanged: (v) {
        if (_isValidTime(v)) onChanged(v);
      },
      readOnly: true,
    );
  }

  static bool _isValidTime(String v) {
    if (v.length != 5) return false;
    final parts = v.split(':');
    if (parts.length != 2) return false;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    return h != null && m != null && h >= 0 && h <= 23 && m >= 0 && m <= 59;
  }
}
