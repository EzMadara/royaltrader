import 'package:flutter/material.dart';
import 'package:royaltrader/components/tile_card.dart';
import 'package:royaltrader/models/tile_model.dart';

class TileListView extends StatelessWidget {
  final List<Tile> tiles;

  const TileListView({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final tile = tiles[index];
        return TileCard(tile: tile);
      },
    );
  }
}
