import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:hexabase/hexabase.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:hexabase/src/file.dart';
import 'package:mime/mime.dart';

void main() {
  dynamic loadFile() async {
    var path = 'test/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    return json.decode(str);
  }

  setUp(() async {
    var keys = await loadFile();
    var client = Hexabase();
    await client.login(keys['email'], keys['password']);
  });
  test('Create item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var item = datastore.item();
    item.set('name', 'スイカ').set('price', 100);
    await item.save();
    item.set('price', 110).set('salesDate', DateTime.now());
    await item.save();
    await item.delete();
  });
  test('Create item with image', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var item = datastore.item();
    item.set('name', 'スイカ').set('price', 120);
    var filePath = './test/test.png';
    var file = HexabaseFile(
        name: basename(filePath), contentType: lookupMimeType(filePath));
    file.data = File(filePath).readAsBytesSync();
    item.set('picture', file);
    await item.save();
    var pictures = item.get('picture') as List<HexabaseFile>;
    var data = await pictures[0].download();
    expect(listEquals(data, file.data), isTrue);
    item.set('price', 110).set('salesDate', DateTime.now());
    await item.save();
    await pictures[0].delete();
    await item.delete();
  });
  test('Create item with images', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var item = datastore.item();
    item.set('name', 'スイカ').set('price', 120);
    var filePaths = ['./test/test.png', './test/test2.png'];
    for (var filePath in filePaths) {
      var file = HexabaseFile(
          name: basename(filePath), contentType: lookupMimeType(filePath));
      file.data = File(filePath).readAsBytesSync();
      item.add('picture', file);
    }
    await item.save();
    await item.getDetail();
    var pictures = item.get('picture') as List<dynamic>;
    var picture = pictures[0] as HexabaseFile;
    var data = await picture.download();
    item.set('price', 110).set('salesDate', DateTime.now());
    await item.save();
    await item.delete();
  });

  test('Delete old items', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var query = datastore.query();
    query.equalTo('price', 120).per(100);
    var items = await datastore.items(query: query);
    for (var item in items) {
      await item.delete();
    }
  });
  test('Change item status', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var item = datastore.item();
    item.set('name', 'スイカ').set('price', 100);
    await item.save();
    print(item.actions().map((e) => e.name));
    item.action('startReservation').set('price', 110);
    await item.save();
    print(item.actions().map((e) => e.name));
    await item.delete();
  });

  test('Subscribe item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = client.project(id: keys['project']);
    var datastore = project.datastore(id: keys['datastore']);
    var items = await datastore.items();
    var item = items.first;
    item.subscribe((event) {
      print(event);
    });
    await new Future.delayed(new Duration(seconds: 120));
  }, timeout: Timeout(Duration(minutes: 2)));
}
