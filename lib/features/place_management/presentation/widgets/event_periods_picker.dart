import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class EventPeriodsPicker extends StatefulWidget {
  final List<EventPeriod> eventPeriods;
  final Function(List<EventPeriod>) onChanged;
  final String? errorText;

  const EventPeriodsPicker({
    super.key,
    required this.eventPeriods,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<EventPeriodsPicker> createState() => _EventPeriodsPickerState();
}

class _EventPeriodsPickerState extends State<EventPeriodsPicker> {
  late List<EventPeriod> _eventPeriods;

  @override
  void initState() {
    super.initState();
    _eventPeriods = List.from(widget.eventPeriods);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '이벤트 기간',
              style: AppTheme.labelLarge.copyWith(
                color: widget.errorText != null ? AppTheme.errorRed : null,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: _addEventPeriod,
              icon: const Icon(Icons.add),
              tooltip: '이벤트 추가',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_eventPeriods.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null ? AppTheme.errorRed : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '이벤트 기간이 없습니다',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+ 버튼을 눌러 이벤트를 추가하세요',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.errorText != null ? AppTheme.errorRed : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: _eventPeriods.asMap().entries.map((entry) {
                final index = entry.key;
                final event = entry.value;
                return _buildEventItem(event, index);
              }).toList(),
            ),
          ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
          ),
        ],
      ],
    );
  }

  Widget _buildEventItem(EventPeriod event, int index) {
    final isLast = index == _eventPeriods.length - 1;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: event.isActive 
                        ? AppTheme.successGreen.withOpacity(0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    event.isActive ? '진행중' : '종료',
                    style: AppTheme.bodySmall.copyWith(
                      color: event.isActive 
                          ? AppTheme.successGreen
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _editEventPeriod(index),
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                IconButton(
                  onPressed: () => _removeEventPeriod(index),
                  icon: const Icon(Icons.delete),
                  iconSize: 20,
                  color: AppTheme.errorRed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(event.startDate)} - ${_formatDate(event.endDate)}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_calculateDuration(event.startDate, event.endDate)}일간',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (event.description != null && event.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  void _addEventPeriod() {
    _showEventDialog();
  }

  void _editEventPeriod(int index) {
    _showEventDialog(existingEvent: _eventPeriods[index], index: index);
  }

  void _removeEventPeriod(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이벤트 삭제'),
        content: Text('${_eventPeriods[index].name} 이벤트를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _eventPeriods.removeAt(index);
              });
              widget.onChanged(_eventPeriods);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEventDialog({EventPeriod? existingEvent, int? index}) async {
    final nameController = TextEditingController(text: existingEvent?.name ?? '');
    final descriptionController = TextEditingController(text: existingEvent?.description ?? '');
    DateTime startDate = existingEvent?.startDate ?? DateTime.now();
    DateTime endDate = existingEvent?.endDate ?? DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existingEvent != null ? '이벤트 수정' : '이벤트 추가'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '이벤트 이름',
                    hintText: '예: 할인 이벤트',
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('시작일'),
                        subtitle: Text(_formatDate(startDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: startDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppTheme.primaryGreen,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selected != null) {
                            setState(() {
                              startDate = selected;
                              if (endDate.isBefore(startDate)) {
                                endDate = startDate.add(const Duration(days: 1));
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('종료일'),
                        subtitle: Text(_formatDate(endDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: endDate,
                            firstDate: startDate,
                            lastDate: DateTime(2030),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: AppTheme.primaryGreen,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selected != null) {
                            setState(() => endDate = selected);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '설명 (선택사항)',
                    hintText: '이벤트에 대한 간단한 설명',
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('이벤트 이름을 입력해주세요'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                final newEvent = EventPeriod(
                  id: existingEvent?.id ?? '',
                  placeId: existingEvent?.placeId ?? '',
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty 
                      ? null 
                      : descriptionController.text.trim(),
                  startDate: startDate,
                  endDate: endDate,
                );

                setState(() {
                  if (index != null) {
                    _eventPeriods[index] = newEvent;
                  } else {
                    _eventPeriods.add(newEvent);
                  }
                });
                
                widget.onChanged(_eventPeriods);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
              ),
              child: Text(existingEvent != null ? '수정' : '추가'),
            ),
          ],
        ),
      ),
    );
  }
}