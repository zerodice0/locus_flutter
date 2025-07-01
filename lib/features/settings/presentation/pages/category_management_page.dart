import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locus_flutter/core/theme/app_theme.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/category_provider.dart';
import 'package:locus_flutter/features/common/presentation/widgets/loading_widget.dart';
import 'package:locus_flutter/features/common/presentation/widgets/error_widget.dart';
import '../widgets/add_category_dialog.dart';
import '../widgets/edit_category_dialog.dart';

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage> {
  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 카테고리 목록 새로고침
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).refreshCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카테고리 관리'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(categoriesProvider.notifier).refreshCategories(),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (error, stackTrace) => Center(
          child: CustomErrorWidget(
            title: '카테고리 로드 실패',
            message: error.toString(),
            onRetry: () => ref.read(categoriesProvider.notifier).refreshCategories(),
          ),
        ),
        data: (categories) => _buildCategoryList(context, categories),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCategoryDialog(context),
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add),
        label: const Text('카테고리 추가'),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List<Category> categories) {
    final defaultCategories = categories.where((c) => c.isDefault).toList();
    final userCategories = categories.where((c) => !c.isDefault).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(categoriesProvider.notifier).refreshCategories(),
      child: CustomScrollView(
        slivers: [
          // 기본 카테고리 섹션
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              '기본 카테고리',
              '시스템에서 제공하는 기본 카테고리입니다',
              defaultCategories.length,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCategoryTile(context, defaultCategories[index]),
              childCount: defaultCategories.length,
            ),
          ),

          // 구분선
          const SliverToBoxAdapter(child: Divider(height: 32, thickness: 1)),

          // 사용자 카테고리 섹션
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              '사용자 카테고리',
              '직접 추가한 카테고리입니다',
              userCategories.length,
            ),
          ),
          if (userCategories.isEmpty)
            SliverToBoxAdapter(
              child: _buildEmptyUserCategories(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCategoryTile(context, userCategories[index]),
                childCount: userCategories.length,
              ),
            ),

          // 하단 여백
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count개',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(BuildContext context, Category category) {
    return Consumer(
      builder: (context, ref, child) {
        final usageCountAsync = ref.watch(categoryUsageCountProvider(category.id));
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _parseColor(category.color),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _parseIcon(category.icon),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: usageCountAsync.when(
              loading: () => const Text('사용 횟수 확인 중...'),
              error: (_, __) => const Text('사용 횟수 확인 실패'),
              data: (count) => Text('$count개 장소에서 사용됨'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (category.isDefault) 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '기본',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )
                else
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditCategoryDialog(context, category),
                        tooltip: '편집',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                        onPressed: () => _showDeleteConfirmDialog(context, category),
                        tooltip: '삭제',
                      ),
                    ],
                  ),
              ],
            ),
            onTap: () => _showCategoryDetails(context, category),
          ),
        );
      },
    );
  }

  Widget _buildEmptyUserCategories() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '사용자 카테고리가 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 + 버튼을 눌러 새로운 카테고리를 추가해보세요!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => EditCategoryDialog(category: category),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Category category) async {
    final usageCount = await ref.read(categoryUsageCountProvider(category.id).future);
    
    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('정말로 "${category.name}" 카테고리를 삭제하시겠습니까?'),
            const SizedBox(height: 16),
            if (usageCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '이 카테고리는 현재 $usageCount개의 장소에서 사용되고 있습니다.',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '카테고리를 삭제하면 해당 장소들은 기본 카테고리로 변경됩니다.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteCategory(category);
    }
  }

  void _showCategoryDetails(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _parseColor(category.color),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _parseIcon(category.icon),
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Text(category.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('타입', category.isDefault ? '기본 카테고리' : '사용자 카테고리'),
            _buildDetailRow('생성일', '${category.createdAt.year}.${category.createdAt.month.toString().padLeft(2, '0')}.${category.createdAt.day.toString().padLeft(2, '0')}'),
            _buildDetailRow('아이콘', category.icon),
            _buildDetailRow('색상', category.color),
            Consumer(
              builder: (context, ref, child) {
                final usageCountAsync = ref.watch(categoryUsageCountProvider(category.id));
                return usageCountAsync.when(
                  loading: () => _buildDetailRow('사용 횟수', '확인 중...'),
                  error: (_, __) => _buildDetailRow('사용 횟수', '확인 실패'),
                  data: (count) => _buildDetailRow('사용 횟수', '$count개 장소'),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          if (!category.isDefault)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditCategoryDialog(context, category);
              },
              child: const Text('편집'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    try {
      final deleteCategoryUseCase = ref.read(deleteCategoryUseCaseProvider);
      await deleteCategoryUseCase(category.id);
      
      // UI에서 카테고리 제거
      ref.read(categoriesProvider.notifier).removeCategory(category.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.name} 카테고리가 삭제되었습니다'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카테고리 삭제 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _parseColor(String colorString) {
    // 색상 문자열을 Color 객체로 변환
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
      } else if (colorString.startsWith('0x')) {
        return Color(int.parse(colorString));
      } else {
        // 기본 색상들
        switch (colorString.toLowerCase()) {
          case 'red': return Colors.red;
          case 'blue': return Colors.blue;
          case 'green': return Colors.green;
          case 'orange': return Colors.orange;
          case 'purple': return Colors.purple;
          case 'teal': return Colors.teal;
          case 'pink': return Colors.pink;
          case 'indigo': return Colors.indigo;
          default: return AppTheme.primaryBlue;
        }
      }
    } catch (e) {
      return AppTheme.primaryBlue;
    }
  }

  IconData _parseIcon(String iconString) {
    // 아이콘 문자열을 IconData로 변환
    switch (iconString.toLowerCase()) {
      case 'restaurant': return Icons.restaurant;
      case 'local_cafe': return Icons.local_cafe;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'movie': return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'home': return Icons.home;
      case 'work': return Icons.work;
      case 'local_gas_station': return Icons.local_gas_station;
      case 'fitness_center': return Icons.fitness_center;
      case 'hotel': return Icons.hotel;
      case 'local_library': return Icons.local_library;
      default: return Icons.category;
    }
  }
}