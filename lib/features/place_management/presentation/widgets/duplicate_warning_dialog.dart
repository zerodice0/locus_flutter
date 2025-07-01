import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/constants/map_constants.dart';

class DuplicateWarningDialog extends StatelessWidget {
  final Place newPlace;
  final List<Place> duplicateCandiates;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const DuplicateWarningDialog({
    super.key,
    required this.newPlace,
    required this.duplicateCandiates,
    required this.onProceed,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('중복 장소 발견'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추가하려는 장소와 비슷한 위치에 다음 장소들이 이미 저장되어 있습니다:',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            
            // New place info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.add_location,
                        color: AppTheme.primaryBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '추가할 장소',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    newPlace.name,
                    style: AppTheme.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (newPlace.address != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      newPlace.address!,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Existing places
            Text(
              '기존 장소들:',
              style: AppTheme.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: duplicateCandiates.length,
                itemBuilder: (context, index) {
                  final place = duplicateCandiates[index];
                  final distance = newPlace.distanceFrom(place.latitude, place.longitude);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                place.name,
                                style: AppTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getDistanceColor(distance).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                MapConstants.formatDistance(distance),
                                style: AppTheme.bodySmall.copyWith(
                                  color: _getDistanceColor(distance),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (place.address != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            place.address!,
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '등록일: ${place.createdAtFormatted}',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.visibility,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.visitCountText,
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '같은 장소를 중복으로 저장하지 않도록 주의해주세요.',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
          child: const Text('그래도 추가'),
        ),
      ],
    );
  }

  Color _getDistanceColor(double distance) {
    if (distance < 0.05) { // 50m 이내
      return AppTheme.errorRed;
    } else if (distance < 0.1) { // 100m 이내
      return Colors.orange;
    } else if (distance < 0.2) { // 200m 이내
      return Colors.amber;
    } else {
      return AppTheme.primaryBlue;
    }
  }
}