import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/contact_helper.dart';

class CriarContatoPage extends StatefulWidget {
  final Contact? contact;

  CriarContatoPage({this.contact});

  @override
  _CriarContatoPageState createState() => _CriarContatoPageState();
}

class _CriarContatoPageState extends State<CriarContatoPage> {
  bool _userEdit = false;
  late Contact _editedContact;

  final _nomeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nomeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.contact == null) {
        _editedContact = Contact();
      } else {
        _editedContact = Contact.fromMap(widget.contact!.toMap());
        _nomeController.text = _editedContact.name!;
        _emailController.text = _editedContact.email!;
        _phoneController.text = _editedContact.phone!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _editedContact.name ?? "Novo Contato",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null &&
                _editedContact.name!.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nomeFocus);
            }
          },
          backgroundColor: Colors.red,
          child: const Icon(Icons.save, color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 160.0,
                  height: 160.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null
                          ? FileImage(File(_editedContact.img!))
                          : const AssetImage("images/person.png"),
                    ),
                  ),
                ),
                onTap: () {
                  _pickImage(context);
                },
              ),
              TextField(
                controller: _nomeController,
                focusNode: _nomeFocus,
                decoration: const InputDecoration(labelText: "Nome "),
                onChanged: (text) {
                  _userEdit = true;
                  setState(() {
                    _editedContact.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email "),
                onChanged: (text) {
                  _userEdit = true;
                  _editedContact.email = text;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Telefone "),
                onChanged: (text) {
                  _userEdit = true;
                  _editedContact.phone = text;
                },
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final source = await _showPickerDialog(context);

    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _editedContact.img = pickedFile.path;
        });
      }
    }
  }

  Future<ImageSource?> _showPickerDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Escolha a fonte da imagem'),
          actions: <Widget>[
            TextButton(
              child: const Text('Câmera'),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            TextButton(
              child: const Text('Galeria'),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _requestPop() {
    if (_userEdit) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Descarta alteraçãoes ?"),
            content: Text("Se sair alterações serão perdidas"),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Centraliza os botões
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Cor de fundo laranja
                    ),
                    child: const Text(
                      "Não",
                      style: TextStyle(color: Colors.black), // Texto preto
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10), // Espaço entre os botões
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Cor de fundo vermelha
                    ),
                    child: const Text(
                      "Sim",
                      style: TextStyle(color: Colors.white), // Texto branco
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
