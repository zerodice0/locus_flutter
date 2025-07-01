import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/category.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    required String icon,
    required String color,
    required bool isDefault,
    required DateTime createdAt,
  }) = _CategoryModel;

  const CategoryModel._();

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  factory CategoryModel.fromDatabase(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseConstants.categoryId] as String,
      name: map[DatabaseConstants.categoryName] as String,
      icon: map[DatabaseConstants.categoryIcon] as String,
      color: map[DatabaseConstants.categoryColor] as String,
      isDefault: (map[DatabaseConstants.categoryIsDefault] as int) == 1,
      createdAt: DateTime.parse(map[DatabaseConstants.categoryCreatedAt] as String),
    );
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      color: entity.color,
      isDefault: entity.isDefault,
      createdAt: entity.createdAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      color: color,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      DatabaseConstants.categoryId: id,
      DatabaseConstants.categoryName: name,
      DatabaseConstants.categoryIcon: icon,
      DatabaseConstants.categoryColor: color,
      DatabaseConstants.categoryIsDefault: isDefault ? 1 : 0,
      DatabaseConstants.categoryCreatedAt: createdAt.toIso8601String(),
    };
  }
}