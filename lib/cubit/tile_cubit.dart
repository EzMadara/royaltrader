import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/tile_model.dart';
import '../repositories/tile_repository.dart' show TileRepository;
import 'tile_state.dart';

class TileCubit extends Cubit<TileState> {
  final TileRepository _repository;

  TileCubit(this._repository) : super(const TileState());

  Future<void> loadTiles() async {
    try {
      emit(state.copyWith(status: TileStatus.loading));
      final tiles = await _repository.getUserTiles();
      emit(
        state.copyWith(
          tiles: tiles,
          filteredTiles: tiles,
          status: TileStatus.loaded,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TileStatus.error,
          errorMessage: 'Failed to load tiles: $e',
        ),
      );
    }
  }

  // Future<void> loadTiles() async {
  //   emit(state.copyWith(status: TileStatus.loading));
  //   try {
  //     final tiles = await _repository.getAllTiles();
  //     emit(
  //       state.copyWith(
  //         tiles: tiles,
  //         filteredTiles: _applyFilter(tiles, state.filterCompany),
  //         status: TileStatus.loaded,
  //       ),
  //     );
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         status: TileStatus.error,
  //         errorMessage: 'Failed to load tiles: $e',
  //       ),
  //     );
  //   }
  // }

  // Filter tiles by company name
  // void filterByCompany(String companyName) {
  //   emit(
  //     state.copyWith(
  //       filterCompany: companyName,
  //       filteredTiles: _applyFilter(state.tiles, companyName),
  //     ),
  //   );
  // }

  Future<void> searchTilesByCompany(String companyName) async {
    emit(state.copyWith(filterCompany: companyName));
    _applyFilters();
  }

  void filterByTileType(String tileType) {
    emit(state.copyWith(filterTileType: tileType));
    _applyFilters();
  }

  void filterBySize(String size) {
    emit(state.copyWith(filterSize: size));
    _applyFilters();
  }

  void filterByColor(String color) {
    emit(state.copyWith(filterColor: color));
    _applyFilters();
  }

  void _applyFilters() {
    final filtered =
        state.tiles.where((tile) {
          final matchesCompany =
              state.filterCompany.isEmpty ||
              tile.companyName.toLowerCase().contains(
                state.filterCompany.toLowerCase(),
              );

          final matchesTileType =
              state.filterTileType.isEmpty ||
              tile.tileType.toLowerCase() == state.filterTileType.toLowerCase();

          final matchesSize =
              state.filterSize.isEmpty ||
              tile.size.toLowerCase() == state.filterSize.toLowerCase();

          final matchesColor =
              state.filterColor.isEmpty ||
              tile.tileColor.toLowerCase() == state.filterColor.toLowerCase();

          return matchesCompany &&
              matchesTileType &&
              matchesSize &&
              matchesColor;
        }).toList();

    emit(state.copyWith(filteredTiles: filtered, status: TileStatus.loaded));
  }

  // Predefined values for filters
  static const List<String> tileTypes = ['polish', 'matt', 'candy'];
  static const List<String> tileColors = ['Light', 'Dark', 'Motive'];
  static const List<String> tileSizes = [
    '2*2',
    '2*4',
    '16*16',
    '12*24',
    '12*36',
    '18*36',
    '12*32',
    '6*32',
    '8*36',
    '8*48',
  ];

  // Helper methods to get filter values
  List<String> getUniqueTileTypes() => tileTypes;
  List<String> getUniqueSizes() => tileSizes;
  List<String> getUniqueColors() => tileColors;

  // Add a new tile
  Future<void> addTile(Tile tile) async {
    emit(state.copyWith(status: TileStatus.loading));
    try {
      final success = await _repository.addTile(tile);
      if (success) {
        await loadTiles();
      } else {
        emit(
          state.copyWith(
            status: TileStatus.error,
            errorMessage: 'Failed to add tile',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: TileStatus.error,
          errorMessage: 'Failed to add tile: $e',
        ),
      );
    }
  }

  // Update an existing tile
  Future<void> updateTile(Tile tile) async {
    emit(state.copyWith(status: TileStatus.loading));
    try {
      final success = await _repository.updateTile(tile);
      if (success) {
        await loadTiles();
      } else {
        emit(
          state.copyWith(
            status: TileStatus.error,
            errorMessage: 'Failed to update tile',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: TileStatus.error,
          errorMessage: 'Failed to update tile: $e',
        ),
      );
    }
  }

  // Delete a tile
  Future<void> deleteTile(String id) async {
    emit(state.copyWith(status: TileStatus.loading));
    try {
      final success = await _repository.deleteTile(id);
      if (success) {
        await loadTiles();
      } else {
        emit(
          state.copyWith(
            status: TileStatus.error,
            errorMessage: 'Failed to delete tile',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: TileStatus.error,
          errorMessage: 'Failed to delete tile: $e',
        ),
      );
    }
  }
}
