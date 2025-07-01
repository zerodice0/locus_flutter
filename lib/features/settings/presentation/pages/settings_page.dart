import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';
import 'category_management_page.dart';
import 'data_management_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingSection(
            context,
            title: '지도 설정',
            children: [
              _buildSettingTile(
                context,
                icon: Icons.map,
                title: '지도 서비스',
                subtitle: '자동 선택',
                onTap: () {},
              ),
              _buildSettingTile(
                context,
                icon: Icons.my_location,
                title: '기본 검색 반경',
                subtitle: '2km',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingSection(
            context,
            title: '데이터 관리',
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(categoriesProvider);
                  final categoriesCount = categoriesAsync.maybeWhen(
                    data: (categories) => categories.length,
                    orElse: () => 0,
                  );
                  
                  return _buildSettingTile(
                    context,
                    icon: Icons.folder,
                    title: '카테고리 관리',
                    subtitle: '$categoriesCount개 카테고리',
                    onTap: () => _navigateToCategoryManagement(),
                  );
                },
              ),
              _buildSettingTile(
                context,
                icon: Icons.backup,
                title: '데이터 백업',
                subtitle: '데이터 내보내기/가져오기',
                onTap: () => _navigateToDataManagement(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingSection(
            context,
            title: '앱 정보',
            children: [
              _buildSettingTile(
                context,
                icon: Icons.info,
                title: '버전 정보',
                subtitle: '1.0.0',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateToCategoryManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoryManagementPage(),
      ),
    );
  }

  void _navigateToDataManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DataManagementPage(),
      ),
    );
  }
}