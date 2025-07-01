import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required String icon,
    required String color,
    required bool isDefault,
    required DateTime createdAt,
  }) = _Category;

  const Category._();

  // Helper methods
  bool get isUserCreated => !isDefault;
}