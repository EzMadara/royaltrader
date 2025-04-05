import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';

import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/const/resource.dart';

import '../theme/colors.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSplashScreen.withScreenRouteFunction(
          animationDuration: const Duration(milliseconds: 1000),
          screenRouteFunction: () async {
            return RoutesName.loginScreen;
          },
          splash: Image.asset(
            R.ASSETS_LOGO_JPG,
            fit: BoxFit.cover, // Adjust the image fit if necessary
          ),
          splashIconSize: 200,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
