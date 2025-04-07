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
    if (companyName.isEmpty) {
      emit(
        state.copyWith(filteredTiles: state.tiles, status: TileStatus.loaded),
      );
    } else {
      final filtered =
          state.tiles.where((tile) {
            return tile.companyName.toLowerCase().contains(
              companyName.toLowerCase(),
            );
          }).toList();

      emit(state.copyWith(filteredTiles: filtered, status: TileStatus.loaded));
    }
  }

  // Helper method to apply filter
  List<Tile> _applyFilter(List<Tile> tiles, String companyName) {
    if (companyName.isEmpty) {
      return tiles;
    }
    return tiles
        .where(
          (tile) => tile.companyName.toLowerCase().contains(
            companyName.toLowerCase(),
          ),
        )
        .toList();
  }

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
