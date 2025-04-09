import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/components/pdf_generator.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';

void showPdfOptionsDialog(BuildContext context) {
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
                final pdfGenerator = PdfGenerator();
                pdfGenerator.generatePdf(context, allTiles: true);
              },
              child: const Text('All Tiles'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                final pdfGenerator = PdfGenerator();
                pdfGenerator.generatePdf(context, allTiles: false);
              },
              child: const Text('Filtered Tiles'),
            ),
          ],
        ),
  );
}
