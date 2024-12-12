import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rachacontas/models/Debt.dart';
import 'package:rachacontas/models/UserToDebt.dart';
import 'package:get/get.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/screens/edit_user_screen.dart';
import 'package:rachacontas/services/api_service.dart';

class DebtScreen extends StatefulWidget {
  const DebtScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DebtScreenState();
}

class _DebtScreenState extends State<DebtScreen> {
  bool loading = false;
  late Debt debt;

  Future<void> reloadDebt() async {
    setState(() {
      loading = true;
    });
    ApiResponse response = await getIt<ApiService>().getDebt(debt.id!);
    if (response.logOut) {
      Get.snackbar('Login', 'Sua sessão expirou');
      Get.offAllNamed('/login');
      return;
    }

    setState(() {
      debt = Debt.fromJson(response.data);
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        debt = ModalRoute.of(context)!.settings.arguments as Debt;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dívida'),
        actions: [
          BackButton(
            onPressed: () {
              Get.offAllNamed('/');
            },
          ),
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
              InkWell(
                onTap: !debt.isVerified()
                    ? () {
                        Get.showSnackbar(const GetSnackBar(
                          title: 'Falha',
                          message:
                              'Não é possível pagar uma dívida não confirmada',
                          backgroundColor: Colors.red,
                        ));
                      }
                    : (debt.getPendingValue() == 0
                        ? () {
                            Get.showSnackbar(const GetSnackBar(
                                title: 'Falha',
                                message: 'Dívida já paga',
                                backgroundColor: Colors.red));
                          }
                        : () {
                            Get.toNamed('/pay-debt', arguments: debt);
                          }),
                child: Text('Pagar',
                    style: TextStyle(
                        color: !debt.isVerified() || debt.getPendingValue() == 0
                            ? Colors.grey
                            : Colors.green)),
              ),
            ],
          ),
        ),
      ),
      body: loading
          ? const LinearProgressIndicator()
          : ListView(
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
                            Text(debt.name!,
                                style: const TextStyle(fontSize: 24)),
                            Text(debt.description ?? 'Sem descrição'),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(Icons.update),
                          onPressed: () {
                            reloadDebt();
                          },
                        ),
                      ),
                      Positioned(
                          top: 0,
                          right: 0,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  getIt<ApiService>()
                                      .deleteDebt(debt.id!)
                                      .then((value) {
                                    if (value.success) {
                                      Get.snackbar('Dívida',
                                          'Dívida excluída com sucesso');
                                      Get.offAllNamed('/');
                                    } else if (value.logOut) {
                                      Get.snackbar('Login', 'Sessão expirada',
                                          backgroundColor: Colors.grey);
                                      Get.offAllNamed('/login');
                                    } else {
                                      Get.snackbar(
                                          'Dívida', 'Erro ao excluir dívida');
                                    }
                                  });
                                },
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data da dívida'),
                      Text(debt.debtDate ?? 'Sem data'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data máxima para pagamento'),
                      Text(debt.maxPayDate ?? 'Sem data'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text('Valor total'),
                        Text(oCcy.format(debt.totalValue)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Valor pago'),
                        Text(oCcy.format(debt.getPaidValue())),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('Valor pendente'),
                        Text(oCcy.format(debt.getPendingValue()),
                            style: TextStyle(
                                color: debt.getPendingValue() > 0
                                    ? Colors.red
                                    : Colors.green)),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: debt.userToDebt!.length,
                  itemBuilder: (context, index) {
                    final userToDebt = debt.userToDebt![index];
                    return Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(userToDebt.name!),
                                  Text(userToDebt.email!,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                                  userToDebt.relationship == 'payer'
                                      ? Text(
                                          'Valor a pagar: ${oCcy.format(userToDebt.value ?? debt.totalValue)}')
                                      : SizedBox(),
                                  Text(Relationship.getRelationship(
                                      userToDebt.relationship!)),
                                ]),
                            Row(
                              children: [
                                userToDebt.relationship == Relationship.PAYER
                                    ? Column(
                                        children: [
                                          userToDebt.verifiedAt != null
                                              ? const Icon(Icons.check_circle,
                                                  color: Colors.green)
                                              : const Icon(Icons.error,
                                                  color: Colors.red),
                                          Text(
                                              userToDebt.paidValue ==
                                                      (userToDebt.value ??
                                                          debt.totalValue)
                                                  ? 'Pago'
                                                  : userToDebt.verifiedAt !=
                                                          null
                                                      ? 'Confirmado'
                                                      : 'Não confirmado',
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ],
                                      )
                                    : SizedBox(),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: InkWell(
                                      onTap: () {
                                        Get.toNamed('/edit-user',
                                            arguments:
                                                EditUserArgs(debt, userToDebt));
                                      },
                                      child: const Icon(Icons.edit)),
                                )
                              ],
                            )
                          ],
                        ));
                  },
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: debt.proofs!
                          .map((proof) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.dialog(
                                      Dialog(
                                        child: Image.memory(
                                          base64Decode(proof.src!),
                                          height: 600,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.memory(
                                    base64Decode(proof.src!),
                                    height: 200,
                                  ),
                                ),
                              ))
                          .toList()),
                ),
              ],
            ),
    );
  }
}
