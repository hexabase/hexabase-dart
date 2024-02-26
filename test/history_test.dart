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
  test('Create item history', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    await item.save();
    var history = item.history();
    history.set('comment', 'test');
    await history.save();
    expect(history.id, isNotEmpty);
    await item.delete();
  });
  test('Get item histories', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    await item.save();
    var history1 = item.history();
    history1.set('comment', 'test 1');
    await history1.save();
    expect(history1.id, isNotEmpty);
    var history2 = item.history();
    history2.set('comment', 'test 2');
    await history2.save();
    expect(history2.id, isNotEmpty);
    var histories = await item.histories();
    expect(histories.length, greaterThanOrEqualTo(2));
    await item.delete();
  });

  test('Update item history', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    await item.save();
    var history = item.history();
    var h1 = await item.histories();
    expect(h1.length, 1);
    history.set('comment', 'test');
    await history.save();
    expect(history.id, isNotEmpty);
    history.set('comment', 'test 2');
    await history.save();
    var histories = await item.histories();
    expect(histories.length, 2);
    expect(histories.lastWhereOrNull((h) => h.id == history.id)!.comment,
        'test 2');
    await item.delete();
  });

  test('Delete item history', () async {
    var keys = await loadFile();
    var client = Hexabase.instance;
    var project = await client.currentWorkspace.project(id: keys['project']);
    var datastore = await project.datastore(id: keys['datastore']['main']);
    var item = await datastore.item();
    item.set('test_text_unique', generateNonce());
    await item.save();
    var h1 = await item.histories();
    expect(h1.length, 1);
    await h1[0].delete();
    var history = item.history();
    history.set('comment', 'test');
    await history.save();
    expect(history.id, isNotEmpty);
    history.set('comment', 'test 2');
    await history.save();
    var histories = await item.histories();
    expect(histories.length, 1);
    expect(histories.first.comment, 'test 2');
    await item.delete();
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
