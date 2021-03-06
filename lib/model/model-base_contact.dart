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

part of openreception.model;

/**
 * Available types for [BaseContact] objects.
 */
abstract class ContactType {
 static const String human = 'human';
 static const String function = 'function';
 static const String invisible = 'invisible';

 /// Iterable enumerating the different contact types.
 static const Iterable types = const [human, function, invisible];
}

/**
 * A base contact represents a contact outside the context of a reception.
 */
class BaseContact {
  int id = Contact.noID;
  String fullName = '';
  String contactType = '';
  bool enabled = true;

  /**
   * Default empty constructor.
   */
  BaseContact.empty();

  /**
   * Deserializing constructor.
   */
  BaseContact.fromMap(Map map) {
    id = map[Key.contactID];
    fullName = map[Key.fullName];
    contactType = map[Key.contactType];
    enabled = map[Key.enabled];
  }

  Map get asMap => {
    Key.contactID: id,
    Key.fullName: fullName,
    Key.contactType: contactType,
    Key.enabled: enabled
  };

  Map toJson() => this.asMap;
}
