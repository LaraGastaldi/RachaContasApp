import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/controllers/proof_controller.dart';

class ProofOptionsDialog extends StatefulWidget {
  final List<dynamic> proofControllers;
  final CameraController cameraController;
  bool loadingCamera;
  final Function setState;
  final Future<void> cameraInit;

  ProofOptionsDialog(
      {super.key,
      required this.proofControllers,
      required this.cameraController,
      required this.loadingCamera,
      required this.setState,
      required this.cameraInit});

  @override
  State<StatefulWidget> createState() => _ProofOptionsDialogState();
}

class _ProofOptionsDialogState extends State<ProofOptionsDialog> {
  @override
  Widget build(BuildContext context) {
    eventhub.on('addProof', (value) {
      widget.proofControllers.add(value['value']);
      setState(() {});
    });
    eventhub.on('proofRemove', (value) {
      widget.proofControllers.removeAt(value['index']);
      setState(() {});
    });
    return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            FutureBuilder(
                future: widget.cameraInit,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return takeProofPicture(
                                      cameraController: widget.cameraController,
                                      loadingCamera: widget.loadingCamera,
                                      setState: () {
                                        setState(() {
                                          widget.loadingCamera = !widget.loadingCamera;
                                        });
                                      });
                                });
                          },
                          child: Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo),
                                Text('Adicionar foto')
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(right: 10.0),
                      //   child: GestureDetector(
                      //     onTap: () {
                      //
                      //     },
                      //     child: Container(
                      //       width: 100.0,
                      //       height: 100.0,
                      //       decoration: BoxDecoration(
                      //         color: Colors.black12,
                      //         borderRadius: BorderRadius.circular(8.0),
                      //       ),
                      //       child: const Column(
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           Icon(Icons.image),
                      //           Text('Selecionar foto')
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  );
                }),
            const Divider(),
            ListView(
              shrinkWrap: true,
              children: widget.proofControllers.map((e) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      e.srcController.text.isEmpty
                          ? const Text('Sem foto')
                          :
                      Image.memory(base64Decode(e.srcController.text), width: 150,),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          widget.proofControllers.remove(e);
                          eventhub.fire('proofChanged', {
                            'index': widget.proofControllers.indexOf(e),
                            'value': null
                          });
                          setState(() {});
                        },
                        child: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
          ])
        ));
  }

}


Dialog takeProofPicture(
    {
    required CameraController cameraController,
    required bool loadingCamera,
    required Function setState}) {
  return Dialog(
      child: Column(
    children: [
      CameraPreview(cameraController),
      ElevatedButton(
          onPressed: loadingCamera
              ? null
              : () {
                  loadingCamera = true;
                  setState();
                  cameraController.takePicture().then((value) {
                    value.readAsBytes().then((val) {
                      final base64 = base64Encode(val);
                      final controller = ProofController();
                      controller.srcController.text = base64;
                      controller.typeController.text = 'invoice';

                      eventhub.fire('addProof', {
                        'value': controller
                      });

                      setState();
                      Get.back();
                      Get.back();
                      Get.showSnackbar(const GetSnackBar(
                          title: 'Sucesso',
                          message: 'Foto tirada com sucesso', backgroundColor: Colors.grey,));
                    }).catchError((e) {
                      Get.showSnackbar(const GetSnackBar(
                          title: 'Erro', message: 'Erro ao tirar a foto'));
                    }).whenComplete(() {
                      loadingCamera = false;
                      setState();
                    });
                  }).catchError((e) {
                    Get.showSnackbar(const GetSnackBar(
                        title: 'Erro', message: 'Erro ao tirar a foto'));
                  });
                },
          child: const Text('Tirar foto'))
    ],
  ));
}
