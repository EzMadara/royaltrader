// 🔹 File: lib/ui/HomeScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/cubit/tile_state.dart'
    show TileError, TileLoaded, TileLoading, TileState, TileStatus;
import 'package:royaltrader/widgets/dumb_widgets/app_text_field_widget.dart';
import 'package:royaltrader/const/resource.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            onPressed: () {
              Navigator.pushNamed(context, 'add_tile');
            },
            child: const Icon(Icons.add),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                const SizedBox(height: 12),
                AppTextField(
                  labelText: 'Search by Company',
                  helpText: 'Search',
                  isFloatLabel: false,
                  onChanged: (value) {
                    // Implement filtering if needed
                  },
                  Function: (value) {},
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<TileCubit, TileState>(
                    builder: (context, state) {
                      if (state.status == TileStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state.status == TileStatus.loaded) {
                        if (state.tiles.isEmpty) {
                          return const Center(
                            child: Text('No Tiles Available'),
                          );
                        }
                        return ListView.builder(
                          itemCount: state.tiles.length,
                          itemBuilder: (context, index) {
                            final tile = state.tiles[index];
                            return Card(
                              // Define the shape of the card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              // Define how the card's content should be clipped
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              // Define the child widget of the card
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Add an image widget to display an image
                                    Image.network(
                                      tile.imageUrl ?? '',
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                    // Add some spacing between the image and the text
                                    Container(width: 20),
                                    // Add an expanded widget to take up the remaining horizontal space
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          // Add some spacing between the top of the card and the title
                                          Container(height: 5),
                                          // Add a title widget (company name)
                                          Text(
                                            tile.companyName,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium!.copyWith(
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          // Add some spacing between the title and the subtitle
                                          Container(height: 5),
                                          // Add a subtitle widget (tile code and size)
                                          Text(
                                            'Code: ${tile.code} - Size: ${tile.size}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.copyWith(
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                          // Add some spacing between the subtitle and the tone
                                          Container(height: 5),
                                          // Add tone info
                                          Text(
                                            'Tone: ${tile.tone}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall!.copyWith(
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          // Add a delete button to remove the tile
                                          Container(height: 10),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed:
                                                  () => context
                                                      .read<TileCubit>()
                                                      .deleteTile(tile.id),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
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

void _generatePDF() {
  print("Generating PDF...");
  // Implement PDF generation
}

void _logout(BuildContext context) {
  Navigator.pop(context);
  // Sign out logic
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
            _generatePDF();
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text("Logout", style: Theme.of(context).textTheme.bodyMedium),
          onTap: () => _logout(context),
        ),
      ],
    ),
  );
}
