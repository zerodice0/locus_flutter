import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locus_flutter/features/place_management/domain/entities/place.dart';
import 'package:locus_flutter/features/place_management/domain/entities/operating_hours.dart';
import 'package:locus_flutter/features/place_management/domain/entities/event_period.dart';
import 'package:locus_flutter/core/services/map/map_service.dart';

// Place form provider for adding/editing places
final placeFormProvider =
    StateNotifierProvider<PlaceFormNotifier, PlaceFormState>((ref) {
      return PlaceFormNotifier();
    });

class PlaceFormState {
  final String name;
  final String description;
  final UniversalLatLng? location;
  final String address;
  final String categoryId;
  final String notes;
  final double? rating;
  final List<OperatingHours> operatingHours;
  final List<EventPeriod> eventPeriods;
  final bool isValid;
  final Map<String, String> errors;

  const PlaceFormState({
    this.name = '',
    this.description = '',
    this.location,
    this.address = '',
    this.categoryId = '',
    this.notes = '',
    this.rating,
    this.operatingHours = const [],
    this.eventPeriods = const [],
    this.isValid = false,
    this.errors = const {},
  });

  PlaceFormState copyWith({
    String? name,
    String? description,
    UniversalLatLng? location,
    String? address,
    String? categoryId,
    String? notes,
    double? rating,
    List<OperatingHours>? operatingHours,
    List<EventPeriod>? eventPeriods,
    bool? isValid,
    Map<String, String>? errors,
  }) {
    return PlaceFormState(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      categoryId: categoryId ?? this.categoryId,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      operatingHours: operatingHours ?? this.operatingHours,
      eventPeriods: eventPeriods ?? this.eventPeriods,
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
    );
  }
}

class PlaceFormNotifier extends StateNotifier<PlaceFormState> {
  PlaceFormNotifier() : super(const PlaceFormState());

  void updateName(String name) {
    final errors = Map<String, String>.from(state.errors);

    if (name.trim().isEmpty) {
      errors['name'] = '장소 이름을 입력해주세요';
    } else if (name.trim().length < 2) {
      errors['name'] = '장소 이름은 2글자 이상이어야 합니다';
    } else if (name.trim().length > 100) {
      errors['name'] = '장소 이름은 100글자 이하여야 합니다';
    } else {
      errors.remove('name');
    }

    state = state.copyWith(
      name: name,
      errors: errors,
      isValid: _validateForm(errors),
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateLocation(UniversalLatLng location) {
    final errors = Map<String, String>.from(state.errors);
    errors.remove('location');

    state = state.copyWith(
      location: location,
      errors: errors,
      isValid: _validateForm(errors),
    );
  }

  void updateAddress(String address) {
    state = state.copyWith(address: address);
  }

  void updateCategoryId(String categoryId) {
    final errors = Map<String, String>.from(state.errors);

    if (categoryId.trim().isEmpty) {
      errors['categoryId'] = '카테고리를 선택해주세요';
    } else {
      errors.remove('categoryId');
    }

    state = state.copyWith(
      categoryId: categoryId,
      errors: errors,
      isValid: _validateForm(errors),
    );
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void updateRating(double? rating) {
    state = state.copyWith(rating: rating);
  }

  void updateOperatingHours(List<OperatingHours> operatingHours) {
    state = state.copyWith(operatingHours: operatingHours);
  }

  void updateEventPeriods(List<EventPeriod> eventPeriods) {
    state = state.copyWith(eventPeriods: eventPeriods);
  }

  bool _validateForm(Map<String, String> errors) {
    return errors.isEmpty &&
        state.name.trim().isNotEmpty &&
        state.location != null &&
        state.categoryId.trim().isNotEmpty;
  }

  void reset() {
    state = const PlaceFormState();
  }

  void loadPlace(Place place) {
    state = PlaceFormState(
      name: place.name,
      description: place.description ?? '',
      location: UniversalLatLng(place.latitude, place.longitude),
      address: place.address ?? '',
      categoryId: place.categoryId,
      notes: place.notes ?? '',
      rating: place.rating,
      operatingHours: place.operatingHours ?? [],
      eventPeriods: place.eventPeriods ?? [],
      isValid: true,
    );
  }

  Place createPlace() {
    if (!state.isValid || state.location == null) {
      throw StateError('Form is not valid');
    }

    final now = DateTime.now();
    return Place(
      id: '', // ID는 UseCase에서 생성됨
      name: state.name.trim(),
      description:
          state.description.trim().isEmpty ? null : state.description.trim(),
      latitude: state.location!.latitude,
      longitude: state.location!.longitude,
      address: state.address.trim().isEmpty ? null : state.address.trim(),
      categoryId: state.categoryId,
      createdAt: now,
      updatedAt: now,
      isActive: true,
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      rating: state.rating,
      visitCount: 0,
      operatingHours:
          state.operatingHours.isEmpty ? null : state.operatingHours,
      eventPeriods: state.eventPeriods.isEmpty ? null : state.eventPeriods,
    );
  }

  Place updatePlace(Place existingPlace) {
    if (!state.isValid || state.location == null) {
      throw StateError('Form is not valid');
    }

    return existingPlace.copyWith(
      name: state.name.trim(),
      description:
          state.description.trim().isEmpty ? null : state.description.trim(),
      latitude: state.location!.latitude,
      longitude: state.location!.longitude,
      address: state.address.trim().isEmpty ? null : state.address.trim(),
      categoryId: state.categoryId,
      updatedAt: DateTime.now(),
      notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
      rating: state.rating,
      operatingHours:
          state.operatingHours.isEmpty ? null : state.operatingHours,
      eventPeriods: state.eventPeriods.isEmpty ? null : state.eventPeriods,
    );
  }

  String? getError(String field) {
    return state.errors[field];
  }

  bool hasError(String field) {
    return state.errors.containsKey(field);
  }
}
