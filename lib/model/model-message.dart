part of openreception.model;

abstract class Role {
  static const String TO  = 'to';
  static const String CC  = 'cc';
  static const String BCC = 'bcc';

  static final List<String> RECIPIENT_ROLES = [TO,CC,BCC];
}

class InvalidMessage implements Exception {
  final String message;

  const InvalidMessage(this.message);

  String toString() => message;
}

abstract class MessageFlag {
  static final String PleaseCall     = 'pleaseCall';
  static final String willCallBack   = 'willCallBack';
  static final String Called         = 'called';
  static final String Urgent         = 'urgent';
  static final String ManuallyClosed = 'manuallyClosed';
}

class MessageCaller {

  Map    _map = {};

  String get name                          => this.lookup('name', '?');
         set name           (String value) => this.update('name', value);
  String get company                       => this.lookup('company', '?');
         set company        (String value) => this.update('company', value);
  String get phone                         => this.lookup('phone', '?');
         set phone          (String value) => this.update('phone', value);
  String get cellphone                     => this.lookup('cellphone', '?');
         set cellphone      (String value) => this.update('cellphone', value);
  String get localExtension                => this.lookup('localExtension', '?');
         set localExtension (String value) => this.update('localExtension', value);

  MessageCaller();

  MessageCaller.fromMap(Map this._map);

  Map get asMap => this._map;

  Map toJson () => this.asMap;

  void update (String key, String value) {
    this._map[key] = value;
  }

  String lookup (String key, String defaultValue) {
    try {
      return this._map[key];
    } catch (_) {
      return defaultValue;
    }
  }

  operator == (MessageCaller other) => this.asMap == other.asMap;
}

class Message {

  static const String className = '${libraryName}.Message';
  static const int noID = 0;

  static final Logger log = new Logger(className);

  int                  ID              = noID;
  MessageRecipientList recipients      = new MessageRecipientList.empty();
  MessageContext       _messageContext = null;
  List<String>         _flags          = [];
  MessageCaller        _callerInfo     = null;
  DateTime             createdAt       = null;
  String               body            = '';
  User                 _sender         = null;
  bool                 enqueued        = null;
  bool                 sent            = null;

  bool                 get closed => enqueued || sent || manuallyClosed;

  User                 get sender     => this._sender;
  bool                 get urgent     => this._flags.contains(MessageFlag.Urgent);
  bool                 get manuallyClosed => this._flags.contains(MessageFlag.ManuallyClosed);
  MessageContext       get context    => this._messageContext;
  set context (MessageContext newContext) => this._messageContext = newContext;
  List<String>         get flags      => this._flags;
  set flags (List<String> newFlags) => this._flags = newFlags;
  MessageCaller        get caller     => this._callerInfo;
  set caller (MessageCaller newCallerInfo) => this._callerInfo = newCallerInfo;

  List<MessageRecipient> get toRecipients  => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.TO).toList();
  List<MessageRecipient> get ccRecipients  => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.CC).toList();
  List<MessageRecipient> get bccRecipients => this.recipients.where((MessageRecipient recipient) => recipient.role == Role.BCC).toList();

  void set sender (User user) { this._sender = user;}

  Message() : ID = noID;

  Message.stub(this.ID);

  bool hasFlag (String flag) => this.flags.contains(flag);

  bool get hasRecpients => !this.recipients.hasRecipients;

  Map toJson() => this.asMap;

  /**
   * Appends a message flag to the message.
   */
  void addFlag (String newFlag) {
    if (!(this._flags.contains(newFlag))) {
      this._flags.add(newFlag);
    }
  }

  /**
   * TODO: Document.
   */
  Message.fromMap(Map map) {

    /// TODO: figure out a more generic way of decoding different recipient formats.
    MessageRecipientList recipients = null;
    if (!map.containsKey('recipients')) {
      recipients = new MessageRecipientList.empty();
    } else if (map['recipients'] is List) { //This is the format from the database.
      recipients = new MessageRecipientList.fromlist(map['recipients']);
    } else if (map['recipients'] is Map) {
      recipients = new MessageRecipientList.fromMap(map['recipients']);
    } else {
      throw new InvalidMessage('Bad recipient format: ${map['recipients']}');
    }



    this
        ..ID = (map.containsKey('id') ? map['id'] : noID)
        ..recipients      = recipients
        .._messageContext = new MessageContext.fromMap(map['context'])
        .._flags          = map['flags']
        .._callerInfo     = new MessageCaller.fromMap(map['caller'])
        ..body            = map['message']
        ..sent            = map['sent']
        ..enqueued        = map['enqueued']
        .._sender         = new User.fromMap(map['taken_by_agent'])
        ..createdAt       = Util.unixTimestampToDateTime(map['created_at'])
        ..validate();
  }

  Map get asMap =>
      { 'id'             : this.ID,
        'message'        : this.body,
        'context'        : this.context.asMap,
        'taken_by_agent' : this.sender.asSender,
        'caller'         : this._callerInfo.asMap,
        'flags'          : this._flags,
        'sent'           : this.sent,
        'enqueued'       : this.enqueued,
        'created_at'     : Util.dateTimeToUnixTimestamp(this.createdAt),
        'recipients'     : this.recipients.asMap
      };

  /**
   *
   */
  void validate() => this.body.isEmpty
                     ? throw new InvalidMessage("Empty messages field not allowed")
                     : null;

  Future enqueue(Storage.Message messageStore) => messageStore.enqueue(this);

  /**
   * Saves the message in the [messageStore] supplied. Update the [ID] of the message object
   * if it previously had none.
   */
  Future<Message> save(Storage.Message messageStore) => messageStore.save(this);

  /**
   *
   */
  static Future<Message> load(int messageID, Storage.Message messageStore) => messageStore.get(messageID);

  Set<MessageRecipient> currentRecipients() => this.recipients.asSet;

  String sqlRecipients()
    => this.currentRecipients().map((MessageRecipient contact)
        => "(${contact.contactID}, '${contact.contactName}', ${contact.receptionID}, '${contact.receptionName}', ${this.ID},'${contact.role}')").join(',');
}
