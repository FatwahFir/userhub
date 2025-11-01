String parseApiErrorMessage(
  dynamic data, {
  String fallback = 'Server error',
}) {
  if (data == null) {
    return fallback;
  }

  if (data is Map) {
    final map = Map<String, dynamic>.from(data as Map);

    final nestedError = map['error'];
    if (nestedError is Map) {
      final nestedMessage = nestedError['message'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        return nestedMessage.trim();
      }
    } else if (nestedError is String && nestedError.trim().isNotEmpty) {
      return nestedError.trim();
    }

    final directMessage = map['message'];
    if (directMessage is String && directMessage.trim().isNotEmpty) {
      return directMessage.trim();
    }

    final errors = map['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        final resolved = _extractFromValue(value);
        if (resolved != null) {
          return resolved;
        }
      }
    } else {
      final resolved = _extractFromValue(errors);
      if (resolved != null) {
        return resolved;
      }
    }

    final dataField = map['data'];
    final resolved = _extractFromValue(dataField);
    if (resolved != null) {
      return resolved;
    }
  }

  final resolved = _extractFromValue(data);
  if (resolved != null) {
    return resolved;
  }

  return fallback;
}

String? _extractFromValue(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  if (value is Iterable) {
    for (final item in value) {
      final resolved = _extractFromValue(item);
      if (resolved != null) return resolved;
    }
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value as Map);
    for (final entry in map.entries) {
      final resolved = _extractFromValue(entry.value);
      if (resolved != null) return resolved;
    }
  }
  return null;
}
