abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  String toString() => 'Failure: $message';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && 
           other.message == message && 
           other.code == code;
  }
  
  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

// Network related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

// Location related failures
class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code});
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

// Validation related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

// Place specific failures
class PlaceNotFoundFailure extends Failure {
  const PlaceNotFoundFailure(super.message, {super.code});
}

class DuplicatePlaceFailure extends Failure {
  final List<dynamic> duplicatePlaces;
  
  const DuplicatePlaceFailure(
    super.message, 
    this.duplicatePlaces, 
    {super.code}
  );
}

class CategoryNotFoundFailure extends Failure {
  const CategoryNotFoundFailure(super.message, {super.code});
}

class CategoryInUseFailure extends Failure {
  const CategoryInUseFailure(super.message, {super.code});
}

// Generic failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}