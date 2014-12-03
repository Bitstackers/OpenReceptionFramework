part of openreception.service;

/**
 * Superclass for abstracting away the griddy details of
 * client/server-specific web-clients.
 */
abstract class WebSocket {

  static final ID_Func = () => null;

  static const String GET    = 'GET';
  static const String PUT    = 'PUT';
  static const String POST   = 'POST';
  static const String DELETE = 'DELETE';

  dynamic onMessage = ID_Func;
  dynamic onError   = ID_Func;
  dynamic onClose   = ID_Func;

  Future<WebSocket> connect (Uri path);

  void checkResponseCode(int responseCode) {
    switch (responseCode) {
      case 200:
        break;

      case 400:
        throw new Storage.ClientError ();
        break;

      case 401:
        throw new Storage.NotAuthorized ();
        break;

      case 403:
        throw new Storage.Forbidden ();
        break;

      case 404:
       throw new Storage.NotFound();
       break;

      case 500:
        throw new Storage.ServerError();
        break;

      default:
        throw new StateError('Status (${responseCode}):');
    }
  }
}