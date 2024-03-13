import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:hexabase/hexabase.dart';
import 'package:hexabase/src/field_option.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:hexabase/src/file.dart';
import 'package:mime/mime.dart';
import 'dart:math';

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
    await client.setWorkspace(keys['workspace']);
  });
  test('Create item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    await item.save();
    await item.delete();
  });

  test('Get item for check value', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item(id: keys['item']);

    var title = item.get('title');
    expect(title is String, isTrue);

    var realatedKey = item.get('related_key');
    expect(realatedKey is String, isTrue);

    var testText = item.get('test_text');
    expect(testText is String, isTrue);

    var testTextUnique = item.get('test_text_unique');
    expect(testTextUnique is String, isTrue);

    var testTextarea = item.get('test_textarea');
    expect(testTextarea is String, isTrue);

    var testSelect = item.get('test_select');
    expect(testSelect is HexabaseFieldOption, isTrue);
    expect(testSelect.value is String, isTrue);

    var testRadio = item.get('test_radio');
    expect(testRadio is HexabaseFieldOption, isTrue);
    expect(testRadio.value is String, isTrue);

    var testCheckbox = item.get('test_checkbox');
    expect(testCheckbox is List, isTrue);
    expect(testCheckbox[0] is HexabaseFieldOption, isTrue);
    expect(testCheckbox[0].value is String, isTrue);

    var testAutonumber = item.get('test_autonum');
    expect(testAutonumber is String, isTrue);

    var testNumber = item.get('test_number');
    expect(testNumber is int, isTrue);

    var testDatetime = item.get('test_datetime');
    expect(testDatetime is DateTime, isTrue);

    var testFile = item.get('test_file');
    expect(testFile is List, isTrue);
    expect(testFile[0] is HexabaseFile, isTrue);

    var testUsers = item.get('test_users');
    expect(testUsers is List, isTrue);
    expect(testUsers[0] is HexabaseUser, isTrue);

    var testDslookup = item.get('test_dslookup');
    expect(testDslookup is HexabaseItem, isTrue);
    expect(testDslookup.datastore is HexabaseDatastore, isTrue);

    var testDslookup2 = item.get('test_dslookup2');
    expect(testDslookup2 is HexabaseItem, isTrue);
    expect(testDslookup2.datastore is HexabaseDatastore, isTrue);
  });

  test('Set item to wrong value', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    try {
      item.set('name', 100); // No field name
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    try {
      item.set('test_text', 100); // Wrong type
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    try {
      item.set('test_number', 'test_number'); // Number
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    try {
      item.set('test_autonum', 'test_text_unique'); // Wrong type
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    try {
      item.set('test_autonum', 'test_text_unique'); // Wrong type
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    try {
      item.set('test_datetime', 'test_text_unique'); // Wrong type
      expect(false, isTrue);
    } catch (e) {
      expect(e is Exception, isTrue);
    }
    item.set('test_datetime', "2020-01-01 00:00:00");
    var d = item.get<DateTime>('test_datetime');
    expect(d is DateTime, isTrue);
  });
  test('Set select to item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    var field = await datastore.field('test_select');
    item.set('test_select', field.options.first);
    await item.save();
    expect(item.id, isNot(''));
    await item.delete();
  });
  test('Set multiple to item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    var field = await datastore.field('test_checkbox');
    var options = field.options;
    var values = [options[0], options[1]].map((o) => o!.value).toList();
    item.set('test_checkbox', [options[0], options[1]]);
    await item.save();
    expect(item.id, isNot(''));
    var selected = item.get<List<HexabaseFieldOption?>>('test_checkbox');
    await item.delete();
    expect(selected.map((h) => (h as HexabaseFieldOption).value), values);
  });
  test('Create item with image', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    var filePath = './test/test.png';
    var file = await item.file();
    file.sets({
      'name': basename(filePath),
      'contentType': lookupMimeType(filePath) ?? "application/octet-stream",
      'data': File(filePath).readAsBytesSync()
    });
    item.set('test_file', [file]);
    await item.save();
    var pictures = item.get<List<HexabaseFile>>('test_file');
    var data = await pictures[0].download();
    expect(listEquals(data, file.data), isTrue);
    item.set('test_number', 110).set('test_datetime', DateTime.now());
    await item.save();
    await pictures[0].delete();
    await item.delete();
  });
  test('Create item with images', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce()).set('test_number', 120);
    var filePaths = ['./test/test.png', './test/test2.png'];
    for (var filePath in filePaths) {
      var file = await item.file();
      file.sets({
        'name': basename(filePath),
        'contentType': lookupMimeType(filePath) ?? "application/octet-stream",
        'data': File(filePath).readAsBytesSync()
      });
      item.add('test_file', file);
    }
    await item.save();
    var pictures = item.get<List<HexabaseFile>>('test_file');
    expect(pictures.length == 2, true);
    var picture = pictures.first;
    expect(picture.name == 'test.png', true);
    var data = await picture.download();
    expect(listEquals(data, File(filePaths[0]).readAsBytesSync()), true);
    item.set('test_number', 110).set('test_datetime', DateTime.now());
    await item.save();
    await item.delete();
  });

  test('Delete old items', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var query = datastore.query();
    query.equalTo('price', 120).per(100);
    var items = await datastore.items(query: query);
    for (var item in items) {
      await item.delete();
    }
  });

  test('Get linked item', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var query = datastore.query();
    query
        .per(100)
        .include(true)
        .link(true)
        .number(true)
        .displayId(true)
        .fieldId(true);

    var items = await datastore.items(query: query);
    var ary = items.where((item) {
      var val = item.get('test_dslookup');
      return val is HexabaseItem;
    }).toList();
    for (var element in ary) {
      expect(element.get('test_dslookup') is HexabaseItem, isTrue);
    }
  });

  test('Change item status', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('name', 'スイカ').set('price', 100);
    await item.save();
    print((await item.actions()).map((e) => e.name));
    item.action('startReservation').set('price', 110);
    await item.save();
    print((await item.actions()).map((e) => e.name));
    await item.delete();
  });
  test('Subscribe item', () async {
    var client = Hexabase.instance;
    await client.setWorkspace('644f6e5ab30d853869ec919f');
    var project =
        await client.currentWorkspace.project(id: '650a30501222568b1ae7a2c2');
    var datastore = await project.datastore(id: '655af47f12587163f1dd3b06');
    var items = await datastore.items();
    var item = items.first;
    var message = 'Hello';
    var actionName = 'update';
    item.subscribe(actionName, (itemSubscription) {
      print("subscribed");
      expect(itemSubscription.comment, message);
      expect(itemSubscription.item.id, item.id);
      item.unsubscribe(actionName);
    });
    var history = item.history();
    history.set('comment', message);
    await history.save();
    expect(history.id, isNot(''));
    await Future.delayed(const Duration(seconds: 20));
  });
}

String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  final randomStr =
      List.generate(length, (_) => charset[random.nextInt(charset.length)])
          .join();
  return randomStr;
}
