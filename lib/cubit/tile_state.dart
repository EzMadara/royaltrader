import 'package:equatable/equatable.dart';
import '../../models/tile_model.dart';

enum TileStatus { initial, loading, loaded, error }

class TileState extends Equatable {
  final List<Tile> tiles;
  final List<Tile> filteredTiles;
  final String? errorMessage;
  final TileStatus status;
  final String filterCompany;

  const TileState({
    this.tiles = const [],
    this.filteredTiles = const [],
    this.errorMessage,
    this.status = TileStatus.initial,
    this.filterCompany = '',
  });

  TileState copyWith({
    List<Tile>? tiles,
    List<Tile>? filteredTiles,
    String? errorMessage,
    TileStatus? status,
    String? filterCompany,
  }) {
    return TileState(
      tiles: tiles ?? this.tiles,
      filteredTiles: filteredTiles ?? this.filteredTiles,
      errorMessage: errorMessage,
      status: status ?? this.status,
      filterCompany: filterCompany ?? this.filterCompany,
    );
  }

  @override
  List<Object?> get props => [
    tiles,
    filteredTiles,
    errorMessage,
    status,
    filterCompany,
  ];
}
