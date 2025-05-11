// lib/models/tile_model.dart
import 'dart:convert';

class Tile {
  final String id;
  final DateTime date;
  final String code;
  final String size;
  final String companyName;
  final String tone;
  final int stock;
  final int boxQuantity;
  final String tileType;
  final String tileColor;
  final String? imageUrl;
  final String userId;

  Tile({
    required this.id,
    required this.date,
    required this.code,
    required this.size,
    required this.companyName,
    required this.tone,
    required this.stock,
    required this.boxQuantity,
    required this.tileType,
    required this.tileColor,
    this.imageUrl,
    required this.userId,
  });

  Tile copyWith({
    String? id,
    DateTime? date,
    String? code,
    String? size,
    String? companyName,
    String? tone,
    int? stock,
    int? boxQuantity,
    String? tileType,
    String? tileColor,
    String? imageUrl,
    String? userId,
  }) {
    return Tile(
      id: id ?? this.id,
      date: date ?? this.date,
      code: code ?? this.code,
      size: size ?? this.size,
      companyName: companyName ?? this.companyName,
      tone: tone ?? this.tone,
      stock: stock ?? this.stock,
      boxQuantity: boxQuantity ?? this.boxQuantity,
      tileType: tileType ?? this.tileType,
      tileColor: tileColor ?? this.tileColor,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.millisecondsSinceEpoch,
      'code': code,
      'size': size,
      'companyName': companyName,
      'tone': tone,
      'stock': stock,
      'boxQuantity': boxQuantity,
      'tileType': tileType,
      'tileColor': tileColor,
      'imageUrl': imageUrl,
      'userId': userId,
    };
  }

  factory Tile.fromMap(Map<String, dynamic> map) {
    return Tile(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      code: map['code'] ?? '',
      size: map['size'] ?? '',
      companyName: map['companyName'] ?? '',
      tone: map['tone'] ?? '',
      stock: map['stock'] ?? 0,
      boxQuantity: map['boxQuantity'] ?? 0,
      tileType: map['tileType'] ?? '',
      tileColor: map['tileColor'] ?? '',
      imageUrl: map['imageUrl'],
      userId: map['userId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Tile.fromJson(String source) => Tile.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Tile(id: $id, date: $date, code: $code, size: $size, companyName: $companyName, tone: $tone, stock: $stock, boxQuantity: $boxQuantity, tileType: $tileType, tileColor: $tileColor, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Tile &&
        other.id == id &&
        other.date == date &&
        other.code == code &&
        other.size == size &&
        other.companyName == companyName &&
        other.tone == tone &&
        other.userId == userId &&
        other.stock == stock &&
        other.boxQuantity == boxQuantity &&
        other.tileType == tileType &&
        other.tileColor == tileColor;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        date.hashCode ^
        code.hashCode ^
        size.hashCode ^
        companyName.hashCode ^
        tone.hashCode ^
        userId.hashCode ^
        stock.hashCode ^
        boxQuantity.hashCode ^
        tileType.hashCode ^
        tileColor.hashCode;
  }
}
