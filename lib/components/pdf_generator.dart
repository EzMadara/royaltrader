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
  Future<void> generatePdf(
    BuildContext context, {
    required bool allTiles,
  }) async {
    final state = context.read<TileCubit>().state;
    final tiles = allTiles ? state.tiles : state.filteredTiles;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Generating PDF...."),
        duration: Duration(seconds: 2),
      ),
    );

    final pdf = pw.Document();
    final ByteData logoData = await rootBundle.load('assets/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    final Map<String, pw.MemoryImage> tileImages = {};

    // Load all tile images
    for (final tile in tiles) {
      try {
        if (tile.imageUrl != null && tile.imageUrl!.isNotEmpty) {
          final url = tile.imageUrl;
          final response = await http.get(Uri.parse(url!));
          tileImages[tile.code] = pw.MemoryImage(response.bodyBytes);
        }
      } catch (e) {
        print('Failed to load image for tile: ${tile.code}, error: $e');
      }
    }

    // Create a page for each tile
    for (final tile in tiles) {
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(40),
          build:
              (context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Header with logo at top right
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Company name and subtitle
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            tile.companyName.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.black,
                            ),
                          ),
                          pw.SizedBox(height: 5),
                        ],
                      ),

                      pw.Container(
                        height: 60,
                        width: 60,
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),
                  tileImages.containsKey(tile.code)
                      ? pw.Container(
                        height: 380,
                        width: 700,
                        alignment: pw.Alignment.center,
                        child: pw.Image(
                          tileImages[tile.code]!,
                          fit: pw.BoxFit.fill,
                        ),
                      )
                      : pw.Container(
                        height: 380,
                        width: 500,
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          'No Image Available',
                          style: pw.TextStyle(fontSize: 16),
                        ),
                      ),
                  pw.SizedBox(height: 30),

                  pw.Container(
                    width: 500,
                    padding: const pw.EdgeInsets.symmetric(vertical: 10),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Code', tile.code),
                        _buildDetailRow('Company', tile.companyName),
                        _buildDetailRow('Size', tile.size),
                        _buildDetailRow('Tone', tile.tone),
                        _buildDetailRow('Stock', tile.stock.toString()),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    '${tile.companyName} ${tile.code} ${tile.tone}',
                    style: pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 70),

                  pw.Container(
                    alignment: pw.Alignment.bottomCenter,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(logoImage, width: 20, height: 20),
                        pw.SizedBox(width: 5),
                        pw.Text(
                          'Royal Tiles And Sanitary',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 30,
                        height: 30,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.amber700,
                          borderRadius: pw.BorderRadius.circular(2),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text(
                          '${tiles.indexOf(tile) + 1}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Container(
            width: 70,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
