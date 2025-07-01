import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  ConsumerState<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  bool _isLoading = false;

  // 사용 가능한 아이콘 목록
  static const List<Map<String, dynamic>> _availableIcons = [
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': '음식점'},
    {'name': 'local_cafe', 'icon': Icons.local_cafe, 'label': '카페'},
    {'name': 'shopping_bag', 'icon': Icons.shopping_bag, 'label': '쇼핑'},
    {'name': 'movie', 'icon': Icons.movie, 'label': '영화관'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': '병원'},
    {'name': 'school', 'icon': Icons.school, 'label': '학교'},
    {'name': 'home', 'icon': Icons.home, 'label': '집'},
    {'name': 'work', 'icon': Icons.work, 'label': '직장'},
    {'name': 'local_gas_station', 'icon': Icons.local_gas_station, 'label': '주유소'},
    {'name': 'fitness_center', 'icon': Icons.fitness_center, 'label': '헬스장'},
    {'name': 'hotel', 'icon': Icons.hotel, 'label': '호텔'},
    {'name': 'local_library', 'icon': Icons.local_library, 'label': '도서관'},
    {'name': 'park', 'icon': Icons.park, 'label': '공원'},
    {'name': 'beach_access', 'icon': Icons.beach_access, 'label': '해변'},
    {'name': 'hiking', 'icon': Icons.hiking, 'label': '등산'},
    {'name': 'local_pharmacy', 'icon': Icons.local_pharmacy, 'label': '약국'},
  ];

  // 사용 가능한 색상 목록
  static const List<Map<String, dynamic>> _availableColors = [
    {'name': 'red', 'color': Colors.red, 'label': '빨강'},
    {'name': 'blue', 'color': Colors.blue, 'label': '파랑'},
    {'name': 'green', 'color': Colors.green, 'label': '초록'},
    {'name': 'orange', 'color': Colors.orange, 'label': '주황'},
    {'name': 'purple', 'color': Colors.purple, 'label': '보라'},
    {'name': 'teal', 'color': Colors.teal, 'label': '청록'},
    {'name': 'pink', 'color': Colors.pink, 'label': '분홍'},
    {'name': 'indigo', 'color': Colors.indigo, 'label': '남색'},
    {'name': 'brown', 'color': Colors.brown, 'label': '갈색'},
    {'name': 'grey', 'color': Colors.grey, 'label': '회색'},
  ];

  @override
  void initState() {
    super.initState();
    // 폼 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryFormProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(categoryFormProvider);
    final formNotifier = ref.read(categoryFormProvider.notifier);

    return AlertDialog(
      title: const Text('새 카테고리 추가'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리 이름 입력
              _buildNameField(formState, formNotifier),
              const SizedBox(height: 24),

              // 아이콘 선택
              _buildIconSelector(formState, formNotifier),
              const SizedBox(height: 24),

              // 색상 선택
              _buildColorSelector(formState, formNotifier),
              const SizedBox(height: 16),

              // 미리보기
              _buildPreview(formState),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading || !formState.isValid ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('추가'),
        ),
      ],
    );
  }

  Widget _buildNameField(CategoryFormState formState, CategoryFormNotifier formNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '카테고리 이름',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: formState.name,
          onChanged: formNotifier.updateName,
          decoration: InputDecoration(
            hintText: '예: 맛집, 놀거리, 볼거리',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorText: formState.nameError,
            prefixIcon: const Icon(Icons.label),
          ),
          maxLength: 50,
        ),
      ],
    );
  }

  Widget _buildIconSelector(CategoryFormState formState, CategoryFormNotifier formNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '아이콘',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = _availableIcons[index];
              final isSelected = formState.icon == iconData['name'];

              return InkWell(
                onTap: () => formNotifier.updateIcon(iconData['name']),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.1) : null,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData['icon'],
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                    size: 20,
                  ),
                ),
              );
            },
          ),
        ),
        if (formState.iconError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              formState.iconError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildColorSelector(CategoryFormState formState, CategoryFormNotifier formNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '색상',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((colorData) {
            final isSelected = formState.color == colorData['name'];

            return InkWell(
              onTap: () => formNotifier.updateColor(colorData['name']),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorData['color'],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        if (formState.colorError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              formState.colorError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildPreview(CategoryFormState formState) {
    if (formState.name.isEmpty || formState.icon.isEmpty || formState.color.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '미리보기',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getColorFromName(formState.color),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromName(formState.icon),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formState.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      '사용자 카테고리',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final formNotifier = ref.read(categoryFormProvider.notifier);
      final categoriesNotifier = ref.read(categoriesProvider.notifier);
      final addCategoryUseCase = ref.read(addCategoryUseCaseProvider);
      final validateCategoryNameUseCase = ref.read(validateCategoryNameUseCaseProvider);

      final formState = ref.read(categoryFormProvider);

      // 이름 중복 검사
      final isNameValid = await validateCategoryNameUseCase(formState.name.trim());
      if (!isNameValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미 존재하는 카테고리 이름입니다'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // 카테고리 생성 및 저장
      final newCategory = formNotifier.createCategory();
      final savedCategoryId = await addCategoryUseCase(newCategory);
      
      // 저장된 카테고리를 다시 가져와서 ID를 포함한 완전한 객체 생성
      final savedCategory = newCategory.copyWith(id: savedCategoryId);

      // UI 업데이트
      categoriesNotifier.addCategory(savedCategory);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${savedCategory.name} 카테고리가 추가되었습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카테고리 추가 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getColorFromName(String colorName) {
    final colorData = _availableColors.firstWhere(
      (data) => data['name'] == colorName,
      orElse: () => _availableColors.first,
    );
    return colorData['color'];
  }

  IconData _getIconFromName(String iconName) {
    final iconData = _availableIcons.firstWhere(
      (data) => data['name'] == iconName,
      orElse: () => _availableIcons.first,
    );
    return iconData['icon'];
  }
}