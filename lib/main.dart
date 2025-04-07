import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'
    show BlocProvider, MultiBlocProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:royaltrader/config/routes/routes.dart';
import 'package:royaltrader/config/routes/routes_name.dart';
import 'package:royaltrader/cubit/auth_cubit.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';
import 'package:royaltrader/firebase_options.dart';
import 'package:royaltrader/repositories/tile_repository.dart';
import 'package:royaltrader/theme/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final tileRepository = TileRepository();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TileCubit>(
          create:
              (_) => TileCubit(tileRepository)..loadTiles(), // Or init logic
        ),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Royal Traders',
        theme: ThemeData(
          dividerColor: const Color(0xffE0E0E0),
          primaryColor: appThemeColor,
          secondaryHeaderColor: Colors.black,
          appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
          scaffoldBackgroundColor: Colors.white,
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.montserratTextTheme(Typography.blackCupertino),
          useMaterial3: true,
        ),
        initialRoute: RoutesName.splashScreen,
        onGenerateRoute: Routes.generateRoute,
      ),
    );
  }
}
