import 'dart:core';

import 'package:agenda_contatos/models/contact_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactHelper{

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;
  ContactHelper.internal();

  Database _db;
  
  Future<Database> get db async{
    if(_db != null){
      return _db;
    }
    else{
      _db = await initDB();
      return _db;
    }
  }

  Future<Database> initDB() async{
    final dataBasespath = await getDatabasesPath();
    final path = join(dataBasespath, "contacts2.db");

    return await openDatabase(path, version: 1, onCreate: (Database db, int newweVersion) async{
      await db.execute(
        "create table $contactTable($idColumn integer primary key, $nameColumn text, "
        "$emailColumn text, $phoneColumn text, $imgColumn text)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?", whereArgs: [id]);
    if(maps.length>0){
      return Contact.fromMap(maps.first);
    }
    else{
      return null;
    }
  }

  Future<int> deleteContact(int id) async{
    Database dbContact = await db;
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async{
    Database dbContact = await db;
    return await dbContact.update(contactTable, contact.toMap(), 
    where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllcontacts() async{
    Database dbContact = await db;
    List listMap = await dbContact.rawQuery("select * from $contactTable");
    List<Contact> listContact = List();
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  Future<int> getNumbercontacts() async{
    Database dbContact = await db;
    return Sqflite.firstIntValue(await dbContact.rawQuery(
      "select count(*) from $contactTable"));
  }

  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }
}