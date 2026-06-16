import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'data/app_state.dart';
import 'data/mapbox_config.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the public Mapbox token (and any other env values) before the app
  // starts. Missing .env is tolerated so the app still boots (the map will be
  // blank until a token is provided) — see README for setup.
  await dotenv.load(fileName: '.env', isOptional: true);

  // Hand the public token to the native Mapbox SDK.
  MapboxOptions.setAccessToken(mapboxPublicToken);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  runApp(const NaviPetApp());
}

class NaviPetApp extends StatelessWidget {
  const NaviPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp.router(
        title: 'NaviPet',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
          fontFamily: 'Plus Jakarta Sans',
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
