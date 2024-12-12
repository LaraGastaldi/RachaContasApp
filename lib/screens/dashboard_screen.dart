import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rachacontas/models/Debt.dart';
import 'package:rachacontas/providers.dart';
import 'package:rachacontas/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  List<Debt> debts = [];
  List<Debt> otherDebts = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();

    getDebts();
  }

  void getDebts() {
    setState(() {
      loading = true;
    });


    getIt<ApiService>().getDebts().then((value) {
      if (value.success) {
        setState(() {
          debts = value.data['own'].map((e) => Debt.fromJson(e)).cast<Debt>().toList();
          otherDebts = value.data['others'].map((e) => Debt.fromJson(e)).cast<Debt>().toList();
        });
      } else if (value.logOut) {
        Get.snackbar('Login', 'Sessão expirada',
            backgroundColor: Colors.grey);
        Get.offAllNamed('/login');
      } else {
        Get.snackbar('Dívidas', 'Erro ao buscar dívidas',
            backgroundColor: Colors.redAccent);
      }
    }).whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas dívidas'),
        actions: [
          IconButton(
              onPressed: () {
                getDebts();
              },
              icon: const Icon(Icons.update)
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: DraggableHome(
        title: const Text("RachaContas"),
        headerWidget: headerWidget(context),
        headerBottomBar: headerBottomBarWidget(),
        body: [
          loading ? const Center(child: CircularProgressIndicator()) :
          debts.isEmpty ? Text('Sem dívidas a mostrar')
          : listView(debts),
        ],
        fullyStretchable: true,
        expandedBody: Container(
          color: Colors.greenAccent,
        ),
        backgroundColor: Colors.white,
        appBarColor: Colors.greenAccent.shade200,
      ),
    );
  }

  Row headerBottomBarWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            Get.toNamed('/add-debt');
          },
          child: Text("Nova dívida"),
        ),
      ],
    );
  }

  Widget headerWidget(BuildContext context) {
    return Container(
      color: Colors.greenAccent.shade200,
      child: Center(),
    );
  }

  ListView listView(List<Debt> debts) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: debts.length,
      shrinkWrap: true,
      itemBuilder: (context, index) =>  Card(
        color: Colors.white70,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(debts[index].name ?? ''),
                    Text(debts[index].description ?? ''),
                    Text('Total: ${oCcy.format(debts[index].totalValue)}'),
                  ],
                ),
              ),
              debts[index].getPendingValue() == 0 ?
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Text('Pago')
                ) :
              (debts[index].isVerified() ?
                Container(
                  decoration: BoxDecoration(
                    color: (debts[index].getPendingValue() ?? 0) > 0 ? Colors.red.shade200 : Colors.green,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Text('Pendente: ${oCcy.format(debts[index].totalValue)}')
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade200,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: Text('Aguardando confirmação')
                )),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  Get.toNamed('/debt', arguments: debts[index]);
                },
              ),
            ],
          )
        )
      ),
    );
  }
}
