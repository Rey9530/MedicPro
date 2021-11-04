import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:syncfusion_localizations/syncfusion_localizations.dart';
import 'package:flutter/material.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/services/services.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthServices>( create: (_) => AuthServices() ),
        ChangeNotifierProvider<ExpedientesProvider>( create: (_) => ExpedientesProvider() ),
        ChangeNotifierProvider<CitasProvider>( create: (_) => CitasProvider() ),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          SfGlobalLocalizations.delegate
      ],
      supportedLocales: [
        const Locale('es','ES'),
      ],
      locale: const Locale('es','ES'),
      scaffoldMessengerKey: NotificationsServices.messengerkey,
      debugShowCheckedModeBanner: false,
      title: 'MedicPro',
      initialRoute: 'check', // 'check',
      routes: {
        'login': (_) => LoginApp(),
        'check': (_) => CheckAuthPage(),
        'home':  (_) => NavigatorPage(),
        //'exp_detalle': (_) => ExpedientePerfilPage(),
      },
    );
  }
}
