import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/core/constants/database_constants.dart';

part 'event_period_model.freezed.dart';
part 'event_period_model.g.dart';

@freezed
class EventPeriodModel with _$EventPeriodModel {
  const factory EventPeriodModel({
    required String id,
    required String placeId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
  }) = _EventPeriodModel;

  const EventPeriodModel._();

  factory EventPeriodModel.fromJson(Map<String, dynamic> json) =>
      _$EventPeriodModelFromJson(json);

  factory EventPeriodModel.fromDatabase(Map<String, dynamic> map) {
    return EventPeriodModel(
      id: map[DatabaseConstants.eventPeriodId] as String,
      placeId: map[DatabaseConstants.eventPeriodPlaceId] as String,
      name: map[DatabaseConstants.eventPeriodName] as String,
      startDate: DateTime.parse(map[DatabaseConstants.eventPeriodStartDate] as String),
      endDate: DateTime.parse(map[DatabaseConstants.eventPeriodEndDate] as String),
      description: map[DatabaseConstants.eventPeriodDescription] as String?,
    );
  }

  factory EventPeriodModel.fromEntity(EventPeriod entity) {
    return EventPeriodModel(
      id: entity.id,
      placeId: entity.placeId,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
      description: entity.description,
    );
  }

  EventPeriod toEntity() {
    return EventPeriod(
      id: id,
      placeId: placeId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      description: description,
    );
  }

  Map<String, dynamic> toDatabase() {
    return {
      DatabaseConstants.eventPeriodId: id,
      DatabaseConstants.eventPeriodPlaceId: placeId,
      DatabaseConstants.eventPeriodName: name,
      DatabaseConstants.eventPeriodStartDate: startDate.toIso8601String(),
      DatabaseConstants.eventPeriodEndDate: endDate.toIso8601String(),
      DatabaseConstants.eventPeriodDescription: description,
    };
  }
}