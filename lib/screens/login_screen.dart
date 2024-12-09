import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';
import 'package:rachacontas/services/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  LoginController loginController = Get.put(LoginController());

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  @override
  void initState() {
    getIt<ApiService>().me().then((auth) {
      if (auth.success) {
        Get.offAllNamed('/home');
      }
    });
    eventhub.on('loading', (loading) {
      setState(() {
        this.loading = loading;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Form(
            key: widget.loginController.loginFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Racha Contas',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 30,
                ),
                CupertinoTextField(
                  controller: widget.loginController.emailController,
                  placeholder: 'Insira seu e-mail',
                  autocorrect: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                  ],
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 30,
                ),
                CupertinoTextField(
                  obscureText: true,
                  controller: widget.loginController.passwordController,
                  placeholder: 'Insira sua senha',
                ),

                const Divider(
                  color: Colors.transparent,
                  height: 30,
                ),
                CupertinoButton(
                    onPressed: loading
                        ? null
                        : () {
                      widget.loginController.login();
                    },
                    color: Colors.green,
                    child: loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    )
                        : const Text('Login'),
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 40,
                ),
                InkWell(
                  onTap: () {
                    Get.toNamed('/register');
                  },
                  child: const Text('Não tem uma conta? Cadastre-se', style: TextStyle(color: Colors.blue),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
