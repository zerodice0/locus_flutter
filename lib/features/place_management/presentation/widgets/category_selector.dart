import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';

class CategorySelector extends ConsumerWidget {
  final String? selectedCategoryId;
  final Function(String categoryId) onCategorySelected;
  final String? errorText;

  const CategorySelector({
    super.key,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.errorText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: AppTheme.labelLarge.copyWith(
            color: errorText != null ? AppTheme.errorRed : null,
          ),
        ),
        const SizedBox(height: 8),
        categoriesAsync.when(
          data: (categories) => _buildCategoryGrid(context, categories),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, _) => Center(
            child: Text(
              '카테고리를 불러올 수 없습니다',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.errorRed),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Category> categories) {
    if (categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            '사용 가능한 카테고리가 없습니다',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: errorText != null ? AppTheme.errorRed : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;
          
          return _buildCategoryItem(context, category, isSelected);
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category, bool isSelected) {
    final color = Color(int.parse('0xFF${category.color}'));
    
    return GestureDetector(
      onTap: () => onCategorySelected(category.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(category.icon),
              color: isSelected ? color : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: AppTheme.bodySmall.copyWith(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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