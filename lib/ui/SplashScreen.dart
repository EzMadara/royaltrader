import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/const/resource.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:royaltrader/cubit/auth_state.dart';

import '../theme/colors.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, RoutesName.homeScreen);
        } else if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, RoutesName.loginScreen);
        }
      },
      child: Scaffold(
        body: Center(
          child: AnimatedSplashScreen.withScreenRouteFunction(
            animationDuration: const Duration(milliseconds: 1000),
            screenRouteFunction: () async {
              await Future.delayed(const Duration(milliseconds: 500));

              final state = context.read<AuthCubit>().state;
              if (state is AuthAuthenticated) {
                return RoutesName.homeScreen;
              } else {
                return RoutesName.loginScreen;
              }
            },
            splash: Image.asset(R.ASSETS_LOGO_JPG, fit: BoxFit.cover),
            splashIconSize: 200,
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
