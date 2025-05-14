import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/components/home_drawer.dart';
import 'package:royaltrader/components/ile_list_view.dart';
import 'package:royaltrader/components/pdf_dialog.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart';
import 'package:royaltrader/const/resource.dart';
import 'package:royaltrader/widgets/dumb_widgets/SearchFilterWidget.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

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
          drawer: HomeDrawer(
            onGeneratePdf: () => showPdfOptionsDialog(context),
            onLogout: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesName.loginScreen,
                (route) => false,
              );
            },
          ),
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
                BlocBuilder<TileCubit, TileState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Tile Type',
                              border: OutlineInputBorder(),
                            ),
                            value:
                                state.filterTileType.isEmpty
                                    ? null
                                    : state.filterTileType,
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('Types'),
                              ),
                              ...context
                                  .read<TileCubit>()
                                  .getUniqueTileTypes()
                                  .map(
                                    (type) => DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(type),
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              context.read<TileCubit>().filterByTileType(
                                value ?? '',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Size',
                              border: OutlineInputBorder(),
                            ),
                            value:
                                state.filterSize.isEmpty
                                    ? null
                                    : state.filterSize,
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('Sizes'),
                              ),
                              ...context.read<TileCubit>().getUniqueSizes().map(
                                (size) => DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(size),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              context.read<TileCubit>().filterBySize(
                                value ?? '',
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              border: OutlineInputBorder(),
                            ),
                            value:
                                state.filterColor.isEmpty
                                    ? null
                                    : state.filterColor,
                            items: [
                              const DropdownMenuItem<String>(
                                value: '',
                                child: Text('Colors'),
                              ),
                              ...context
                                  .read<TileCubit>()
                                  .getUniqueColors()
                                  .map(
                                    (color) => DropdownMenuItem<String>(
                                      value: color,
                                      child: Text(color),
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              context.read<TileCubit>().filterByColor(
                                value ?? '',
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<TileCubit, TileState>(
                    builder: (context, state) {
                      if (state.status == TileStatus.loading) {
                        return _buildLoadingSkeletons();
                      } else if (state.status == TileStatus.loaded) {
                        if (state.tiles.isEmpty) {
                          return const Center(
                            child: Text('No Tiles Available'),
                          );
                        }
                        return TileListView(tiles: state.filteredTiles);
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

  Widget _buildLoadingSkeletons() {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        duration: const Duration(seconds: 2),
      ),
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(height: 100, width: 100, color: Colors.grey[300]),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            alignment: Alignment.centerRight,
                            child: Icon(Icons.delete, color: Colors.grey[300]),
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
  }
}
