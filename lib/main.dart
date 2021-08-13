import 'package:flutter/material.dart';
import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/services/services.dart';
import 'package:provider/provider.dart';

void main() => runApp(AppState());

class AppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
            ChangeNotifierProvider<AuthServices>(create: (_) => AuthServices()),
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: NotificationsServices.messengerkey,
      debugShowCheckedModeBanner: false,
      title: 'MedicPro',
      initialRoute: 'check',
      routes: {
        'login': (_) => LoginApp(),
        'check': (_) => CheckAuthPage(),
        'home': (_) => NavigatorPage(),
      },
    );
  }
}
