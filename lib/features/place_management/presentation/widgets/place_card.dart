import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/core/constants/map_constants.dart';

class PlaceCard extends ConsumerWidget {
  final Place place;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onVisit;
  final double? distanceFromUser;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onVisit,
    this.distanceFromUser,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesNotifier = ref.read(categoriesProvider.notifier);
    final category = categoriesNotifier.getCategoryById(place.categoryId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Category icon
                  if (category != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xFF${category.color}')).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconData(category.icon),
                        color: Color(int.parse('0xFF${category.color}')),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  
                  // Place info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.name,
                          style: AppTheme.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (category != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            category.name,
                            style: AppTheme.bodySmall.copyWith(
                              color: Color(int.parse('0xFF${category.color}')),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Status indicators
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (place.hasRating) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              place.displayRating,
                              style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (distanceFromUser != null) ...[
                        Text(
                          MapConstants.formatDistance(distanceFromUser!),
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Description
              if (place.description != null && place.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  place.description!,
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Address
              if (place.address != null && place.address!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey.shade500,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address!,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              
              // Status row
              const SizedBox(height: 12),
              Row(
                children: [
                  // Operating status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: place.isCurrentlyOpen 
                          ? AppTheme.successGreen.withOpacity(0.2)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      place.operatingStatus,
                      style: AppTheme.bodySmall.copyWith(
                        color: place.isCurrentlyOpen 
                            ? AppTheme.successGreen
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Visit count
                  Text(
                    place.visitCountText,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onVisit != null)
                        IconButton(
                          onPressed: onVisit,
                          icon: const Icon(Icons.check_circle_outline),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: '방문 체크',
                        ),
                      if (onEdit != null)
                        IconButton(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit_outlined),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: '수정',
                        ),
                      if (onDelete != null)
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          color: AppTheme.errorRed,
                          tooltip: '삭제',
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'place':
        return Icons.place;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'more_horiz':
      default:
        return Icons.more_horiz;
    }
  }
}