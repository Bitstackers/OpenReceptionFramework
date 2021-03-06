/*                  This file is part of OpenReception
                   Copyright (C) 2015-, BitStackers K/S

  This is free software;  you can redistribute it and/or modify it
  under terms of the  GNU General Public License  as published by the
  Free Software  Foundation;  either version 3,  or (at your  option) any
  later version. This software is distributed in the hope that it will be
  useful, but WITHOUT ANY WARRANTY;  without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  You should have received a copy of the GNU General Public License along with
  this program; see the file COPYING3. If not, see http://www.gnu.org/licenses.
*/

part of openreception.model.dialplan;

class Notify extends Action {

  final String eventName;

  const Notify (this.eventName);

  static Notify parse(String buffer) {
    var buf = consumeKey(buffer.trimLeft(), Key.notify).trimLeft();

    var consumed = consumeWord(buf);

    String eventName = consumed.iden;
    if(eventName.isEmpty) {
      throw new FormatException('${consumed.iden} is empty', buffer);
    }

    return new Notify(eventName);

  }

  String toJson() => '${Key.notify} $eventName';
}
