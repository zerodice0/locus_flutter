import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/features/place_discovery/domain/entities/search_settings.dart';
import 'package:locus_flutter/features/place_discovery/presentation/providers/search_provider.dart';
import 'package:locus_flutter/features/place_discovery/presentation/widgets/category_filter.dart';
import 'package:locus_flutter/features/place_discovery/presentation/widgets/radius_slider.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';

class SearchSettingsPage extends ConsumerStatefulWidget {
  const SearchSettingsPage({super.key});

  @override
  ConsumerState<SearchSettingsPage> createState() => _SearchSettingsPageState();
}

class _SearchSettingsPageState extends ConsumerState<SearchSettingsPage> {
  late SearchSettings _localSettings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _localSettings = ref.read(searchSettingsProvider);
  }

  void _updateLocalSettings(SearchSettings newSettings) {
    setState(() {
      _localSettings = newSettings;
      _hasChanges = true;
    });
  }

  Future<void> _saveSettings() async {
    try {
      await ref.read(searchSettingsProvider.notifier).updateSettings(_localSettings);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정이 저장되었습니다')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정 저장 실패: $e')),
        );
      }
    }
  }

  void _resetToDefaults() {
    setState(() {
      _localSettings = const SearchSettings();
      _hasChanges = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색 설정'),
        actions: [
          TextButton(
            onPressed: _hasChanges ? _saveSettings : null,
            child: const Text('저장'),
          ),
        ],
      ),
      body: categories.when(
        data: (categoryList) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('검색 반경'),
              const SizedBox(height: 8),
              RadiusSlider(
                value: _localSettings.radiusKm,
                onChanged: (value) {
                  _updateLocalSettings(_localSettings.copyWith(radiusKm: value));
                },
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('카테고리 필터'),
              const SizedBox(height: 8),
              CategoryFilter(
                categories: categoryList,
                selectedCategoryIds: _localSettings.categoryIds,
                onSelectionChanged: (selectedIds) {
                  _updateLocalSettings(_localSettings.copyWith(categoryIds: selectedIds));
                },
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('정렬 방식'),
              const SizedBox(height: 8),
              _buildSortOrderSelector(),
              const SizedBox(height: 24),

              _buildSectionHeader('고급 옵션'),
              const SizedBox(height: 8),
              _buildAdvancedOptions(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resetToDefaults,
                  child: const Text('기본값으로 초기화'),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('카테고리 로딩 실패: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(categoriesProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSortOrderSelector() {
    return Column(
      children: SearchSortOrder.values.map((order) {
        return RadioListTile<SearchSortOrder>(
          title: Text(order.displayName),
          value: order,
          groupValue: _localSettings.sortOrder,
          onChanged: (value) {
            if (value != null) {
              _updateLocalSettings(_localSettings.copyWith(sortOrder: value));
            }
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  Widget _buildAdvancedOptions() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('운영시간 고려'),
          subtitle: const Text('현재 운영 중인 장소만 표시'),
          value: _localSettings.considerOperatingHours,
          onChanged: (value) {
            _updateLocalSettings(_localSettings.copyWith(considerOperatingHours: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('이벤트 기간 고려'),
          subtitle: const Text('이벤트 기간 내의 장소만 표시'),
          value: _localSettings.considerEventPeriod,
          onChanged: (value) {
            _updateLocalSettings(_localSettings.copyWith(considerEventPeriod: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('적응형 반경'),
          subtitle: const Text('장소가 적으면 자동으로 반경 확장'),
          value: _localSettings.adaptiveRadius,
          onChanged: (value) {
            _updateLocalSettings(_localSettings.copyWith(adaptiveRadius: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}