import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:hexabase/hexabase.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:hexabase/src/file.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  dynamic loadFile() async {
    var path = 'test/keys.json';
    var file = File('../$path');
    var str = (await file.exists())
        ? await file.readAsString()
        : await File('./$path').readAsString();
    return json.decode(str);
  }

  test('User login', () async {
    var keys = await loadFile();
    var client = Hexabase();
    await client.login(keys['email'], keys['password']);
    expect(client.token, isNotNull);
  });

  test('User login and save persistence', () async {
    var keys = await loadFile();
    var client = Hexabase();
    SharedPreferences.setMockInitialValues({});
    client.persistence = Hexabase.persistenceLocal;
    await client.login(keys['email'], keys['password']);
    expect(client.token, isNotNull);
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    expect(token, isNotNull);
    expect(token, client.token);
  });
  test('User logout', () async {
    var keys = await loadFile();
    var client = Hexabase();
    SharedPreferences.setMockInitialValues({});
    client.persistence = Hexabase.persistenceLocal;
    await client.login(keys['email'], keys['password']);
    expect(client.token, isNotNull);
    await client.logout();
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');
    expect(token, isNull);
  });

  test('Check login status', () async {
    var keys = await loadFile();
    var client = Hexabase();
    await client.login(keys['email'], keys['password']);
    var bol = await client.isLogin();
    expect(bol, isTrue);
    client.token = "${client.token}a";
    bol = await client.isLogin();
    expect(bol, isFalse);
  });
}
