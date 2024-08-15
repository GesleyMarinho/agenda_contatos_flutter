import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final String contactTable = "contactTable";
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String emailColumn = 'emailColumn';
final String phoneColumn = 'phoneColumn';
final String imgColumn = 'imgColumn';

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    } else {
      _db = await initDb();
      return _db!;
    }
  }

  // initDb() é uma função para iniciar o banco de dados caso  não esteja criado;
  Future<Database> initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'contacts.db');

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      print('Banco de dados criado');
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, "
          "$emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  // metodo para salvar o contato;
  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;

    contact.id = await dbContact.insert(contactTable, contact.toMap());
    print("Contato salvo: ${contact.toString()}");
    return contact;
  }

  //obtendo os dados do contato;
  Future<Contact?> getContact(int id) async {
    Database dbContact = await db;

    List<Map<String, dynamic>> maps = await dbContact.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //Metódo para deletar
  Future<int> deleteContact(int id) async {
    Database dbContact = await db;

    int result = await dbContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
    return result;
  }

  //Metodos para atualizar
  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return dbContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
  }


  //Metodo para listar;
  Future<List<Contact>> getAllContact() async {
    Database dbContact = await db;
    List<Map<String, dynamic>> listMap =
        await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = [];
    for (Map<String, dynamic> m in listMap) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int?> getNumber() async {
    Database dbcontact = await db;

    return Sqflite.firstIntValue(
        await dbcontact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future close() async {
    Database dbcontact = await db;
    dbcontact.close();
  }
}

class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  Contact.fromMap(Map<String, dynamic> map) {
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Contact{id: $id, nome: $name, email: $email, phone: $phone, img: $img}';
  }
}
