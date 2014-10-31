part of openreception.service;

abstract class AuthResource {

  static String nameSpace = 'token';

  static Uri tokenToUser(Uri host, String token)
    => Uri.parse('${_removeTailingSlashes(host)}/${nameSpace}/${token}');
}

class Authentication {

  static final String className = '${libraryName}.Authentication';

  WebService _backed = null;
  Uri        _host;
  String     _token = '';


  Authentication (Uri this._host, String this._token, this._backed);

  /**
   * Performs a lookup of the user on the notification server via the supplied token.
   */
  Future<Model.User> userOf(String token) =>
      this._backed.get (appendToken(AuthResource.tokenToUser(this._host, token), this._token))
      .then((String response)
        => new Model.User.fromMap(JSON.decode(response)));
}
