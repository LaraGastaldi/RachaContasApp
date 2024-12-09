import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';

class AddDebtController extends GetxController {
  final addDebtFormKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final valueController = TextEditingController();
  final maxPayDateController = TextEditingController();

  final userController = [];

  final proofController = [];

  bool loading = false;

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    valueController.dispose();
    maxPayDateController.dispose();
    userController.every((element) {
      element.dispose();
      return true;
    });
    super.onClose();
  }

  String? validator(String value) {
    if (value.isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  bool send() {
    if (addDebtFormKey.currentState!.validate()) {
      if (userController.isEmpty) {
        Get.snackbar('Falha', 'Adicione um usuário');
        return false;
      }
      print(userController[0].toJson());
      if (userController.any((element) => element.emailController.text.isEmpty || element.nameController.text.isEmpty)) {
        Get.snackbar('Falha', 'Preencha todas as informações do(s) usuário(s)');
        return false;
      }
      if (proofController.any((element) => element.srcController.text.isEmpty)) {
        Get.snackbar('Falha', 'Todos os comprovantes devem ter uma foto');
        return false;
      }
      eventhub.fire('loading', true);

      Map<String, dynamic> data = {
        'name': nameController.text,
        'description': descriptionController.text,
        'total_value': valueController.text,
        'max_pay_date': maxPayDateController.text,
        'debt_date': DateTime.now().toString(),
        'users': userController.map((e) => e.toJson()).toList(),
        'proofs': proofController.map((e) => e.toJson()).toList(),
      };

      getIt<ApiService>().addDebt(data)
        .then((value) {
          if (value.success) {
            Get.snackbar('Dívida', 'Dívida adicionada com sucesso');
            Get.offAllNamed('/');
          } else if (value.logOut) {
            Get.snackbar('Login', 'Sessão expirada',
                backgroundColor: Colors.grey);
            Get.offAllNamed('/login');
          } else {
            Get.snackbar('Dívida', 'Erro ao adicionar dívida',
                backgroundColor: Colors.redAccent);
          }
        }).whenComplete(() {
          eventhub.fire('loading', false);
        });
      return true;
    }
    Get.snackbar('Falha', 'Preencha todos os campos');
    return false;
  }
}
