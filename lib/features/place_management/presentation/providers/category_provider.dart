import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/usecases/manage_categories.dart';
import 'package:locus_flutter/features/place_management/presentation/providers/place_provider.dart';

// UseCase providers for categories
final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetCategories(repository);
});

final getDefaultCategoriesUseCaseProvider = Provider<GetDefaultCategories>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetDefaultCategories(repository);
});

final getUserCategoriesUseCaseProvider = Provider<GetUserCategories>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetUserCategories(repository);
});

final getCategoryUseCaseProvider = Provider<GetCategory>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetCategory(repository);
});

final addCategoryUseCaseProvider = Provider<AddCategory>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return AddCategory(repository);
});

final updateCategoryUseCaseProvider = Provider<UpdateCategory>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return UpdateCategory(repository);
});

final deleteCategoryUseCaseProvider = Provider<DeleteCategory>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return DeleteCategory(repository);
});

final validateCategoryNameUseCaseProvider = Provider<ValidateCategoryName>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return ValidateCategoryName(repository);
});

final getCategoryUsageCountUseCaseProvider = Provider<GetCategoryUsageCount>((ref) {
  final repository = ref.read(placeRepositoryProvider);
  return GetCategoryUsageCount(repository);
});

// State management providers
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  final getCategoriesUseCase = ref.read(getCategoriesUseCaseProvider);
  return CategoriesNotifier(getCategoriesUseCase);
});

final defaultCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getDefaultCategoriesUseCase = ref.read(getDefaultCategoriesUseCaseProvider);
  return await getDefaultCategoriesUseCase();
});

final userCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getUserCategoriesUseCase = ref.read(getUserCategoriesUseCaseProvider);
  return await getUserCategoriesUseCase();
});

final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

// Category usage count provider
final categoryUsageCountProvider = FutureProvider.family<int, String>((ref, categoryId) async {
  final getCategoryUsageCountUseCase = ref.read(getCategoryUsageCountUseCaseProvider);
  return await getCategoryUsageCountUseCase(categoryId);
});

// Categories state notifier
class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final GetCategories _getCategories;

  CategoriesNotifier(this._getCategories) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _getCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshCategories() async {
    await loadCategories();
  }

  void addCategory(Category category) {
    state.whenData((categories) {
      state = AsyncValue.data([...categories, category]);
    });
  }

  void updateCategory(Category updatedCategory) {
    state.whenData((categories) {
      final updatedCategories = categories.map((category) {
        return category.id == updatedCategory.id ? updatedCategory : category;
      }).toList();
      state = AsyncValue.data(updatedCategories);
    });
  }

  void removeCategory(String categoryId) {
    state.whenData((categories) {
      final updatedCategories = categories.where((category) => category.id != categoryId).toList();
      state = AsyncValue.data(updatedCategories);
    });
  }

  List<Category> get categories {
    return state.maybeWhen(
      data: (categories) => categories,
      orElse: () => [],
    );
  }

  List<Category> get defaultCategories {
    return categories.where((category) => category.isDefault).toList();
  }

  List<Category> get userCategories {
    return categories.where((category) => !category.isDefault).toList();
  }

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  Category? getCategoryByName(String name) {
    try {
      return categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  int get categoriesCount {
    return categories.length;
  }

  int get defaultCategoriesCount {
    return defaultCategories.length;
  }

  int get userCategoriesCount {
    return userCategories.length;
  }

  bool get isLoading {
    return state.isLoading;
  }

  bool get hasError {
    return state.hasError;
  }

  String? get errorMessage {
    return state.maybeWhen(
      error: (error, _) => error.toString(),
      orElse: () => null,
    );
  }
}

// Category form provider for adding/editing categories
final categoryFormProvider = StateNotifierProvider<CategoryFormNotifier, CategoryFormState>((ref) {
  return CategoryFormNotifier();
});

class CategoryFormState {
  final String name;
  final String icon;
  final String color;
  final bool isValid;
  final String? nameError;
  final String? iconError;
  final String? colorError;

  const CategoryFormState({
    this.name = '',
    this.icon = '',
    this.color = '',
    this.isValid = false,
    this.nameError,
    this.iconError,
    this.colorError,
  });

  CategoryFormState copyWith({
    String? name,
    String? icon,
    String? color,
    bool? isValid,
    String? nameError,
    String? iconError,
    String? colorError,
  }) {
    return CategoryFormState(
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isValid: isValid ?? this.isValid,
      nameError: nameError ?? this.nameError,
      iconError: iconError ?? this.iconError,
      colorError: colorError ?? this.colorError,
    );
  }
}

class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  CategoryFormNotifier() : super(const CategoryFormState());

  void updateName(String name) {
    String? nameError;
    
    if (name.trim().isEmpty) {
      nameError = '카테고리 이름을 입력해주세요';
    } else if (name.trim().length < 2) {
      nameError = '카테고리 이름은 2글자 이상이어야 합니다';
    } else if (name.trim().length > 50) {
      nameError = '카테고리 이름은 50글자 이하여야 합니다';
    }

    state = state.copyWith(
      name: name,
      nameError: nameError,
      isValid: _validateForm(
        name: name,
        icon: state.icon,
        color: state.color,
        nameError: nameError,
        iconError: state.iconError,
        colorError: state.colorError,
      ),
    );
  }

  void updateIcon(String icon) {
    String? iconError;
    
    if (icon.trim().isEmpty) {
      iconError = '아이콘을 선택해주세요';
    }

    state = state.copyWith(
      icon: icon,
      iconError: iconError,
      isValid: _validateForm(
        name: state.name,
        icon: icon,
        color: state.color,
        nameError: state.nameError,
        iconError: iconError,
        colorError: state.colorError,
      ),
    );
  }

  void updateColor(String color) {
    String? colorError;
    
    if (color.trim().isEmpty) {
      colorError = '색상을 선택해주세요';
    }

    state = state.copyWith(
      color: color,
      colorError: colorError,
      isValid: _validateForm(
        name: state.name,
        icon: state.icon,
        color: color,
        nameError: state.nameError,
        iconError: state.iconError,
        colorError: colorError,
      ),
    );
  }

  bool _validateForm({
    required String name,
    required String icon,
    required String color,
    String? nameError,
    String? iconError,
    String? colorError,
  }) {
    return nameError == null &&
           iconError == null &&
           colorError == null &&
           name.trim().isNotEmpty &&
           icon.trim().isNotEmpty &&
           color.trim().isNotEmpty;
  }

  void reset() {
    state = const CategoryFormState();
  }

  void loadCategory(Category category) {
    state = CategoryFormState(
      name: category.name,
      icon: category.icon,
      color: category.color,
      isValid: true,
    );
  }

  Category createCategory() {
    if (!state.isValid) {
      throw StateError('Form is not valid');
    }

    return Category(
      id: '', // ID는 UseCase에서 생성됨
      name: state.name.trim(),
      icon: state.icon.trim(),
      color: state.color.trim(),
      isDefault: false,
      createdAt: DateTime.now(),
    );
  }

  Category updateCategory(Category existingCategory) {
    if (!state.isValid) {
      throw StateError('Form is not valid');
    }

    return existingCategory.copyWith(
      name: state.name.trim(),
      icon: state.icon.trim(),
      color: state.color.trim(),
    );
  }
}