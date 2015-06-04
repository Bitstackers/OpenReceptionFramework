part of openreception.event;


class PeerState implements Event {

  final DateTime timestamp;
  final String   eventName = _Key.peerState;

  final Peer     peer;

  PeerState (Peer this.peer) : this.timestamp = new DateTime.now();

  Map toJson() => this.asMap;
  String toString() => this.asMap.toString();

  Map get asMap => EventTemplate.peer(this);

  PeerState.fromMap (Map map) :
    this.peer      = new Peer.fromMap             (map[_Key.peer]),
    this.timestamp = Util.unixTimestampToDateTime (map[_Key.timestamp]);

}