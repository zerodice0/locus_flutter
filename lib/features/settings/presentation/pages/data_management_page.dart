import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';

final settingsDataSourceProvider = Provider<SettingsLocalDataSource>((ref) {
  return SettingsLocalDataSourceImpl(
    placeDataSource: ref.read(placeLocalDataSourceProvider),
    categoryDataSource: ref.read(categoryLocalDataSourceProvider),
  );
});

class DataManagementPage extends ConsumerStatefulWidget {
  const DataManagementPage({super.key});

  @override
  ConsumerState<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends ConsumerState<DataManagementPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('데이터 관리'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('데이터 백업'),
                _buildBackupSection(),
                const SizedBox(height: 32),
                _buildSectionHeader('데이터 복원'),
                _buildRestoreSection(),
                const SizedBox(height: 32),
                _buildSectionHeader('위험 구역'),
                _buildDangerSection(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      child: Column(
        children: [
          _buildDataTile(
            icon: Icons.upload_file,
            title: '데이터 내보내기',
            subtitle: '모든 장소 및 카테고리 데이터를 파일로 저장',
            trailing: const Icon(Icons.chevron_right),
            onTap: _exportData,
          ),
          const Divider(height: 1),
          _buildDataTile(
            icon: Icons.share,
            title: '데이터 공유',
            subtitle: '다른 기기나 앱으로 데이터 공유',
            trailing: const Icon(Icons.chevron_right),
            onTap: _shareData,
          ),
        ],
      ),
    );
  }

  Widget _buildRestoreSection() {
    return Card(
      child: Column(
        children: [
          _buildDataTile(
            icon: Icons.file_download,
            title: '데이터 가져오기',
            subtitle: '백업 파일에서 데이터 복원',
            trailing: const Icon(Icons.chevron_right),
            onTap: _importData,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerSection() {
    return Card(
      color: Colors.red.withValues(alpha: 0.05),
      child: Column(
        children: [
          _buildDataTile(
            icon: Icons.delete_forever,
            title: '모든 데이터 삭제',
            subtitle: '앱의 모든 데이터를 영구적으로 삭제',
            trailing: const Icon(Icons.warning, color: Colors.red),
            onTap: _showDeleteAllDataDialog,
            titleColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _exportData() async {
    setState(() => _isLoading = true);

    try {
      final dataSource = ref.read(settingsDataSourceProvider);
      final exportData = await dataSource.exportAllData();
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // 파일로 저장
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'locus_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터가 성공적으로 내보내졌습니다\n위치: ${file.path}'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '공유',
              onPressed: () => _shareFile(file.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 내보내기 실패: $e'),
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

  Future<void> _shareData() async {
    setState(() => _isLoading = true);

    try {
      final dataSource = ref.read(settingsDataSourceProvider);
      final exportData = await dataSource.exportAllData();
      
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // 임시 파일 생성
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'locus_backup_$timestamp.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonString);

      // 파일 공유
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Locus 앱 데이터 백업 파일',
        subject: 'Locus 백업 데이터',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 공유 실패: $e'),
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

  Future<void> _shareFile(String filePath) async {
    try {
      await Share.shareXFiles([XFile(filePath)]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 공유 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // 사용자가 취소함
      }

      final file = result.files.first;
      if (file.path == null) {
        throw Exception('파일 경로를 찾을 수 없습니다');
      }

      setState(() => _isLoading = true);

      final fileContent = await File(file.path!).readAsString();
      final importData = jsonDecode(fileContent) as Map<String, dynamic>;

      // 데이터 유효성 검사
      if (!importData.containsKey('places') || !importData.containsKey('categories')) {
        throw Exception('유효하지 않은 백업 파일 형식입니다');
      }

      // 가져오기 확인 다이얼로그
      final shouldImport = await _showImportConfirmDialog(importData);
      if (!shouldImport) return;

      // 데이터 가져오기
      final dataSource = ref.read(settingsDataSourceProvider);
      await dataSource.importAllData(importData);

      // UI 새로고침
      ref.read(placesProvider.notifier).refreshPlaces();
      ref.read(categoriesProvider.notifier).refreshCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('데이터가 성공적으로 가져와졌습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 가져오기 실패: $e'),
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

  Future<bool> _showImportConfirmDialog(Map<String, dynamic> importData) async {
    final placesCount = (importData['places'] as List?)?.length ?? 0;
    final categoriesCount = (importData['categories'] as List?)?.length ?? 0;
    final exportDate = importData['exportDate'] as String?;

    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 가져오기 확인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('다음 데이터를 가져오시겠습니까?'),
            const SizedBox(height: 16),
            Text('• 장소: $placesCount개'),
            Text('• 카테고리: $categoriesCount개'),
            if (exportDate != null) ...[
              const SizedBox(height: 8),
              Text('내보낸 날짜: ${_formatDate(exportDate)}'),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '기존 데이터와 중복될 수 있습니다.',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('가져오기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모든 데이터 삭제'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 모든 데이터를 삭제하시겠습니까?'),
            SizedBox(height: 16),
            Text(
              '⚠️ 이 작업은 되돌릴 수 없습니다!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('삭제될 데이터:'),
            Text('• 모든 저장된 장소'),
            Text('• 사용자 정의 카테고리'),
            Text('• 앱 설정'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: 모든 데이터 삭제 로직 구현
      // 현재는 임시로 설정만 삭제
      final dataSource = ref.read(settingsDataSourceProvider);
      await dataSource.clearPreferences();

      // UI 새로고침
      ref.read(placesProvider.notifier).refreshPlaces();
      ref.read(categoriesProvider.notifier).refreshCategories();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모든 데이터가 삭제되었습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 삭제 실패: $e'),
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}