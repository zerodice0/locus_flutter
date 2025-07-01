// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message';
}

// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.code});
}

// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

// Location related exceptions
class LocationException extends AppException {
  const LocationException(super.message, {super.code});
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

// Place specific exceptions
class PlaceNotFoundException extends AppException {
  const PlaceNotFoundException(super.message, {super.code});
}

class DuplicatePlaceException extends AppException {
  final List<dynamic> duplicatePlaces;
  
  const DuplicatePlaceException(
    super.message, 
    this.duplicatePlaces, 
    {super.code}
  );
}

class CategoryNotFoundException extends AppException {
  const CategoryNotFoundException(super.message, {super.code});
}

class CategoryInUseException extends AppException {
  const CategoryInUseException(super.message, {super.code});
}

// Map related exceptions
class MapException extends AppException {
  const MapException(super.message, {super.code});
}

class GeocodingException extends AppException {
  const GeocodingException(super.message, {super.code});
}