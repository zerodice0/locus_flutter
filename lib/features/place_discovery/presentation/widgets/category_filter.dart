import 'package:flutter/material.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';

class CategoryFilter extends StatelessWidget {
  final List<Category> categories;
  final List<String> selectedCategoryIds;
  final ValueChanged<List<String>> onSelectionChanged;

  const CategoryFilter({
    super.key,
    required this.categories,
    required this.selectedCategoryIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('카테고리 선택'),
                TextButton(
                  onPressed: _toggleSelectAll,
                  child: Text(
                    _isAllSelected ? '전체 해제' : '전체 선택',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (selectedCategoryIds.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '카테고리를 선택하지 않으면 모든 카테고리가 포함됩니다',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = selectedCategoryIds.contains(category.id);
                  return _buildCategoryChip(context, category, isSelected);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, Category category, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIconData(category.icon),
            size: 16,
            color: isSelected ? Colors.white : _getColorFromHex(category.color),
          ),
          const SizedBox(width: 4),
          Text(category.name),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) => _toggleCategory(category.id, selected),
      selectedColor: _getColorFromHex(category.color),
      backgroundColor: _getColorFromHex(category.color).withOpacity(0.1),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
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
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  bool get _isAllSelected {
    return selectedCategoryIds.length == categories.length;
  }

  void _toggleSelectAll() {
    if (_isAllSelected) {
      onSelectionChanged([]);
    } else {
      onSelectionChanged(categories.map((c) => c.id).toList());
    }
  }

  void _toggleCategory(String categoryId, bool selected) {
    final newSelection = List<String>.from(selectedCategoryIds);
    
    if (selected) {
      if (!newSelection.contains(categoryId)) {
        newSelection.add(categoryId);
      }
    } else {
      newSelection.remove(categoryId);
    }
    
    onSelectionChanged(newSelection);
  }
}