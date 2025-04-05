// lib/repository/tile_repository.dart
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tile_model.dart';

class TileRepository {
  static const String _tilesKey = 'tiles_data';
  final Uuid _uuid = const Uuid();

  // Get all tiles from local storage
  Future<List<Tile>> getAllTiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tilesJsonList = prefs.getStringList(_tilesKey) ?? [];

      return tilesJsonList.map((tileJson) => Tile.fromJson(tileJson)).toList();
    } catch (e) {
      print('Error getting tiles: $e');
      return [];
    }
  }

  // Get tiles filtered by company name
  Future<List<Tile>> getTilesByCompany(String companyName) async {
    final allTiles = await getAllTiles();
    return allTiles
        .where(
          (tile) => tile.companyName.toLowerCase().contains(
            companyName.toLowerCase(),
          ),
        )
        .toList();
  }

  // Add a new tile
  Future<bool> addTile(Tile tile) async {
    try {
      final tiles = await getAllTiles();
      final tileWithId = tile.copyWith(id: _uuid.v4());

      tiles.add(tileWithId);
      return await _saveTiles(tiles);
    } catch (e) {
      print('Error adding tile: $e');
      return false;
    }
  }

  // Update an existing tile
  Future<bool> updateTile(Tile updatedTile) async {
    try {
      final tiles = await getAllTiles();
      final index = tiles.indexWhere((tile) => tile.id == updatedTile.id);

      if (index >= 0) {
        tiles[index] = updatedTile;
        return await _saveTiles(tiles);
      }
      return false;
    } catch (e) {
      print('Error updating tile: $e');
      return false;
    }
  }

  // Delete a tile
  Future<bool> deleteTile(String id) async {
    try {
      final tiles = await getAllTiles();
      tiles.removeWhere((tile) => tile.id == id);
      return await _saveTiles(tiles);
    } catch (e) {
      print('Error deleting tile: $e');
      return false;
    }
  }

  // Save tiles to SharedPreferences
  Future<bool> _saveTiles(List<Tile> tiles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tilesJsonList = tiles.map((tile) => tile.toJson()).toList();
      return await prefs.setStringList(_tilesKey, tilesJsonList);
    } catch (e) {
      print('Error saving tiles: $e');
      return false;
    }
  }
}
