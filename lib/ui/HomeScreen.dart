// 🔹 File: lib/ui/HomeScreen.dart
import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart'
    show TileError, TileLoaded, TileLoading, TileState, TileStatus;
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/ui/TileDetailsScreen.dart';
import 'package:royaltrader/widgets/dumb_widgets/SearchFilterWidget.dart';
import 'package:royaltrader/widgets/dumb_widgets/app_text_field_widget.dart';
import 'package:royaltrader/const/resource.dart';
import 'package:http/http.dart' as http;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    context.read<TileCubit>().loadTiles();
    _searchController.addListener(() {
      if (_searchController.text !=
          context.read<TileCubit>().state.filterCompany) {
        context.read<TileCubit>().searchTilesByCompany(_searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            centerTitle: true,
            title: Image.asset(R.ASSETS_LOGO_JPG, height: 50),
          ),
          drawer: _buildDrawer(context),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.pushNamed(context, RoutesName.addTile);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                SearchFilterWidget(searchController: _searchController),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<TileCubit, TileState>(
                    builder: (context, state) {
                      if (state.status == TileStatus.loading) {
                        return Skeletonizer(
                          enabled: true,
                          effect: ShimmerEffect(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            duration: const Duration(seconds: 2),
                          ),
                          child: ListView.builder(
                            itemCount: 6, // Show 6 fake items
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          height: 100,
                                          width: 100,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(width: 20),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(height: 5),
                                              Container(
                                                height: 20,
                                                width: 150,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                height: 18,
                                                width: 200,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                height: 16,
                                                width: 100,
                                                color: Colors.grey[300],
                                              ),
                                              const SizedBox(height: 10),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.grey[300],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state.status == TileStatus.loaded) {
                        if (state.tiles.isEmpty) {
                          return const Center(
                            child: Text('No Tiles Available'),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.filteredTiles.length,
                          itemBuilder: (context, index) {
                            final tile = state.filteredTiles[index];
                            return _buildTileCard(context, tile);
                          },
                        );
                      } else if (state.status == TileStatus.error) {
                        return Center(
                          child: Text('Error: ${state.errorMessage}'),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTileCard(BuildContext context, Tile tile) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TileDetailsScreen(tile: tile)),
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
            // Image with rounded corners
            ClipRRect(
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
            ),

            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    tile.companyName,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
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
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () => _showDeleteConfirmation(context, tile),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[400],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Generating PDF...."),
      duration: Duration(seconds: 2),
    ),
  );

  final pdf = pw.Document();
  final companyFilter =
      state.filterCompany.isEmpty
          ? 'All Companies'
          : 'Company: ${state.filterCompany}';

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
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 50, height: 50),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      'Royal Tiles And Sanitary',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Tile Detail - $companyFilter',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: const pw.TextStyle(fontSize: 12),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Large Image
                tileImages.containsKey(tile.code)
                    ? pw.Container(
                      height: 300,
                      width: 400,
                      alignment: pw.Alignment.center,
                      child: pw.Image(
                        tileImages[tile.code]!,
                        fit: pw.BoxFit.contain,
                      ),
                    )
                    : pw.Container(
                      height: 300,
                      width: 400,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Text(
                        'No Image Available',
                        style: pw.TextStyle(fontSize: 16),
                      ),
                    ),
                pw.SizedBox(height: 30),

                // Tile Details in a styled container
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(10),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Code', tile.code),
                      _buildDetailRow('Company', tile.companyName),
                      _buildDetailRow('Size', tile.size),
                      _buildDetailRow('Tone', tile.tone),
                      _buildDetailRow('Stock', tile.stock.toString()),
                      _buildDetailRow(
                        'Date',
                        DateFormat('dd/MM/yyyy').format(tile.date),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      build:
          (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Image(logoImage, width: 50, height: 50),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'Royal Tiles And Sanitary',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Inventory Summary - $companyFilter',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),

              pw.Text(
                'Summary Information:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text('Total Items: ${tiles.length}'),
              pw.Text(
                'Total Stock: ${tiles.fold<int>(0, (sum, tile) => sum + tile.stock)}',
              ),
            ],
          ),
    ),
  );

  await Printing.layoutPdf(
    onLayout: (format) => pdf.save(),
    name:
        'tiles_inventory_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
  );
}

pw.Widget _buildDetailRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      children: [
        pw.Container(
          width: 100,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ),
        pw.Expanded(
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ),
      ],
    ),
  );
}

pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : null),
    ),
  );
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          accountName: Text(
            "Ali Abbas",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          accountEmail: Text(
            "aliabbas@gmail.com",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          currentAccountPicture: CircleAvatar(
            backgroundImage: AssetImage(R.ASSETS_LOGO_JPG),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(
            "Generate PDF",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onTap: () {
            Navigator.pop(context);
            _showPdfOptions(context);
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text("Logout", style: Theme.of(context).textTheme.bodyMedium),
          onTap: () {
            context.read<AuthCubit>().signOut();
            Navigator.pushNamedAndRemoveUntil(
              context,
              RoutesName.loginScreen,
              (route) => false,
            );
          },
        ),
      ],
    ),
  );
}
