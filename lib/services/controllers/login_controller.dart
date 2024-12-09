import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';

class LoginController extends GetxController {
  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validator(String value) {
    if (value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void login() {
    if (loginFormKey.currentState!.validate()) {
      eventhub.fire('loading', true);
      loading = true;
      InternetConnection().hasInternetAccess.then((val) {
        if (!val) {
          Get.snackbar('Login', 'Sem conexão com a internet',
              backgroundColor: Colors.redAccent);
          eventhub.fire('loading', false);
          loading = false;
          return;
        }
        getIt<ApiService>()
            .login(emailController.text, passwordController.text)
            .then((auth) {
          if (auth.success) {
            Get.snackbar('Login', 'Logado com sucesso',
                backgroundColor: Colors.greenAccent);
            Get.offAllNamed('/home');
          } else {
            log('Error on login: ${auth.data}');
            Get.snackbar('Login', 'Credenciais incorretas',
                backgroundColor: Colors.redAccent);
          }
        }).catchError((e) {
          log('Error on login: $e');
          Get.snackbar('Login', 'Erro no login');
        }).whenComplete(() {
          eventhub.fire('loading', false);
          loading = false;
        });
      });
    } else {
      Get.snackbar('Login', 'Preencha os campos corretamente',
          backgroundColor: Colors.redAccent);
    }
  }
}
