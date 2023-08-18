 import 'dart:developer';

import 'package:mongo_dart/mongo_dart.dart';

import 'api.dart';

class MongoDatabase {
  static connect() async{
    var db =await Db.create(baseURL);
    await db.open();
    inspect(db);
    var status =db.serverStatus();
    print(status);
    var collection =db.collection(collactionName);
    var collection2 =db.collection(studentsCol);
  print(collection.find().toList());
  print(collection2.find().toList());
  }
 }