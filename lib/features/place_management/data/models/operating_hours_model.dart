import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';

part 'operating_hours_model.freezed.dart';
part 'operating_hours_model.g.dart';

@freezed
class OperatingHoursModel with _$OperatingHoursModel {
  const factory OperatingHoursModel({
    required String id,
    required String placeId,
    required int dayOfWeek,
    String? openTime,
    String? closeTime,
    required bool isClosed,
  }) = _OperatingHoursModel;

  const OperatingHoursModel._();

  factory OperatingHoursModel.fromJson(Map<String, dynamic> json) =>
      _$OperatingHoursModelFromJson(json);

  factory OperatingHoursModel.fromDatabase(Map<String, dynamic> map) {
    return OperatingHoursModel(
      id: map[DatabaseConstants.operatingHoursId] as String,
      placeId: map[DatabaseConstants.operatingHoursPlaceId] as String,
      dayOfWeek: map[DatabaseConstants.operatingHoursDayOfWeek] as int,
      openTime: map[DatabaseConstants.operatingHoursOpenTime] as String?,
      closeTime: map[DatabaseConstants.operatingHoursCloseTime] as String?,
      isClosed: (map[DatabaseConstants.operatingHoursIsClosed] as int) == 1,
    );
  }

  factory OperatingHoursModel.fromEntity(OperatingHours entity) {
    return OperatingHoursModel(
      id: entity.id,
      placeId: entity.placeId,
      dayOfWeek: entity.dayOfWeek,
      openTime: entity.openTime,
      closeTime: entity.closeTime,
      isClosed: entity.isClosed,
    );
  }

  OperatingHours toEntity() {
    return OperatingHours(
      id: id,
      placeId: placeId,
      dayOfWeek: dayOfWeek,
      openTime: openTime,
      closeTime: closeTime,
      isClosed: isClosed,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      DatabaseConstants.operatingHoursId: id,
      DatabaseConstants.operatingHoursPlaceId: placeId,
      DatabaseConstants.operatingHoursDayOfWeek: dayOfWeek,
      DatabaseConstants.operatingHoursOpenTime: openTime,
      DatabaseConstants.operatingHoursCloseTime: closeTime,
      DatabaseConstants.operatingHoursIsClosed: isClosed ? 1 : 0,
    };
  }
}