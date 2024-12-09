import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/controllers/register_controller.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  RegisterController registerController = Get.put(RegisterController());

  @override
  State<StatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool loading = false;
  AutovalidateMode validateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    eventhub.on('loading', (loading) {
      setState(() {
        this.loading = loading;
      });
    });
    eventhub.on('validateMode', (validateMode) {
      this.validateMode = validateMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Form(
            autovalidateMode: validateMode,
            key: widget.registerController.registerFormKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  const Text(
                    'Registrar',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  CupertinoFormSection.insetGrouped(
                    footer: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: CupertinoButton(
                          onPressed: loading
                              ? null
                              : () {
                                  widget.registerController.register();
                                },
                          color: Colors.green,
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(),
                                )
                              : const Text('Criar conta'),
                        ),
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    children: [
                      CupertinoTextFormFieldRow(
                        placeholder: 'Primeiro nome',
                        controller: widget.registerController.nameController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        placeholder: 'Sobrenome',
                        controller:
                            widget.registerController.lastNameController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        placeholder: 'E-mail',
                        controller: widget.registerController.emailController,
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (RegExp(r'[a-zA-Z_\-0-9\.]*?@'
                          r'[a-zA-Z_\-0-9\.]*?\.[a-zA-Z_\-0-9]*')
                              .allMatches(value)
                              .isEmpty) {
                            return 'E-mail inválido';
                          }
                          return null;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        placeholder: 'Senha',
                        obscureText: true,
                        controller:
                            widget.registerController.passwordController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          return null;
                        },
                      ),
                      CupertinoTextFormFieldRow(
                        placeholder: 'Confirmar senha',
                        obscureText: true,
                        controller:
                            widget.registerController.confirmPasswordController,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Campo obrigatório';
                          }
                          if (value !=
                              widget
                                  .registerController.passwordController.text) {
                            return 'Senhas não conferem';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
