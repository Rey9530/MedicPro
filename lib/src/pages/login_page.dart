import 'package:flutter/material.dart';
import 'package:medicpro/src/services/auth_service.dart';
import 'package:medicpro/src/services/services.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medicpro/src/providers/providers.dart';
import 'package:medicpro/src/themes/theme.dart';
import 'package:medicpro/src/ui/input_decorations.dart';

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: temaApp.primaryColor,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<LoginFormProvider>(create: (_) => LoginFormProvider())
          ],
          child: Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    _HeaderLogin(),
                    _FormLogin(),
                  ],
                ),
                _ProgressBottom()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBottom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final mediaSize = MediaQuery.of(context).size;
    return (loginForm.isLoadin)
        ? Positioned(
            bottom: 0,
            child: Container(
              width: mediaSize.width*0.07,
              height: mediaSize.width*0.07,
              margin: EdgeInsets.symmetric(horizontal: mediaSize.width*0.46),
              child: CircularProgressIndicator(color: temaApp.primaryColor),
            ),
          )
        : Container();
  }
}

class _FormLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginForm = Provider.of<LoginFormProvider>(context);
    final mediaSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: (!loginForm.isLoadin) ? mediaSize.height * 0.46 : mediaSize.height * 0.60,
      // color: Colors.red,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: mediaSize.width * 0.08),
        child: Form(
          key: loginForm.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(height: 30),
              Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: temaApp.primaryColor,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                initialValue: "",
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                  hintText: 'Usuario',
                  labelText: 'Usuario',
                  prefixIcon: FontAwesomeIcons.user,
                ),
                onChanged: (value) => loginForm.usuario = value,
                validator: (value) {
                  if (value.toString().length > 4) {
                    return null;
                  } else {
                    return "Usuario Invalido";
                  }
                },
              ),
              SizedBox(height: mediaSize.height * 0.03),
              TextFormField(
                initialValue: "",
                obscureText: true,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecorations.authInputDecoration(
                  hintText: '****',
                  labelText: 'Clave',
                  prefixIcon: FontAwesomeIcons.key,
                ),
                onChanged: (value) => loginForm.password = value,
                validator: (value) {
                  if (value.toString().length >= 4) {
                    return null;
                  } else {
                    return "Clave invalida";
                  }
                },
              ),
              SizedBox(height: mediaSize.height * 0.03),
              MaterialButton(
                disabledColor: Colors.transparent,
                elevation: 0,
                child: (!loginForm.isLoadin)
                    ? Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Text(
                          'Iniciar Sesion',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ))
                    : Container(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                color: temaApp.primaryColor,
                onPressed: loginForm.isLoadin
                    ? null
                    : () async {
                        if (!loginForm.isValiForm()) return;
                        FocusScope.of(context).unfocus();
                        loginForm.isLoadin = true;
                        //await Future.delayed(Duration(seconds: 2));
                        
                        final authservice = Provider.of<AuthServices>(context, listen: false);
                        final String? errorData = await authservice.login(loginForm.usuario, loginForm.password);
                        
                        if (errorData == null) {
                          Navigator.pushReplacementNamed(context, 'home');
                        } else {
                          NotificationsServices.showSnackbar(errorData); 
                        loginForm.isLoadin = false;
                        } 
                      },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: mediaSize.height * 0.4,
      decoration: BoxDecoration(
        color: temaApp.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(100),
        ),
      ),
      child: Center(
        child: Container(
          height: 125,
          child: Image(
            image: AssetImage("assets/imgs/medicpro_blanco.png"),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
