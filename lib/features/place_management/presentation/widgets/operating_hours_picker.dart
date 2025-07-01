import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class OperatingHoursPicker extends StatefulWidget {
  final List<OperatingHours> operatingHours;
  final Function(List<OperatingHours>) onChanged;
  final String? errorText;

  const OperatingHoursPicker({
    super.key,
    required this.operatingHours,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<OperatingHoursPicker> createState() => _OperatingHoursPickerState();
}

class _OperatingHoursPickerState extends State<OperatingHoursPicker> {
  late List<OperatingHours> _hours;

  @override
  void initState() {
    super.initState();
    _initializeHours();
  }

  void _initializeHours() {
    _hours = List.from(widget.operatingHours);
    
    // 기본 요일 7일이 없으면 생성
    final existingDays = _hours.map((h) => h.dayOfWeek).toSet();
    for (int day = 1; day <= 7; day++) {
      if (!existingDays.contains(day)) {
        _hours.add(OperatingHours(
          id: '',
          placeId: '',
          dayOfWeek: day,
          openTime: '09:00',
          closeTime: '18:00',
          isClosed: false,
        ));
      }
    }
    
    // 요일 순서로 정렬
    _hours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '운영시간',
              style: AppTheme.labelLarge.copyWith(
                color: widget.errorText != null ? AppTheme.errorRed : null,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _showQuickSetDialog,
              child: const Text('일괄 설정'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorText != null ? AppTheme.errorRed : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _hours.map((hours) => _buildDayItem(hours)).toList(),
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

  Widget _buildDayItem(OperatingHours hours) {
    final isFirst = hours.dayOfWeek == 1;
    final isLast = hours.dayOfWeek == 7;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: Colors.grey.shade200),
        ),
        borderRadius: BorderRadius.only(
          topLeft: isFirst ? const Radius.circular(12) : Radius.zero,
          topRight: isFirst ? const Radius.circular(12) : Radius.zero,
          bottomLeft: isLast ? const Radius.circular(12) : Radius.zero,
          bottomRight: isLast ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Day name
            SizedBox(
              width: 40,
              child: Text(
                _getDayName(hours.dayOfWeek),
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isWeekend(hours.dayOfWeek) ? AppTheme.errorRed : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Closed switch
            SizedBox(
              width: 60,
              child: Switch(
                value: !hours.isClosed,
                onChanged: (isOpen) => _updateHours(hours.copyWith(isClosed: !isOpen)),
                activeColor: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 16),
            
            // Time selectors
            if (!hours.isClosed) ...[
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        label: '개점',
                        time: hours.openTime ?? '09:00',
                        onChanged: (time) => _updateHours(hours.copyWith(openTime: time)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimeSelector(
                        label: '폐점',
                        time: hours.closeTime ?? '18:00',
                        onChanged: (time) => _updateHours(hours.copyWith(closeTime: time)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '휴무',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector({
    required String label,
    required String time,
    required Function(String) onChanged,
  }) {
    return GestureDetector(
      onTap: () => _selectTime(time, onChanged),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return '월';
      case 2:
        return '화';
      case 3:
        return '수';
      case 4:
        return '목';
      case 5:
        return '금';
      case 6:
        return '토';
      case 7:
        return '일';
      default:
        return '';
    }
  }

  bool _isWeekend(int dayOfWeek) {
    return dayOfWeek == 6 || dayOfWeek == 7; // 토요일, 일요일
  }

  void _updateHours(OperatingHours updatedHours) {
    final index = _hours.indexWhere((h) => h.dayOfWeek == updatedHours.dayOfWeek);
    if (index != -1) {
      _hours[index] = updatedHours;
      widget.onChanged(_hours);
    }
  }

  Future<void> _selectTime(String currentTime, Function(String) onChanged) async {
    final timeParts = currentTime.split(':');
    final currentHour = int.tryParse(timeParts[0]) ?? 9;
    final currentMinute = int.tryParse(timeParts[1]) ?? 0;
    
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final formattedTime = '${selectedTime.hour.toString().padLeft(2, '0')}:'
          '${selectedTime.minute.toString().padLeft(2, '0')}';
      onChanged(formattedTime);
    }
  }

  Future<void> _showQuickSetDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운영시간 일괄 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('평일 9:00-18:00'),
              subtitle: const Text('월~금요일'),
              onTap: () => _applyQuickSet(
                weekdays: true,
                openTime: '09:00',
                closeTime: '18:00',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('일반 매장 10:00-22:00'),
              subtitle: const Text('월~일요일'),
              onTap: () => _applyQuickSet(
                all: true,
                openTime: '10:00',
                closeTime: '22:00',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text('음식점 11:00-21:00'),
              subtitle: const Text('화~일요일 (월요일 휴무)'),
              onTap: () => _applyQuickSet(
                all: true,
                openTime: '11:00',
                closeTime: '21:00',
                closedDays: [1], // 월요일
              ),
            ),
            ListTile(
              leading: const Icon(Icons.local_cafe),
              title: const Text('카페 8:00-20:00'),
              subtitle: const Text('매일 운영'),
              onTap: () => _applyQuickSet(
                all: true,
                openTime: '08:00',
                closeTime: '20:00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _applyQuickSet({
    bool weekdays = false,
    bool all = false,
    required String openTime,
    required String closeTime,
    List<int>? closedDays,
  }) {
    for (int i = 0; i < _hours.length; i++) {
      final dayOfWeek = _hours[i].dayOfWeek;
      
      bool shouldApply = false;
      bool shouldClose = closedDays?.contains(dayOfWeek) ?? false;
      
      if (all) {
        shouldApply = true;
      } else if (weekdays && dayOfWeek >= 1 && dayOfWeek <= 5) {
        shouldApply = true;
      }
      
      if (shouldApply) {
        _hours[i] = _hours[i].copyWith(
          openTime: openTime,
          closeTime: closeTime,
          isClosed: shouldClose,
        );
      }
    }
    
    widget.onChanged(_hours);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('운영시간이 일괄 설정되었습니다'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }
}