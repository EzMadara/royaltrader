import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/tile_model.dart';

class TileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  static const String _tilesCollection = 'tiles';

  // Get all tiles from Firestore
  Future<List<Tile>> getAllTiles() async {
    try {
      final snapshot = await _firestore.collection(_tilesCollection).get();
      return snapshot.docs
          .map((doc) => Tile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
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
      final tileWithId = tile.copyWith(id: _uuid.v4());

      // Add the tile to Firestore
      await _firestore
          .collection(_tilesCollection)
          .doc(tileWithId.id)
          .set(tileWithId.toMap());
      return true;
    } catch (e) {
      print('Error adding tile: $e');
      return false;
    }
  }

  // Update an existing tile
  Future<bool> updateTile(Tile updatedTile) async {
    try {
      // Update the tile in Firestore
      await _firestore
          .collection(_tilesCollection)
          .doc(updatedTile.id)
          .update(updatedTile.toMap());
      return true;
    } catch (e) {
      print('Error updating tile: $e');
      return false;
    }
  }

  // Delete a tile
  Future<bool> deleteTile(String id) async {
    try {
      // Delete the tile from Firestore
      await _firestore.collection(_tilesCollection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting tile: $e');
      return false;
    }
  }
}
