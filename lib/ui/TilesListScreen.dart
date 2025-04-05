// lib/ui/tiles/TilesListScreen.dart
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field2_widget.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field_widget.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TilesListScreen extends StatefulWidget {
  const TilesListScreen({super.key});

  @override
  State<TilesListScreen> createState() => _TilesListScreenState();
}

class _TilesListScreenState extends State<TilesListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load tiles when screen initializes
    context.read<TileCubit>().loadTiles();

    _searchController.addListener(() {
      context.read<TileCubit>().filterByCompany(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiles Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _showPdfOptions(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.addTile);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppTextField2(
              labelText: 'Search by Company',
              helpText: 'Enter company name',
              isFloatLabel: false,
              controller: _searchController,
              // suffix: Icon(Icons.search, color: Theme.of(context).primaryColor),
            ),
          ),
          Expanded(
            child: BlocBuilder<TileCubit, TileState>(
              builder: (context, state) {
                if (state.status == TileStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state.status == TileStatus.error) {
                  return Center(
                    child: Text(state.errorMessage ?? 'An error occurred'),
                  );
                } else if (state.filteredTiles.isEmpty) {
                  return const Center(child: Text('No tiles found'));
                }

                return ListView.builder(
                  itemCount: state.filteredTiles.length,
                  itemBuilder: (context, index) {
                    final tile = state.filteredTiles[index];
                    return _buildTileCard(context, tile);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileCard(BuildContext context, Tile tile) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.pushNamed(context, RoutesName.tileDetails, arguments: tile);
        },
        leading:
            tile.imagePath != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(tile.imagePath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                )
                : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
        title: Text(
          '${tile.code} - ${tile.companyName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Size: ${tile.size}'),
            Text('Tone: ${tile.tone}'),
            Text('Stock: ${tile.stock}'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(tile.date)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  RoutesName.editTile,
                  arguments: tile,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, tile),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Tile tile) {
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

  void _showPdfOptions(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Generate PDF Report'),
            content: const Text('Choose the type of report to generate'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _generatePdf(context, allTiles: true);
                },
                child: const Text('All Tiles'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _generatePdf(context, allTiles: false);
                },
                child: const Text('Filtered Tiles'),
              ),
            ],
          ),
    );
  }

  Future<void> _generatePdf(
    BuildContext context, {
    required bool allTiles,
  }) async {
    final state = context.read<TileCubit>().state;
    final tiles = allTiles ? state.tiles : state.filteredTiles;

    final pdf = pw.Document();
    final companyFilter =
        state.filterCompany.isEmpty
            ? 'All Companies'
            : 'Company: ${state.filterCompany}';

    pdf.addPage(
      pw.MultiPage(
        header:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Royal Tiles And Sanitary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Inventory Report - $companyFilter',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(),
              ],
            ),
        build:
            (context) => [
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headers: ['Code', 'Company', 'Size', 'Tone', 'Stock', 'Date'],
                data:
                    tiles
                        .map(
                          (tile) => [
                            tile.code,
                            tile.companyName,
                            tile.size,
                            tile.tone,
                            tile.stock.toString(),
                            DateFormat('dd/MM/yyyy').format(tile.date),
                          ],
                        )
                        .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Items: ${tiles.length}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Total Stock: ${tiles.fold<int>(0, (sum, tile) => sum + tile.stock)}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name:
          'tiles_inventory_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }
}
