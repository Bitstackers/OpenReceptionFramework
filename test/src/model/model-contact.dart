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

testModelContact() {
  group('Model.Contact', () {
    test('deserialization', ModelContact.deserialization);

    test('serialization', ModelContact.serialization);

    test('Model.Contact buildObject', ModelContact.buildObject);
  });
}

abstract class ModelContact {
  static void serialization() {
    Model.Contact builtObject = buildObject();
    String serializedObject = JSON.encode(builtObject);

    expect(serializedObject, isNotNull);
    expect(serializedObject, isNotEmpty);
  }

  static void deserialization() {
    Model.Contact builtObject = buildObject();
    Model.Contact deserializedObject =
        new Model.Contact.fromMap(JSON.decode(JSON.encode(builtObject)));

    expect(builtObject.receptionID, equals(deserializedObject.receptionID));
    expect(builtObject.ID, equals(deserializedObject.ID));
    expect(builtObject.enabled, equals(deserializedObject.enabled));
    expect(builtObject.fullName, equals(deserializedObject.fullName));
    expect(builtObject.contactType, equals(deserializedObject.contactType));

    {
      Iterable<Map> lhsPn =
          builtObject.phones.map((Model.PhoneNumber pn) => pn.asMap);
      Iterable<Map> rhsPn =
          deserializedObject.phones.map((Model.PhoneNumber pn) => pn.asMap);

      expect(lhsPn, equals(rhsPn));
    }

    expect(
        builtObject.backupContacts, equals(deserializedObject.backupContacts));
    expect(builtObject.departments, equals(deserializedObject.departments));
    expect(
        builtObject.emailaddresses, equals(deserializedObject.emailaddresses));
    expect(builtObject.handling, equals(deserializedObject.handling));
    expect(builtObject.infos, equals(deserializedObject.infos));
    expect(builtObject.statusEmail, equals(deserializedObject.statusEmail));
    expect(builtObject.titles, equals(deserializedObject.titles));
    expect(builtObject.relations, equals(deserializedObject.relations));
    expect(builtObject.responsibilities,
        equals(deserializedObject.responsibilities));
    expect(builtObject.tags, equals(deserializedObject.tags));
    expect(builtObject.workhours, equals(deserializedObject.workhours));
    expect(builtObject.messagePrerequisites,
        equals(deserializedObject.messagePrerequisites));
    expect(builtObject.whenWhats, equals(deserializedObject.whenWhats));
  }

  static Model.Contact buildObject() {
    final int receptionID = 2;
    final int contactID = 2;
    final bool enabled = true;
    final bool statusEmail = false;
    final String fullName = 'Biff, the goldfish';
    final String contactType = 'Goldfish';
    final List<Model.PhoneNumber> pn = [
      new Model.PhoneNumber.empty()
        ..billing_type = 'waterline'
        ..confidential = true
        ..description = 'Fluid connection'
        ..tags = ['Gulping sound', 'Silence']
        ..type = 'Very mobile'
        ..endpoint = '-0045 32112345'
    ];

    final List<String> backupContacts = ['Buford'];
    final List<String> departments = ['Fish school', 'Clowning'];
    final List<String> emailaddresses = ['scaly@nibble.bits'];
    final List<String> handling = ['Avoid fishing rods, please'];
    final List<String> infos = ['He\'s a fish, what more do you need to know?'];
    final List<String> titles = ['GOLD-fish'];
    final List<String> relations = ['Yo\' mamma'];
    final List<String> responsibilities = ['Swimming around', 'Nibbling'];
    final List<String> tags = ['Fish', 'Gold', 'Athlete'];
    final List<String> workhours = ['Quite frankly; never'];
    final List<String> messagePrerequisites = ['[fishcode]'];

    final List<Model.WhenWhat> whenWhats = [
      new Model.WhenWhat('man-fri 08:00-09:00', 'Meeting'),
      new Model.WhenWhat('wed 12:00-12:30', 'lunch')
    ];

    Model.Contact builtObject = new Model.Contact.empty()
      ..receptionID = receptionID
      ..ID = contactID
      ..statusEmail = statusEmail
      ..enabled = enabled
      ..fullName = fullName
      ..contactType = contactType
      ..phones.addAll(pn)
      ..backupContacts = backupContacts
      ..departments = departments
      ..emailaddresses = emailaddresses
      ..handling = handling
      ..infos = infos
      ..titles = titles
      ..relations.addAll(relations)
      ..responsibilities = responsibilities
      ..tags = tags
      ..workhours = workhours
      ..messagePrerequisites = messagePrerequisites
      ..whenWhats = whenWhats;

    expect(builtObject.receptionID, equals(receptionID));
    expect(builtObject.ID, equals(contactID));
    expect(builtObject.enabled, equals(enabled));
    expect(builtObject.statusEmail, equals(statusEmail));
    expect(builtObject.fullName, equals(fullName));
    expect(builtObject.contactType, equals(contactType));
    expect(builtObject.phones, equals(pn));
    expect(builtObject.backupContacts, equals(backupContacts));
    expect(builtObject.departments, equals(departments));
    expect(builtObject.emailaddresses, equals(emailaddresses));
    expect(builtObject.handling, equals(handling));
    expect(builtObject.infos, equals(infos));
    expect(builtObject.titles, equals(titles));
    expect(builtObject.relations, equals(relations));
    expect(builtObject.responsibilities, equals(responsibilities));
    expect(builtObject.tags, equals(tags));
    expect(builtObject.workhours, equals(workhours));
    expect(builtObject.messagePrerequisites, equals(messagePrerequisites));
    expect(builtObject.whenWhats, equals(whenWhats));

    return builtObject;
  }
}
