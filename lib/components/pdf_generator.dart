import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:http/http.dart' as http;

class PdfGenerator {
  /// Generate PDF for all or filtered tiles
  Future<void> generatePdf(
    BuildContext context, {
    required bool allTiles,
  }) async {
    final state = context.read<TileCubit>().state;
    final tiles = allTiles ? state.tiles : state.filteredTiles;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Generating PDF...")));

    final pdf = pw.Document();
    final logoImage = await _loadLogo();
    final tileImages = await _loadTileImages(tiles);

    for (final tile in tiles) {
      pdf.addPage(
        pw.Page(
          orientation: pw.PageOrientation.portrait,
          margin: const pw.EdgeInsets.all(0),
          build:
              (context) => _buildTilePage(
                tile,
                logoImage,
                tileImages[tile.code],
                tiles.indexOf(tile) + 1,
              ),
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name:
          'tiles_catalog_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Generate PDF for a single tile
  Future<void> generateSingleTilePdf(BuildContext context, Tile tile) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Generating tile PDF...")));

    final pdf = pw.Document();
    final logoImage = await _loadLogo();

    pw.MemoryImage? tileImage;
    try {
      if (tile.imageUrl != null && tile.imageUrl!.isNotEmpty) {
        final response = await http.get(Uri.parse(tile.imageUrl!));
        tileImage = pw.MemoryImage(response.bodyBytes);
      }
    } catch (e) {
      print('Failed to load image for tile: ${tile.code}, error: $e');
    }

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.portrait,
        margin: const pw.EdgeInsets.all(0),
        build: (context) => _buildTilePage(tile, logoImage, tileImage, 1),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name:
          '${tile.code}_tile_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Load company logo from assets
  Future<pw.MemoryImage> _loadLogo() async {
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    return pw.MemoryImage(logoBytes);
  }

  /// Load tile images into memory
  Future<Map<String, pw.MemoryImage>> _loadTileImages(List<Tile> tiles) async {
    final Map<String, pw.MemoryImage> tileImages = {};
    for (final tile in tiles) {
      try {
        if (tile.imageUrl != null && tile.imageUrl!.isNotEmpty) {
          final response = await http.get(Uri.parse(tile.imageUrl!));
          tileImages[tile.code] = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        print('Failed to load image for tile: ${tile.code}, error: $e');
      }
    }
    return tileImages;
  }

  /// Build a PDF page layout for a tile
  pw.Widget _buildTilePage(
    Tile tile,
    pw.MemoryImage logoImage,
    pw.MemoryImage? tileImage,
    int index,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Left Panel
        pw.Container(
          width: 250,
          color: PdfColors.blueGrey800,
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                height: 100,
                width: 100,
                child: pw.Image(logoImage, fit: pw.BoxFit.contain),
              ),
              pw.Text(
                'Royal Traders',
                style: pw.TextStyle(
                  fontSize: 24,
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Column(
                children: [
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Company: ${tile.companyName}',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Tone: ${tile.tone}',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'Code: ${tile.code}',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.white),
                  ),
                ],
              ),
              pw.Container(
                width: 30,
                height: 30,
                decoration: pw.BoxDecoration(
                  color: PdfColors.amber700,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  '$index',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right Content
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.SizedBox(height: 50),
              pw.Center(
                child: pw.Container(
                  width: 350,
                  height: 50,
                  color: PdfColors.blue900,
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    '(${tile.size}) ${_formatDimensions(tile.size)}',
                    style: pw.TextStyle(
                      fontSize: 20,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Expanded(
                      flex: 10,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              width: double.infinity,
                              color: PdfColors.grey200,
                              child:
                                  tileImage != null
                                      ? pw.Image(
                                        width: 350,
                                        height: 400,
                                        tileImage,
                                        fit: pw.BoxFit.contain,
                                      )
                                      : pw.Center(
                                        child: pw.Text(
                                          'No Image Available',
                                          style: pw.TextStyle(fontSize: 16),
                                        ),
                                      ),
                            ),
                          ),
                          pw.Container(
                            width: 170,
                            height: 60,
                            color: PdfColors.blue900,
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  'Code: ${tile.code}',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Stock: ${tile.stock} BOX',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    color: PdfColors.white,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDimensions(String size) {
    final parts = size.split('x');
    if (parts.length == 2) {
      try {
        final width = int.parse(parts[0]);
        final height = int.parse(parts[1]);
        final inchesWidth = (width / 25.4).round();
        final inchesHeight = (height / 25.4).round();
        return '${inchesWidth}X${inchesHeight} AAA';
      } catch (e) {
        return 'Unknown';
      }
    }
    return size;
  }
}
