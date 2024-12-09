import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';

class RegisterController extends GetxController {
  final registerFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool loading = false;
  AutovalidateMode validateMode = AutovalidateMode.disabled;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  String? validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  void register() {
    if (registerFormKey.currentState!.validate()) {
      validateMode = AutovalidateMode.disabled;
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
            .register(
                nameController.text,
                lastNameController.text,
                emailController.text,
                passwordController.text)
            .then((auth) {
          if (auth.success) {
            Get.snackbar('Registro', 'Conta criada. Faça login.',
                backgroundColor: Colors.greenAccent);
            Get.offAllNamed('/login');
          } else {
            log('Error on register: ${auth.data}');
            Get.snackbar('Registro', 'Credenciais inválidas',
                backgroundColor: Colors.redAccent);
          }
        }).catchError((e) {
          log('Error on register: $e');
          Get.snackbar('Registro', 'Erro no registro');
        }).whenComplete(() {
          eventhub.fire('loading', false);
          loading = false;
        });
      });
    } else {
      validateMode = AutovalidateMode.always;
      eventhub.fire('validateMode', validateMode);
      Get.snackbar('Registro', 'Preencha os campos corretamente',
          backgroundColor: Colors.redAccent);
    }
  }
}
