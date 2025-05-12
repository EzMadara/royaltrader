import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/components/pdf_generator.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final Map<String, int> _cart = {};
  final Map<String, Tile> _tileDetails = {};
  final TextEditingController _searchController = TextEditingController();
  List<Tile> _filteredTiles = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterTiles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTiles() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredTiles =
          context.read<TileCubit>().state.tiles.where((tile) {
            return tile.code.toLowerCase().contains(searchQuery) ||
                tile.companyName.toLowerCase().contains(searchQuery) ||
                tile.size.toLowerCase().contains(searchQuery);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by code, company, or size',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<TileCubit, TileState>(
              builder: (context, state) {
                if (_searchController.text.isEmpty) {
                  _filteredTiles = state.tiles;
                }
                return ListView.builder(
                  itemCount: _filteredTiles.length,
                  itemBuilder: (context, index) {
                    final tile = _filteredTiles[index];
                    return _buildTileCard(tile);
                  },
                );
              },
            ),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildTileCard(Tile tile) {
    final quantity = _cart[tile.code] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tile.code,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Company: ${tile.companyName}'),
                      Text('Size: ${tile.size}'),
                      Text('Available Stock: ${tile.stock}'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed:
                          quantity < tile.stock
                              ? () => _updateQuantity(tile, quantity + 1)
                              : null,
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed:
                          quantity > 0
                              ? () => _updateQuantity(tile, quantity - 1)
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Items:', style: TextStyle(fontSize: 18)),
              Text(
                _cart.values
                    .fold(0, (sum, quantity) => sum + quantity)
                    .toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cart.isEmpty ? null : _generateInvoice,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Generate Invoice'),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(Tile tile, int newQuantity) {
    setState(() {
      if (newQuantity > 0) {
        _cart[tile.code] = newQuantity;
        _tileDetails[tile.code] = tile;
      } else {
        _cart.remove(tile.code);
        _tileDetails.remove(tile.code);
      }
    });
  }

  void _generateInvoice() async {
    final pdfGenerator = PdfGenerator();
    await pdfGenerator.generateInvoicePdf(
      context,
      cart: _cart,
      tileDetails: _tileDetails,
      address: '22-2-C2, College Road Butt Chowk Township Lahore',
      contactPerson1: 'Rana Ali Abbas',
      contactNumber1: '0317-0009544',
      contactPerson2: 'Bilal',
      contactNumber2: '0312 6954242',
    );

    // Update stock in Firestore
    for (final entry in _cart.entries) {
      final tile = _tileDetails[entry.key]!;
      final updatedTile = tile.copyWith(stock: tile.stock - entry.value);
      context.read<TileCubit>().updateTile(updatedTile);
    }

    // Clear cart
    setState(() {
      _cart.clear();
      _tileDetails.clear();
    });
  }
}
