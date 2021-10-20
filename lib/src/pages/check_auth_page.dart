import 'package:flutter/material.dart';
import 'package:medicpro/src/pages/pages.dart'; 
import 'package:provider/provider.dart';
// import 'package:medicpro/src/pages/pages.dart';
import 'package:medicpro/src/services/services.dart'; 
 

class CheckAuthPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) { 
    final authServices = Provider.of<AuthServices>( context, listen: false ); 
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: authServices.readToken(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            
            if ( !snapshot.hasData )            
              return SplashPage();

            if ( snapshot.data == '' ) {
              Future.microtask(() { 
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: ( _, __ , ___ ) => LoginApp(),
                  transitionDuration: Duration( seconds: 0)
                  )
                ); 
              }); 
            } else { 
              Future.microtask(() { 
                Navigator.pushReplacement(context, PageRouteBuilder(
                  pageBuilder: ( _, __ , ___ ) => NavigatorPage(),
                  transitionDuration: Duration( seconds: 0)
                  )
                ); 
              });
            } 
            return SplashPage(); 
          },
        ),
     ),
   );
  }
}