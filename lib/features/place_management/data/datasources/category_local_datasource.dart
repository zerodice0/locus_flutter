import 'package:uuid/uuid.dart';
import 'package:locus_flutter/core/database/database_helper.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';
import 'package:locus_flutter/features/place_management/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<String> insertCategory(CategoryModel category);
  Future<CategoryModel?> getCategory(String id);
  Future<List<CategoryModel>> getAllCategories();
  Future<List<CategoryModel>> getDefaultCategories();
  Future<List<CategoryModel>> getUserCategories();
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<bool> isCategoryNameExists(String name, {String? excludeId});
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid;

  CategoryLocalDataSourceImpl({
    required DatabaseHelper databaseHelper,
    Uuid? uuid,
  }) : _databaseHelper = databaseHelper,
       _uuid = uuid ?? const Uuid();

  @override
  Future<String> insertCategory(CategoryModel category) async {
    final categoryData = category.toDatabase();
    await _databaseHelper.insert(DatabaseConstants.tableCategories, categoryData);
    return category.id;
  }

  @override
  Future<CategoryModel?> getCategory(String id) async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return CategoryModel.fromDatabase(results.first);
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableCategories,
      orderBy: '${DatabaseConstants.categoryIsDefault} DESC, ${DatabaseConstants.categoryName} ASC',
    );

    return results.map((row) => CategoryModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<CategoryModel>> getDefaultCategories() async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.categoryIsDefault} = ?',
      whereArgs: [1],
      orderBy: '${DatabaseConstants.categoryName} ASC',
    );

    return results.map((row) => CategoryModel.fromDatabase(row)).toList();
  }

  @override
  Future<List<CategoryModel>> getUserCategories() async {
    final results = await _databaseHelper.query(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.categoryIsDefault} = ?',
      whereArgs: [0],
      orderBy: '${DatabaseConstants.categoryCreatedAt} DESC',
    );

    return results.map((row) => CategoryModel.fromDatabase(row)).toList();
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    final categoryData = category.toDatabase();
    await _databaseHelper.update(
      DatabaseConstants.tableCategories,
      categoryData,
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [category.id],
    );
  }

  @override
  Future<void> deleteCategory(String id) async {
    // First check if category is being used by any places
    final placesUsingCategory = await _databaseHelper.query(
      DatabaseConstants.tablePlaces,
      where: '${DatabaseConstants.placeCategoryId} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (placesUsingCategory.isNotEmpty) {
      throw Exception('Cannot delete category: it is being used by existing places');
    }

    await _databaseHelper.delete(
      DatabaseConstants.tableCategories,
      where: '${DatabaseConstants.categoryId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> isCategoryNameExists(String name, {String? excludeId}) async {
    String whereClause = '${DatabaseConstants.categoryName} = ?';
    List<dynamic> whereArgs = [name];

    if (excludeId != null) {
      whereClause += ' AND ${DatabaseConstants.categoryId} != ?';
      whereArgs.add(excludeId);
    }

    final results = await _databaseHelper.query(
      DatabaseConstants.tableCategories,
      where: whereClause,
      whereArgs: whereArgs,
      limit: 1,
    );

    return results.isNotEmpty;
  }

  // Helper method to create a new category ID
  String generateCategoryId() => 'cat_${_uuid.v4()}';
}