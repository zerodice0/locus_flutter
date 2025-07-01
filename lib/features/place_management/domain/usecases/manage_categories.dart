import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/features/place_management/domain/repositories/place_repository.dart';

class GetCategories {
  final PlaceRepository _repository;

  GetCategories(this._repository);

  Future<List<Category>> call() async {
    return await _repository.getAllCategories();
  }
}

class GetDefaultCategories {
  final PlaceRepository _repository;

  GetDefaultCategories(this._repository);

  Future<List<Category>> call() async {
    return await _repository.getDefaultCategories();
  }
}

class GetUserCategories {
  final PlaceRepository _repository;

  GetUserCategories(this._repository);

  Future<List<Category>> call() async {
    return await _repository.getUserCategories();
  }
}

class GetCategory {
  final PlaceRepository _repository;

  GetCategory(this._repository);

  Future<Category?> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    
    return await _repository.getCategory(categoryId);
  }
}

class AddCategory {
  final PlaceRepository _repository;

  AddCategory(this._repository);

  Future<String> call(Category category) async {
    // Validate category data
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }
    
    if (category.icon.trim().isEmpty) {
      throw ArgumentError('Category icon cannot be empty');
    }
    
    if (category.color.trim().isEmpty) {
      throw ArgumentError('Category color cannot be empty');
    }
    
    // Check if category name already exists
    final nameExists = await _repository.isCategoryNameExists(category.name.trim());
    if (nameExists) {
      throw CategoryNameExistsException('Category with name "${category.name}" already exists');
    }
    
    // Create category with timestamps
    final now = DateTime.now();
    final categoryToAdd = category.copyWith(
      createdAt: now,
      isDefault: false, // User categories are never default
    );
    
    return await _repository.addCategory(categoryToAdd);
  }
}

class UpdateCategory {
  final PlaceRepository _repository;

  UpdateCategory(this._repository);

  Future<void> call(Category category) async {
    // Validate category data
    if (category.id.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    
    if (category.name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }
    
    if (category.icon.trim().isEmpty) {
      throw ArgumentError('Category icon cannot be empty');
    }
    
    if (category.color.trim().isEmpty) {
      throw ArgumentError('Category color cannot be empty');
    }
    
    // Check if category exists
    final existingCategory = await _repository.getCategory(category.id);
    if (existingCategory == null) {
      throw CategoryNotFoundException('Category with ID ${category.id} not found');
    }
    
    // Prevent updating default categories (only allow user categories to be updated)
    if (existingCategory.isDefault) {
      throw DefaultCategoryUpdateException('Default categories cannot be modified');
    }
    
    // Check if new name conflicts with existing categories (excluding current category)
    final nameExists = await _repository.isCategoryNameExists(
      category.name.trim(), 
      excludeId: category.id,
    );
    if (nameExists) {
      throw CategoryNameExistsException('Category with name "${category.name}" already exists');
    }
    
    await _repository.updateCategory(category);
  }
}

class DeleteCategory {
  final PlaceRepository _repository;

  DeleteCategory(this._repository);

  Future<void> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    
    // Check if category exists
    final category = await _repository.getCategory(categoryId);
    if (category == null) {
      throw CategoryNotFoundException('Category with ID $categoryId not found');
    }
    
    // Prevent deleting default categories
    if (category.isDefault) {
      throw DefaultCategoryDeleteException('Default categories cannot be deleted');
    }
    
    // Check if category is being used by any places
    final placesWithCategory = await _repository.getPlacesByCategory(categoryId);
    if (placesWithCategory.isNotEmpty) {
      throw CategoryInUseException(
        'Category "${category.name}" is being used by ${placesWithCategory.length} place(s) and cannot be deleted',
      );
    }
    
    await _repository.deleteCategory(categoryId);
  }
}

class ValidateCategoryName {
  final PlaceRepository _repository;

  ValidateCategoryName(this._repository);

  Future<bool> call(String name, {String? excludeId}) async {
    if (name.trim().isEmpty) {
      return false;
    }
    
    if (name.trim().length < 2) {
      return false;
    }
    
    if (name.trim().length > 50) {
      return false;
    }
    
    // Check if name already exists
    final nameExists = await _repository.isCategoryNameExists(name.trim(), excludeId: excludeId);
    return !nameExists;
  }
}

class GetCategoryUsageCount {
  final PlaceRepository _repository;

  GetCategoryUsageCount(this._repository);

  Future<int> call(String categoryId) async {
    if (categoryId.trim().isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
    
    final places = await _repository.getPlacesByCategory(categoryId);
    return places.length;
  }
}

// Category specific exceptions
class CategoryNotFoundException implements Exception {
  final String message;
  
  CategoryNotFoundException(this.message);
  
  @override
  String toString() => 'CategoryNotFoundException: $message';
}

class CategoryNameExistsException implements Exception {
  final String message;
  
  CategoryNameExistsException(this.message);
  
  @override
  String toString() => 'CategoryNameExistsException: $message';
}

class CategoryInUseException implements Exception {
  final String message;
  
  CategoryInUseException(this.message);
  
  @override
  String toString() => 'CategoryInUseException: $message';
}

class DefaultCategoryUpdateException implements Exception {
  final String message;
  
  DefaultCategoryUpdateException(this.message);
  
  @override
  String toString() => 'DefaultCategoryUpdateException: $message';
}

class DefaultCategoryDeleteException implements Exception {
  final String message;
  
  DefaultCategoryDeleteException(this.message);
  
  @override
  String toString() => 'DefaultCategoryDeleteException: $message';
}