import 'package:flutter/material.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/models/tile_model.dart';
import 'package:royaltrader/ui/ForgotMyPassword.dart';
import 'package:royaltrader/ui/HomeScreen.dart';
import 'package:royaltrader/ui/LoginScreen.dart';
import 'package:royaltrader/ui/SplashScreen.dart';
import 'package:royaltrader/ui/TilesListScreen.dart';
import 'package:royaltrader/ui/AddTileScreen.dart';
import 'package:royaltrader/ui/EditTileScreen.dart';
import 'package:royaltrader/ui/TileDetailsScreen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splashScreen:
        return MaterialPageRoute(builder: (context) => const Splashscreen());
      case RoutesName.loginScreen:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case RoutesName.homeScreen:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case RoutesName.forgotMyPassword:
        return MaterialPageRoute(
          builder: (context) => const ForgotMyPassword(),
        );

      // Tile inventory routes
      // case RoutesName.tilesList:
      //   return MaterialPageRoute(builder: (context) => const TilesListScreen());
      case RoutesName.addTile:
        return MaterialPageRoute(builder: (context) => const AddTileScreen());
      case RoutesName.editTile:
        final tile = settings.arguments as Tile;
        return MaterialPageRoute(
          builder: (context) => EditTileScreen(tile: tile),
        );
      case RoutesName.tileDetails:
        final tile = settings.arguments as Tile;
        return MaterialPageRoute(
          builder: (context) => TileDetailsScreen(tile: tile),
        );

      default:
        return MaterialPageRoute(builder: (context) => const Splashscreen());
    }
  }
}
