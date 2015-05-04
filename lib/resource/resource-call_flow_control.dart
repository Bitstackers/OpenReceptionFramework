part of openreception.resource;

/**
 * Protocol wrapper class for building homogenic REST
 * resources across servers and clients.
 */
abstract class CallFlowControl {

  static String nameSpace = 'call';

  /**
   * Builds a Uri to retrieve a userstatus resource.
   * The output format is:
   *    http://hostname/userstate/${userID}
   */
  static Uri userStatus(Uri host, int userID)
    => Uri.parse('${host}/userstate/${userID}');

  /**
   * Builds a Uri to retrieve a list of userstatus resources.
   * The output format is:
   *    http://hostname/userstate
   */
  static Uri userStatusList(Uri host)
    => Uri.parse('${host}/userstate');

  /**
   * Builds a Uri to update a userstatus resource associated with a user.
   * The [newState] parameter must be a valid [UserState].
   * The output format is:
   *    http://hostname/userstate/${userID}/${newState}
   */
  static Uri userState (Uri host, int userID, String newState)
    => Uri.parse('${host}/userstate/${userID}/${newState}');

  /**
   * Builds a Uri to keep alive a userstatus resource associated with a user.
   * The [newState] parameter must be a valid [UserState].
   * The output format is:
   *    http://hostname/userstate/${userID}/keep-alive
   */
  static Uri userStateKeepAlive (Uri host, int userID)
    => Uri.parse('${host}/userstate/${userID}/keep-alive');

  /**
   * Builds a Uri to logout userstatus resource associated with a user.
   * The [newState] parameter must be a valid [UserState].
   * The output format is:
   *    http://hostname/userstate/${userID}/loggedOut
   */
  static Uri userStateLoggedOut (Uri host, int userID)
    => userState(host, userID, Model.UserState.LoggedOut);

  /**
   * Builds a Uri to retrieve a userstatus resource.
   * The output format is:
   *    http://hostname/channel/list
   */
  static Uri channelList(Uri host)
    => Uri.parse('${host}/channel/list');

  /**
   * Builds a Uri to mark a userstatus resource as idle.
   * The output format is:
   *    http://hostname/userstate/${userID}/idle
   */
  static Uri userStatusIdle(Uri host, int userID)
    => Uri.parse('${userStatus(host, userID)}/idle');

  /**
   * Builds a Uri to retrieve a every current peer resource.
   * The output format is:
   *    http://hostname/peer/list
   */
  static Uri peerList(Uri host)
    => Uri.parse('${host}/peer/list');

  /**
   * Builds a Uri to retrieve a single call resource.
   * The output format is:
   *    http://hostname/call/<callID>
   */
  static Uri single(Uri host, String callID)
    => Uri.parse('${_root(host)}/${callID}');

  /**
   * Builds a Uri to pickup a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/pickup
   */
  static Uri pickup(Uri host, String callID)
    =>  Uri.parse ('${single (host, callID)}/pickup');

  /**
   * Builds a Uri to originate to a specific extension.
   * The output format is:
   *    http://hostname/call/originate/<extension>/reception/<receptionID>/contact/<contactID>
   */
  static Uri originate(Uri host, String extension,
                       int contactID, int receptionID)
    =>  Uri.parse ('${_root(host)}'
                    '/originate/${extension}'
                    '/reception/${receptionID}'
                    '/contact/${contactID}');

  /**
   * Builds a Uri to park a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/park
   */
  static Uri park(Uri host, String callID)
    =>  Uri.parse ('${single (host, callID)}/park');

  /**
   * Builds a Uri to hangup a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/hangup
   */
  static Uri hangup(Uri host, String callID)
    =>  Uri.parse ('${single (host, callID)}/hangup');

  /**
   * Builds a Uri to transfer a specific call resource.
   * The output format is:
   *    http://hostname/call/<callID>/hangup
   */
  static Uri transfer(Uri host, String callID, String destination)
    =>  Uri.parse ('${single (host, callID)}/transfer/${destination}');

  /**
   * Builds a Uri to retrieve a every current call resource.
   * The output format is:
   *    http://hostname/call
   */
  static Uri list(Uri host) => _root(host);

  /**
   * Builds up the root resource.
   * The output format is:
   *    http://hostname/call
   */
  static Uri _root(Uri host)
    => Uri.parse('${Util.removeTailingSlashes(host)}/${nameSpace}');
}
