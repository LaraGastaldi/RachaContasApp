import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rachacontas/models/Debt.dart';
import 'package:rachacontas/models/UserToDebt.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';
import 'package:rachacontas/services/controllers/user_debt_controller.dart';
import 'package:get/get.dart';

class EditUserScreen extends StatefulWidget {
  EditUserScreen({super.key});

  final userController = Get.put(UserDebtController());

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class EditUserArgs {
  final Debt debt;
  final UserToDebt userToDebt;

  EditUserArgs(this.debt, this.userToDebt);
}

class _EditUserScreenState extends State<EditUserScreen> {
  late Debt debt;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditUserArgs;

    debt = args.debt;
    widget.userController.nameController.text = args.userToDebt.name!;
    widget.userController.emailController.text = args.userToDebt.email!;
    widget.userController.valueController.text =
        args.userToDebt.value.toString();
    widget.userController.relationshipController.text =
        args.userToDebt.relationship!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar usuário'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: widget.userController.userDebtFormKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nome'),
                  controller: widget.userController.nameController,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  controller: widget.userController.emailController,
                ),
                if (args.userToDebt.value != null) ...[
                  CupertinoTextFormFieldRow(
                    placeholder: 'Valor da dívida',
                    controller: widget.userController.valueController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ],
                    padding: const EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.black12,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      return null;
                    },
                  ),
                  const Text(
                      'O valor é opcional se for o único pagador ou se for uma testemunha'),
                ],
                DropdownButton<String>(
                    padding: const EdgeInsets.all(5.0),
                    menuWidth: 200.0,
                    value: widget.userController.relationshipController.text,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    // underline: Container(
                    //   height: 2,
                    //   color: Colors.deepPurpleAccent,
                    // ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        widget.userController.relationshipController.text =
                            value!;
                      });
                    },
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'payer',
                        child: Text('Pagador'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'receiver',
                        child: Text('Credor'),
                      ),
                      DropdownMenuItem<String>(
                          value: 'witness', child: Text('Testemunha'))
                    ]),
                ElevatedButton(
                  onPressed: () {
                    if (widget.userController.userDebtFormKey.currentState!
                        .validate()) {
                      getIt<ApiService>().editUser(args.userToDebt.id!, {
                        'name': widget.userController.nameController.text,
                        'email': widget.userController.emailController.text,
                        'value': widget.userController.valueController.text,
                        'relationship':
                            widget.userController.relationshipController.text
                      }).then((value) {
                        if (value.success) {
                          Get.snackbar(
                              'Usuário', 'Usuário editado com sucesso');
                          debt.userToDebt!.remove(args.userToDebt);
                          debt.userToDebt!.add(UserToDebt(
                              id: args.userToDebt.id,
                              name: widget.userController.nameController.text,
                              email: widget.userController.emailController.text,
                              value: double.tryParse(
                                  widget.userController.valueController.text),
                              relationship: widget.userController
                                  .relationshipController.text));
                          Get.offNamed('/debt', arguments: debt);
                        } else if (value.logOut) {
                          Get.offNamed('/login');
                          Get.snackbar('Login', 'Sessão expirada',
                              backgroundColor: Colors.grey);
                        } else {
                          Get.snackbar('Usuário', 'Erro ao editar usuário');
                        }
                      });
                    }
                  },
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
