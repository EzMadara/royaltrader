import 'package:equatable/equatable.dart';
import '../../models/tile_model.dart';

enum TileStatus { initial, loading, loaded, error }

class TileState extends Equatable {
  final List<Tile> tiles;
  final List<Tile> filteredTiles;
  final String? errorMessage;
  final TileStatus status;
  final String filterCompany;
  final String filterTileType;
  final String filterSize;
  final String filterColor;

  const TileState({
    this.tiles = const [],
    this.filteredTiles = const [],
    this.errorMessage,
    this.status = TileStatus.initial,
    this.filterCompany = '',
    this.filterTileType = '',
    this.filterSize = '',
    this.filterColor = '',
  });

  TileState copyWith({
    List<Tile>? tiles,
    List<Tile>? filteredTiles,
    String? errorMessage,
    TileStatus? status,
    String? filterCompany,
    String? filterTileType,
    String? filterSize,
    String? filterColor,
  }) {
    return TileState(
      tiles: tiles ?? this.tiles,
      filteredTiles: filteredTiles ?? this.filteredTiles,
      errorMessage: errorMessage,
      status: status ?? this.status,
      filterCompany: filterCompany ?? this.filterCompany,
      filterTileType: filterTileType ?? this.filterTileType,
      filterSize: filterSize ?? this.filterSize,
      filterColor: filterColor ?? this.filterColor,
    );
  }

  @override
  List<Object?> get props => [
    tiles,
    filteredTiles,
    errorMessage,
    status,
    filterCompany,
    filterTileType,
    filterSize,
    filterColor,
  ];
}
