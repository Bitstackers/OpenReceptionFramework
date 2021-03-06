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
 * Enumeration type for call states.
 */
abstract class CallState {
  static const String Unknown = 'UNKNOWN';
  static const String Created = 'CREATED';
  static const String Ringing = 'RINGING';
  static const String Queued = 'QUEUED';
  static const String Unparked = 'UNPARKED';
  static const String Hungup = 'HUNGUP';
  static const String Transferring = 'TRANSFERRING';
  static const String Transferred = 'TRANSFERRED';
  static const String Speaking = 'SPEAKING';
  static const String Parked = 'PARKED';
}

/**
 * Class representing a call in the system. Every call is identified by a
 * unique id (uuid) that may be used as a handle for REST service method calls.
 */
class Call {
  static const String className = '${libraryName}.Call';
  static final Logger _log = new Logger(Call.className);

  static final Call noCall = new Call.empty(noID);
  static final String noID = '';

  final Bus<String> _callState = new Bus<String>();
  final Bus<Event.CallEvent> _eventBus = new Bus<Event.CallEvent>();

  DateTime arrived = new DateTime.now();
  DateTime answeredAt = Util.never;
  int assignedTo = User.noID;
  String b_Leg = null;
  String callerID = '';
  int contactID = Contact.noID;
  String destination = '';
  bool greetingPlayed = false;
  String _ID = noID;
  bool inbound = null;
  bool _locked = false;
  int receptionID = Reception.noID;
  String _state = CallState.Unknown;
  String hangupCause = '';

  /**
   * Constructor.
   */
  Call.empty(this._ID);

  /**
   * Constructor.
   */
  factory Call.fromMap(Map map) => new Call.empty(map[Key.ID])
    .._state = map[PbxKey.state]
    ..answeredAt = Util.unixTimestampToDateTime(map[Key.answeredAt])
    ..b_Leg = map[Key.bLeg]
    .._locked = map[Key.locked]
    ..inbound = map[Key.inbound]
    ..destination = map[Key.destination]
    ..callerID = map[Key.callerID]
    ..greetingPlayed = map[Key.greetingPlayed]
    ..receptionID = map[ORPbxKey.receptionId]
    ..contactID = map[ORPbxKey.contactId]
    ..assignedTo = map[Key.assignedTo]
    ..arrived = Util.unixTimestampToDateTime(map[Key.arrivalTime]);

  /**
   *
   */
  @override
  bool operator ==(Call other) => _ID == other._ID;

  /**
   *
   */
  void assignTo(User user) {
    assignedTo = user.id;
  }

  /**
   *
   */
  Stream<String> get callState => _callState.stream;

  /**
   *
   */
  void changeState(String newState) {
    final String lastState = _state;

    _state = newState;

    _log.finest('UUID: ${_ID}: ${lastState} => ${newState}');

    if (lastState == CallState.Queued) {
      notifyEvent(new Event.QueueLeave(this));
    } else if (lastState == CallState.Parked) {
      notifyEvent(new Event.CallUnpark(this));
    }

    switch (newState) {
      case (CallState.Created):
        notifyEvent(new Event.CallOffer(this));
        break;

      case (CallState.Parked):
        notifyEvent(new Event.CallPark(this));
        break;

      case (CallState.Unparked):
        notifyEvent(new Event.CallUnpark(this));
        break;

      case (CallState.Queued):
        notifyEvent(new Event.QueueJoin(this));
        break;

      case (CallState.Hungup):
        notifyEvent(new Event.CallHangup(this, hangupCause: hangupCause));
        break;

      case (CallState.Speaking):
        notifyEvent(new Event.CallPickup(this));
        break;

      case (CallState.Transferred):
        notifyEvent(new Event.CallTransfer(this));
        break;

      case (CallState.Ringing):
        notifyEvent(new Event.CallStateChanged(this));
        break;

      case (CallState.Transferring):
        break;

      default:
        _log.severe('Changing call ${this} to Unkown state!');
        break;
    }
  }

  /**
   * Note: The channel is a unique identifier.
   *   Remember to change, if ID changes.
   */
  String get channel => _ID;

  /**
   * The Unique identification of the call
   */
  String get ID => _ID;

  /**
   *
   */
  String get state => _state;

  /**
   *
   */
  set state(String newState) {
    _state = newState;
    _callState.fire(newState);
  }

  /**
   *
   */
  Stream<Event.CallEvent> get event => _eventBus.stream;

  /**
   *
   */
  @override
  int get hashCode => _ID.hashCode;

  /**
   *
   */
  bool get isActive => this != noCall;

  /**
   *
   */
  void link(Call other) {
    if (locked) locked = false;

    b_Leg = other._ID;
    other.b_Leg = _ID;
  }

  /**
   *
   */
  bool get locked => _locked;

  /**
   *
   */
  void set locked(bool lock) {
    _locked = lock;

    if (lock) {
      notifyEvent(new Event.CallLock((this)));
    } else {
      notifyEvent(new Event.CallUnlock(this));
    }
  }

  /**
   *
   */
  void notifyEvent(Event.Event event) => _eventBus.fire(event);

  /**
   *
   */
  void release() {
    assignedTo = User.noID;
  }

  /**
   * String version of [Call] for debug/log purposes.
   */
  @override
  String toString() => this == noCall
      ? 'no Call'
      : 'Call ID: ${_ID}, state: ${_state}, destination: ${destination}';

  /**
   *
   */
  Map toJson() => {
        Key.ID: _ID,
        PbxKey.state: _state,
        Key.bLeg: b_Leg,
        Key.locked: locked,
        Key.inbound: inbound,
        Key.destination: destination,
        Key.callerID: callerID,
        Key.greetingPlayed: greetingPlayed,
        ORPbxKey.receptionId: receptionID,
        ORPbxKey.contactId: contactID,
        Key.assignedTo: assignedTo,
        Key.channel: channel,
        Key.arrivalTime: Util.dateTimeToUnixTimestamp(arrived),
        Key.answeredAt: Util.dateTimeToUnixTimestamp(answeredAt)
      };

  /**
   *
   */
  static void validateID(String callID) {
    if (callID == null || callID.isEmpty) {
      throw new FormatException('Invalid Call ID: ${callID}');
    }
  }
}
