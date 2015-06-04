part of openreception.event;

abstract class CalendarEntryState {
  static const String CREATED = 'created';
  static const String UPDATED = 'updated';
  static const String DELETED = 'deleted';
}

class CalendarChange implements Event {

  final DateTime timestamp;

  String get eventName => _Key.calendarChange;

  final int entryID;
  final int contactID;
  final int receptionID;
  final String state;

  CalendarChange (this.entryID, this.contactID, this.receptionID, this.state) :
    this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap {
    Map template = EventTemplate._rootElement(this);

    Map body = {_Key.entryID     : this.entryID,
                _Key.receptionID : this.receptionID,
                _Key.contactID   : this.contactID,
                _Key.state       : this.state};

    template[_Key.calendarChange] = body;

    return template;
  }

  CalendarChange.fromMap (Map map) :
    this.entryID = map[_Key.calendarChange][_Key.entryID],
    this.contactID = map[_Key.calendarChange][_Key.contactID],
    this.receptionID = map[_Key.calendarChange][_Key.receptionID],
    this.state = map[_Key.calendarChange][_Key.state],
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);
}


