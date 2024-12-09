import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class ProofController extends GetxController {
  final srcController = TextEditingController();
  final typeController = TextEditingController(text: 'receipt');

  Map<String, dynamic> toJson() {
    return {
      'src': srcController.text,
      'type': typeController.text,
    };
  }
}