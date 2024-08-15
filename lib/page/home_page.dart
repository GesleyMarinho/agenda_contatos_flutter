import 'dart:io';

import 'package:agenda_contatos_flutter/model/contact_helper.dart';
import 'package:agenda_contatos_flutter/page/criar_contato_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> listContact = [];

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  _getAllContacts() {
    helper.getAllContact().then((list) {
      setState(() {
        listContact = list;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contatos",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            /* botão para  Ordenação será acionado aqui */
              itemBuilder: (context) =>
              <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.orderaz,
                  child: Text("Ordenar A-Z"),
                ),
                const PopupMenuItem<OrderOptions>(
                  value: OrderOptions.orderza,
                  child: Text("Ordenar Z-A"),
                ),
              ],
              onSelected: _orderList,
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: listContact.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      )
      ,
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: listContact[index].img != null &&
                        File(listContact[index].img!).existsSync()
                        ? FileImage(File(listContact[index].img!))
                        : const AssetImage("images/person.png"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listContact[index].name ?? "",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      listContact[index].email ?? "",
                      style: const TextStyle(fontSize: 22.0),
                    ),
                    Text(
                      listContact[index].phone ?? "",
                      style: const TextStyle(fontSize: 22.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        //_showContactPage(contact: listContact[index]);
        _showOptions(context, index);
      },
    );
  }


  // met
  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        listContact.sort((a, b) {
          return a.name?.toLowerCase().compareTo(b.name!.toLowerCase()) ?? 0;
        });
        break;
      case OrderOptions.orderza:
        listContact.sort((a, b) {
          return b.name?.toLowerCase().compareTo(a.name!.toLowerCase()) ?? 0;
        });
        break;
    }
    setState(() {

    });
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () async {
                      // Ação para ligar
                      //launch("Tel:${listContact[index].phone}");
                      final phoneUrl =
                      Uri.parse("tel:${listContact[index].phone}");
                      if (await canLaunchUrl(phoneUrl)) {
                        await launchUrl(phoneUrl);
                      } else {
                        // Exibir uma mensagem de erro ou realizar outra ação
                        print("Não foi possível ligar para o número");
                      }
                    },
                    child: const Text(
                      "Ligar",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Ação para editar

                      Navigator.pop(context);
                      _showContactPage(contact: listContact[index]);
                    },
                    child: const Text(
                      "Editar",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Ação para excluir
                      helper.deleteContact(listContact[index].id!);
                      setState(() {
                        listContact.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text(
                      "Excluir",
                      style: TextStyle(color: Colors.red, fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactPage({Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CriarContatoPage(
              contact: contact,
            ),
      ),
    );

    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
