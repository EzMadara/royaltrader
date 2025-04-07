// lib/ui/tiles/TileDetailsScreen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/models/tile_model.dart';

class TileDetailsScreen extends StatelessWidget {
  final Tile tile;

  const TileDetailsScreen({Key? key, required this.tile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tile Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tile.imageUrl != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(color: Colors.black),
                child: Image.network(
                  tile.imageUrl!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.white54,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Image not available',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.image_not_supported, size: 60),
                      SizedBox(height: 10),
                      Text('No image available'),
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          tile.code,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          tile.companyName,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow('Size', tile.size),
                      _buildDetailRow('Tone', tile.tone),
                      _buildDetailRow('Stock', tile.stock.toString()),
                      _buildDetailRow(
                        'Date Added',
                        DateFormat('dd MMMM, yyyy').format(tile.date),
                      ),
                      _buildDetailRow('ID', tile.id),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.editTile,
                          arguments: tile,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('ttttdit'),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RoutesName.tilesList,
                          arguments: tile,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to List'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
