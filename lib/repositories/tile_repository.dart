import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/tile_model.dart';

class TileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _tilesCollection = 'tiles';

  String? get _currentUserId => _auth.currentUser?.uid;

  // Check if a user is logged in
  bool get isUserLoggedIn => _currentUserId != null;

  // Get all tiles for the current user
  Future<List<Tile>> getUserTiles() async {
    try {
      // Ensure user is logged in
      if (!isUserLoggedIn) {
        return [];
      }

      final snapshot =
          await _firestore
              .collection(_tilesCollection)
              .where('userId', isEqualTo: _currentUserId)
              .get();
      return snapshot.docs
          .map((doc) => Tile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting user tiles: $e');
      return [];
    }
  }

  // Get tiles filtered by company name for the current user
  Future<List<Tile>> getUserTilesByCompany(String companyName) async {
    try {
      // Ensure user is logged in
      if (!isUserLoggedIn) {
        return [];
      }

      final snapshot =
          await _firestore
              .collection(_tilesCollection)
              .where('userId', isEqualTo: _currentUserId)
              .get();

      final tiles =
          snapshot.docs
              .map((doc) => Tile.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

      return tiles
          .where(
            (tile) => tile.companyName.toLowerCase().contains(
              companyName.toLowerCase(),
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting user tiles by company: $e');
      return [];
    }
  }

  // Add a new tile for the current user
  Future<bool> addTile(Tile tile) async {
    try {
      // Ensure user is logged in
      if (!isUserLoggedIn) {
        return false;
      }

      // Create a tile with ID and current user ID
      final tileWithId = tile.copyWith(id: _uuid.v4(), userId: _currentUserId);

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

  // Update an existing tile - ensure it belongs to the current user
  Future<bool> updateTile(Tile updatedTile) async {
    try {
      // Ensure user is logged in
      if (!isUserLoggedIn) {
        return false;
      }

      // Get the tile first to verify ownership
      final tileDoc =
          await _firestore
              .collection(_tilesCollection)
              .doc(updatedTile.id)
              .get();

      if (!tileDoc.exists) {
        return false;
      }

      final existingTile = Tile.fromMap(tileDoc.data() as Map<String, dynamic>);

      // Check if the tile belongs to the current user
      if (existingTile.userId != _currentUserId) {
        return false; // Not authorized to update this tile
      }

      // Ensure we keep the original userId when updating
      final tileToUpdate = updatedTile.copyWith(userId: _currentUserId);

      // Update the tile in Firestore
      await _firestore
          .collection(_tilesCollection)
          .doc(updatedTile.id)
          .update(tileToUpdate.toMap());

      return true;
    } catch (e) {
      print('Error updating tile: $e');
      return false;
    }
  }

  // Delete a tile - ensure it belongs to the current user
  Future<bool> deleteTile(String id) async {
    try {
      // Ensure user is logged in
      if (!isUserLoggedIn) {
        return false;
      }

      // Get the tile first to verify ownership
      final tileDoc =
          await _firestore.collection(_tilesCollection).doc(id).get();

      if (!tileDoc.exists) {
        return false;
      }

      final existingTile = Tile.fromMap(tileDoc.data() as Map<String, dynamic>);

      // Check if the tile belongs to the current user
      if (existingTile.userId != _currentUserId) {
        return false; // Not authorized to delete this tile
      }

      if (existingTile.imageUrl != null && existingTile.imageUrl!.isNotEmpty) {
        try {
          await FirebaseStorage.instance
              .refFromURL(existingTile.imageUrl!)
              .delete();
        } catch (e) {
          print('Error deleting image from Firebase Storage: $e');
          // Handle the error gracefully if necessary
        }
      }
      // Delete the tile from Firestore
      await _firestore.collection(_tilesCollection).doc(id).delete();

      return true;
    } catch (e) {
      print('Error deleting tile: $e');
      return false;
    }
  }

  // For admin functionality - get all tiles regardless of user
  Future<List<Tile>> getAllTiles() async {
    try {
      final snapshot = await _firestore.collection(_tilesCollection).get();
      return snapshot.docs
          .map((doc) => Tile.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all tiles: $e');
      return [];
    }
  }

  // Get all tiles from Firestore
  // Future<List<Tile>> getAllTiles() async {
  //   try {
  //     final snapshot = await _firestore.collection(_tilesCollection).get();
  //     return snapshot.docs
  //         .map((doc) => Tile.fromMap(doc.data() as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     print('Error getting tiles: $e');
  //     return [];
  //   }
  // }

  // // Get tiles filtered by company name
  // Future<List<Tile>> getTilesByCompany(String companyName) async {
  //   final allTiles = await getAllTiles();
  //   return allTiles
  //       .where(
  //         (tile) => tile.companyName.toLowerCase().contains(
  //           companyName.toLowerCase(),
  //         ),
  //       )
  //       .toList();
  // }

  // // Add a new tile
  // Future<bool> addTile(Tile tile) async {
  //   try {
  //     final tileWithId = tile.copyWith(id: _uuid.v4());

  //     // Add the tile to Firestore
  //     await _firestore
  //         .collection(_tilesCollection)
  //         .doc(tileWithId.id)
  //         .set(tileWithId.toMap());
  //     return true;
  //   } catch (e) {
  //     print('Error adding tile: $e');
  //     return false;
  //   }
  // }

  // // Update an existing tile
  // Future<bool> updateTile(Tile updatedTile) async {
  //   try {
  //     // Update the tile in Firestore
  //     await _firestore
  //         .collection(_tilesCollection)
  //         .doc(updatedTile.id)
  //         .update(updatedTile.toMap());
  //     return true;
  //   } catch (e) {
  //     print('Error updating tile: $e');
  //     return false;
  //   }
  // }

  // // Delete a tile
  // Future<bool> deleteTile(String id) async {
  //   try {
  //     // Delete the tile from Firestore
  //     await _firestore.collection(_tilesCollection).doc(id).delete();
  //     return true;
  //   } catch (e) {
  //     print('Error deleting tile: $e');
  //     return false;
  //   }
  // }
}
