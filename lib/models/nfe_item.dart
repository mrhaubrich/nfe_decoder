import 'package:nfe_decoder/models/item.dart';
import 'package:nfe_decoder/models/identifier_observation.dart';

class NfeItem {
  final Item item;
  final double quantidade;
  final double valorUnitario;
  final double valorTotal;

  /// Identifier observations captured without resolving product identity.
  final List<IdentifierObservation> identifiers;

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
    this.identifierContractVersion,
    this.sourceItemNumber,
    this.sourceOrdinal,
    Map<String, dynamic> sourceMetadata = const {},
  }) : sourceMetadata = _freezeMap(sourceMetadata),
       identifiers = List.unmodifiable(identifiers);

  NfeItem.fromMap(Map<String, dynamic> map)
    : item = Item.fromMap(map['item']),
      quantidade = map['quantidade'],
      valorUnitario = map['valorUnitario'],
      valorTotal = map['valorTotal'],
      identifiers = _parseIdentifiers(map['identifiers']),
      identifierContractVersion = map['identifierContractVersion'] is int
          ? map['identifierContractVersion'] as int
          : null,
      sourceItemNumber = map['sourceItemNumber'] is int
          ? map['sourceItemNumber'] as int
          : null,
      sourceOrdinal = map['sourceOrdinal'] is int
          ? map['sourceOrdinal'] as int
          : null,
      sourceMetadata = _freezeMap(_parseMetadata(map['sourceMetadata']));

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantidade': quantidade,
      'valorUnitario': valorUnitario,
      'valorTotal': valorTotal,
      if (identifiers.isNotEmpty)
        'identifiers': identifiers.map((value) => value.toMap()).toList(),
      if (identifierContractVersion != null)
        'identifierContractVersion': identifierContractVersion,
      if (sourceItemNumber != null) 'sourceItemNumber': sourceItemNumber,
      if (sourceOrdinal != null) 'sourceOrdinal': sourceOrdinal,
      if (sourceMetadata.isNotEmpty) 'sourceMetadata': sourceMetadata,
    };
  }
}

List<IdentifierObservation> _parseIdentifiers(Object? value) {
  if (value is! List) return const [];
  return List.unmodifiable(
    value
        .map(IdentifierObservation.tryParse)
        .whereType<IdentifierObservation>(),
  );
}

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
