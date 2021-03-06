/*                  This file is part of OpenReception
                   Copyright (C) 2014-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.test;

testModelUser() {
  group('Model.User', () {
    test('serialization', ModelUser.serialization);

    test('deserialization', ModelUser.deserialization);

    test('buildObject', ModelUser.buildObject);
  });
}

abstract class ModelUser {
  static void serialization() {
    Model.User builtObject = buildObject();
    String serializedString = JSON.encode(builtObject);

    expect(serializedString, isNotEmpty);
    expect(serializedString, isNotNull);
  }

  static void deserialization() {
    Model.User builtObject = buildObject();
    String serializedString = JSON.encode(builtObject);
    Model.User deserializedObject =
        new Model.User.fromMap(JSON.decode(serializedString));

    expect(builtObject.id, equals(deserializedObject.id));
    expect(builtObject.address, equals(deserializedObject.address));
    expect(builtObject.googleAppcode, equals(deserializedObject.googleAppcode));
    expect(
        builtObject.googleUsername, equals(deserializedObject.googleUsername));
    expect(builtObject.name, equals(deserializedObject.name));
    expect(builtObject.peer, equals(deserializedObject.peer));
  }

  static Model.User buildObject() {
    final int userID = 2;
    final String address = 'golden@fish.net';
    final String gmail = 'golden@sea-mail.net';
    final String appcode = 'buford';
    final String name = 'Biff, the gold fish';
    final String peer = 'Hidden underneath';
    final String picture = 'too_revealing.png';

    Model.User builtObject = new Model.User.empty()
      ..id = userID
      ..address = address
      ..googleUsername = gmail
      ..googleAppcode = appcode
      ..name = name
      ..peer = peer
      ..portrait = picture;

    expect(builtObject.id, equals(userID));
    expect(builtObject.address, equals(address));
    expect(builtObject.googleAppcode, equals(appcode));
    expect(builtObject.googleUsername, equals(gmail));
    expect(builtObject.name, equals(name));
    expect(builtObject.peer, equals(peer));
    expect(builtObject.portrait, equals(picture));

    return builtObject;
  }
}
