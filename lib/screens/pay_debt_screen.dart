import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rachacontas/components/proof_alert_component.dart';
import 'package:rachacontas/models/Debt.dart';
import 'package:rachacontas/models/UserToDebt.dart';
import 'package:get/get.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';
import 'package:rachacontas/services/controllers/proof_controller.dart';

class PayDebtScreen extends StatefulWidget {
  const PayDebtScreen({super.key});

  @override
  State<StatefulWidget> createState() => _PayDebtScreenState();
}

class _PayDebtScreenState extends State<PayDebtScreen> {
  bool loading = false;
  bool loadingCamera = false;
  late Future<void> cameraInit;
  final cameraController = CameraController(
      const CameraDescription(
          lensDirection: CameraLensDirection.back,
          name: 'Tirar foto',
          sensorOrientation: 0),
      ResolutionPreset.medium);

  @override
  void initState() {
    eventhub.on('loading', (loading) {
      setState(() {
        this.loading = loading;
      });
    });
    cameraInit = cameraController.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final debt = ModalRoute.of(context)!.settings.arguments as Debt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar dívida'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  getIt<ApiService>().totalPay(debt.id!).then((value) {
                    if (value.success) {
                      Get.snackbar('Sucesso', 'Dívida paga',
                          backgroundColor: Colors.green);
                      Get.offAllNamed('/debt', arguments: debt);
                    } else {
                      Get.snackbar('Falha', 'Erro ao pagar dívida',
                          backgroundColor: Colors.red);
                    }
                  }).catchError((error) {
                    Get.snackbar('Falha', 'Erro ao pagar dívida',
                        backgroundColor: Colors.red);
                  });
                },
                child: const Text('Pagar total',
                    style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.greenAccent.shade200,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text(debt.name!, style: const TextStyle(fontSize: 24)),
                      Text(debt.description ?? 'Sem descrição'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Form(
              child: ListView(
            shrinkWrap: true,
            children: [
              const Text('Usuários'),
              ...debt.userToDebt!
                  .where((user) => user.relationship == Relationship.PAYER)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.name!),
                              Text(e.email!),
                              Text(
                                  'Valor total: ${e.value ?? debt.totalValue}'),
                              Text(
                                  'Valor pendente: ${(e.value ?? debt.totalValue)! - (e.paidValue ?? 0)}'),
                            ],
                          ),
                          const Spacer(),
                          // InkWell(
                          //   onTap: () {
                          //     showDialog(
                          //         context: context,
                          //         builder: (context) {
                          //           return _makePayDialog(
                          //               e: e, debt: debt, context: context);
                          //         });
                          //   },
                          //   child: const Text('Pagar',
                          //       style: TextStyle(color: Colors.green)),
                          // ),
                        ],
                      ),
                    ),
                  ),
            ],
          ))
        ],
      ),
    );
  }

  Widget _makePayDialog({e, debt, context}) {
    final valueController = TextEditingController();
    final proofControllers = [];
    eventhub.on('addProof', (value) {
      proofControllers.add(value['value']);
      setState(() {});
    });
    eventhub.on('removeProof', (value) {
      proofControllers.removeAt(value['index']);
      setState(() {});
    });
    return AlertDialog(
      title: const Text('Confirmação'),
      content: Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextFormFieldRow(
              controller: valueController,
              placeholder: 'Digite o valor',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Campo obrigatório';
                }
                if (double.parse(value) >
                    ((e.value ?? debt.totalValue)! - (e.paidValue ?? 0))) {
                  return 'Valor maior que o pendente';
                }
                return null;
              },
            ),
            Text(
                'Valor máximo: ${(e.value ?? debt.totalValue)! - (e.paidValue ?? 0)}'),
            const Divider(
              height: 10,
              color: Colors.transparent,
            ),
            ElevatedButton(
              onPressed: () {
                // proofControllers.add(ProofController());
                // eventhub.on('proofChanged', (value) {
                //   setState(() {
                //     if (value.value == null) {
                //       proofControllers.removeAt(value.index);
                //     } else {
                //       proofControllers[value.index].srcController.text = value.value;
                //     }
                //   });
                // });
                showDialog(
                    context: context,
                    builder: (context) {
                      return ProofOptionsDialog(
                          proofControllers: proofControllers,
                          cameraController: cameraController, loadingCamera: loadingCamera,
                          setState: setState,
                          cameraInit: cameraInit
                      );
                    });
              },
              child: const Text('Adicionar comprovante'),
            ),
            const Divider(),
            ...proofControllers.map((e) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Image.memory(base64Decode(e.srcController.text)),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        proofControllers.remove(e);
                        setState(() {});
                      },
                      child: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            // getIt<ApiService>()
            //     .payDebt(e.id!, double.parse(valueController.text))
            //     .then((value) {
            //   if (value.success) {
            //     Get.snackbar('Sucesso', 'Dívida paga',
            //         backgroundColor: Colors.green);
            //     Get.offAllNamed('/debt', arguments: debt);
            //   } else {
            //     Get.snackbar('Falha', 'Erro ao pagar dívida',
            //         backgroundColor: Colors.red);
            //   }
            // }).catchError((error) {
            //   Get.snackbar('Falha', 'Erro ao pagar dívida',
            //       backgroundColor: Colors.red);
            // });
          },
          child: const Text('Pagar', style: TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
