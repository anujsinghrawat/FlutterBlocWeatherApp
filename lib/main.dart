import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/Bloc/AuthBloc/auth_bloc.dart';
import 'package:weather/Bloc/InternetBloc/internet_bloc.dart';
import 'package:weather/Bloc/TemperatureUnitsBloc/temperatureunit_bloc.dart';
import 'package:weather/Data/Repository/auth_repository.dart';
import 'package:weather/Data/Repository/weather_repo.dart';
import 'package:weather/Presentations/Screens/signup_screen.dart';
import 'package:weather/Presentations/Screens/welcome_page.dart';
import 'package:weather/Services/notification_service.dart';
import 'package:weather/boxes.dart';
import 'package:weather/firebase_options.dart';
import 'package:weather/Data/Hive/person.dart';

import 'Bloc/CitiesCubit/cities_cubit.dart';
import 'Bloc/WeatherBloc/weather_bloc.dart';
import 'Presentations/Routes/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initializeAwesomeNotifications();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  boxPersons = await Hive.openBox<Person>("personBox");
  runApp(const MyApp());
}

String appGroupId = 'group.weather_app_group';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<WeatherRepository>(
          create: (context) => WeatherRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => WeatherBloc(
              RepositoryProvider.of<WeatherRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => InternetBloc(),
          ),
          BlocProvider(
            create: (context) => CitiesCubit(),
          ),
          BlocProvider(
            create: (context) => TemperatureUnitBloc(),
          ),
        ],
        child: ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (_, child) {
              return MaterialApp(
                title: 'Flutter Demo',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                  useMaterial3: true,
                ),
                home: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasData) {
                      return const WelcomePage();
                    }
                    return const SignUp();
                  },
                ),
                onGenerateRoute: RoutesGenerators.generateRoute,
              );
            }),
      ),
    );
  }
}
