import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/ui/TileDetailsScreen.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TileCard extends StatelessWidget {
  final Tile tile;

  const TileCard({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TileDetailsScreen(tile: tile),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        shadowColor: Colors.black38,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTileImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTileTitle(),
                    const SizedBox(height: 6),
                    _buildTileInfo(),
                    const SizedBox(height: 6),
                    _buildToneBadge(),
                    const SizedBox(height: 8),
                    _buildDeleteButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: tile.imageUrl ?? '',
        height: 100,
        width: 100,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Skeletonizer(
              enabled: true,
              effect: ShimmerEffect(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                duration: const Duration(seconds: 2),
              ),
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.broken_image, color: Colors.red),
            ),
      ),
    );
  }

  Widget _buildTileTitle() {
    return Text(
      tile.companyName,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTileInfo() {
    return Row(
      children: [
        Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Code: ${tile.code}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Size: ${tile.size}',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildToneBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.palette, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            'Tone: ${tile.tone}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showDeleteConfirmation(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Tile'),
            content: Text('Are you sure you want to delete ${tile.code}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<TileCubit>().deleteTile(tile.id);
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
