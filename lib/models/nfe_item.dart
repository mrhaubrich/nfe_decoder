import 'dart:collection';
import 'dart:convert';

import 'package:nfe_decoder/models/item.dart';
import 'package:nfe_decoder/models/identifier_observation.dart';

class NfeItem {
  final Item item;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  /// Identifier observations captured without resolving product identity.
  final List<IdentifierObservation> identifiers;

  /// Malformed identifier payloads retained as inert JSON evidence.
  ///
  /// Values remain quarantined and are never interpreted as observations.
  final List<Object?> rawIdentifiers;

  /// Version of the additive identifier observation contract, when present.
  final int? identifierContractVersion;

  /// Source item number when the source explicitly provides one.
  final int? sourceItemNumber;

  /// Captured source order and its basis, independent of source item number.
  final int? sourceOrdinal;

  /// Parser/layout metadata without fiscal URLs or raw fiscal payloads.
  final Map<String, dynamic> sourceMetadata;

  NfeItem({
    required this.item,
    required this.quantidade,
    required this.valorUnitario,
    required this.valorTotal,
    List<IdentifierObservation> identifiers = const [],
    List<Object?> rawIdentifiers = const [],
    this.identifierContractVersion,
    this.sourceItemNumber,
    this.sourceOrdinal,
    Map<String, dynamic> sourceMetadata = const {},
  }) : sourceMetadata = _freezeMap(sourceMetadata),
       identifiers = List.unmodifiable(identifiers),
       rawIdentifiers = _freezeRawIdentifiers(rawIdentifiers);

  factory NfeItem.fromMap(Map<String, dynamic> map) {
    final rawIdentifiers = _RawIdentifiersBuilder();
    final identifiers = _parseIdentifierPayload(
      map['identifiers'],
      rawIdentifiers,
    );
    rawIdentifiers.addAll(_parseRawIdentifiers(map));

    return NfeItem(
      item: Item.fromMap(map['item']),
      quantidade: map['quantidade'],
      valorUnitario: map['valorUnitario'],
      valorTotal: map['valorTotal'],
      identifiers: identifiers,
      rawIdentifiers: rawIdentifiers.toList(),
      identifierContractVersion: map['identifierContractVersion'] is int
          ? map['identifierContractVersion'] as int
          : null,
      sourceItemNumber: map['sourceItemNumber'] is int
          ? map['sourceItemNumber'] as int
          : null,
      sourceOrdinal: map['sourceOrdinal'] is int
          ? map['sourceOrdinal'] as int
          : null,
      sourceMetadata: _parseMetadata(map['sourceMetadata']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
      if (identifiers.isNotEmpty)
        'identifiers': identifiers.map((value) => value.toMap()).toList(),
      if (rawIdentifiers.isNotEmpty) 'rawIdentifiers': rawIdentifiers,
      if (identifierContractVersion != null)
        'identifierContractVersion': identifierContractVersion,
      if (sourceItemNumber != null) 'sourceItemNumber': sourceItemNumber,
      if (sourceOrdinal != null) 'sourceOrdinal': sourceOrdinal,
      if (sourceMetadata.isNotEmpty) 'sourceMetadata': sourceMetadata,
    };
  }
}

List<IdentifierObservation> _parseIdentifierPayload(
  Object? value,
  _RawIdentifiersBuilder rawIdentifiers,
) {
  if (value is! List) return const [];

  final valid = <IdentifierObservation>[];
  for (final entry in value) {
    if (!_hasRequiredObservationFields(entry)) {
      rawIdentifiers.add(entry);
      continue;
    }

    final observation = IdentifierObservation.tryParse(entry);
    if (observation == null) {
      rawIdentifiers.add(entry);
    } else {
      valid.add(observation);
    }
  }
  return List.unmodifiable(valid);
}

bool _hasRequiredObservationFields(Object? value) {
  if (value is! Map) return false;
  return value['rawValue'] is String && value['sourceField'] is String;
}

List<Object?> _parseRawIdentifiers(Map<String, dynamic> map) {
  if (!map.containsKey('rawIdentifiers')) return const [];
  final value = map['rawIdentifiers'];
  if (value is! List) {
    throw const FormatException('rawIdentifiers must be a JSON list.');
  }
  return value.cast<Object?>();
}

List<Object?> _freezeRawIdentifiers(List<Object?> values) {
  final builder = _RawIdentifiersBuilder()..addAll(values);
  return builder.toList();
}

class _RawIdentifiersBuilder {
  final Set<Object> _activeContainers = HashSet<Object>.identity();
  final List<Object?> _values = [];
  var _encodedBytes = 2; // Enclosing JSON array brackets.

  void add(Object? value) {
    if (_values.isNotEmpty) _encodedBytes++;
    _checkRawIdentifiersSize(_encodedBytes);
    final result = _freezeJsonValue(value, _activeContainers, 1);
    _encodedBytes += result.encodedBytes;
    _checkRawIdentifiersSize(_encodedBytes);
    _values.add(result.value);
  }

  void addAll(Iterable<Object?> values) {
    for (final value in values) {
      add(value);
    }
  }

  List<Object?> toList() => List<Object?>.unmodifiable(_values);
}

({Object? value, int encodedBytes}) _freezeJsonValue(
  Object? value,
  Set<Object> activeContainers,
  int depth,
) {
  if (value == null || value is bool || value is int) {
    return (value: value, encodedBytes: utf8.encode(jsonEncode(value)).length);
  }
  if (value is String) {
    return (value: value, encodedBytes: _encodedJsonStringBytes(value));
  }
  if (value is double && value.isFinite) {
    return (value: value, encodedBytes: utf8.encode(jsonEncode(value)).length);
  }
  if (value is List) {
    _enterJsonContainer(value, activeContainers, depth);
    try {
      final frozen = <Object?>[];
      var encodedBytes = 2; // List brackets.
      for (final item in value) {
        if (frozen.isNotEmpty) encodedBytes++;
        _checkRawIdentifiersSize(encodedBytes);
        final result = _freezeJsonValue(item, activeContainers, depth + 1);
        encodedBytes += result.encodedBytes;
        _checkRawIdentifiersSize(encodedBytes);
        frozen.add(result.value);
      }
      return (
        value: List<Object?>.unmodifiable(frozen),
        encodedBytes: encodedBytes,
      );
    } finally {
      activeContainers.remove(value);
    }
  }
  if (value is Map) {
    _enterJsonContainer(value, activeContainers, depth);
    try {
      final frozen = <String, Object?>{};
      var encodedBytes = 2; // Map braces.
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw const FormatException(
            'Non-string keys are not valid in rawIdentifiers.',
          );
        }
        if (frozen.isNotEmpty) encodedBytes++;
        final key = entry.key as String;
        encodedBytes += _encodedJsonStringBytes(key) + 1; // Key and colon.
        _checkRawIdentifiersSize(encodedBytes);
        final result = _freezeJsonValue(
          entry.value,
          activeContainers,
          depth + 1,
        );
        encodedBytes += result.encodedBytes;
        _checkRawIdentifiersSize(encodedBytes);
        frozen[key] = result.value;
      }
      return (
        value: Map<String, Object?>.unmodifiable(frozen),
        encodedBytes: encodedBytes,
      );
    } finally {
      activeContainers.remove(value);
    }
  }
  throw const FormatException('Non-JSON value in rawIdentifiers.');
}

int _encodedJsonStringBytes(String value) {
  if (value.length > _maxRawIdentifiersJsonBytes) {
    throw const FormatException(
      'rawIdentifiers exceeds the 64 KiB per-item JSON limit.',
    );
  }
  return utf8.encode(jsonEncode(value)).length;
}

void _checkRawIdentifiersSize(int encodedBytes) {
  if (encodedBytes > _maxRawIdentifiersJsonBytes) {
    throw const FormatException(
      'rawIdentifiers exceeds the 64 KiB per-item JSON limit.',
    );
  }
}

void _enterJsonContainer(
  Object value,
  Set<Object> activeContainers,
  int depth,
) {
  if (depth > _maxRawIdentifierDepth) {
    throw const FormatException('rawIdentifiers exceeds the JSON depth limit.');
  }
  if (!activeContainers.add(value)) {
    throw const FormatException('Cyclic values are not valid JSON.');
  }
}

const _maxRawIdentifiersJsonBytes = 64 * 1024;
const _maxRawIdentifierDepth = 128;

Map<String, dynamic> _parseMetadata(Object? value) {
  if (value is! Map) return const {};
  return Map<String, dynamic>.fromEntries(
    value.entries
        .where((entry) => entry.key is String)
        .map((entry) => MapEntry(entry.key as String, entry.value)),
  );
}

Map<String, dynamic> _freezeMap(Map<String, dynamic> value) {
  return Map.unmodifiable(
    value.map((key, item) => MapEntry(key, _freezeValue(item))),
  );
}

Object? _freezeValue(Object? value) {
  if (value is Map) {
    return Map.unmodifiable(
      value.map((key, item) => MapEntry(key.toString(), _freezeValue(item))),
    );
  }
  if (value is List) return List.unmodifiable(value.map(_freezeValue));
  return value;
}
