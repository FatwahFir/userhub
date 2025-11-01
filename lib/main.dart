import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/di/injector.dart';
import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  HydratedBloc.storage = storage;

  final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api/v1';

  await initDI(baseUrl);

  final authBloc = sl<AuthBloc>()..add(const AuthCheckStatus());

  final GoRouter router = AppRouter.build(authBloc);

  runApp(MyApp(
    router: router,
    authBloc: authBloc,
  ));
}

class MyApp extends StatelessWidget {
  final GoRouter router;
  final AuthBloc authBloc;

  const MyApp({super.key, required this.router, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: authBloc,
      child: MaterialApp.router(
        title: 'UserHub',
        debugShowCheckedModeBanner: false,
        theme: appTheme(context),
        routerConfig: router,
      ),
    );
  }
}
