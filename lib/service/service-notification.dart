part of openreception.service;

abstract class Protocol {
  static final BROADCAST_RESOURCE = "broadcast";
}

abstract class Notification {

  static final String className = '${libraryName}.Notification';

  static HttpClient client = new HttpClient();

  /**
   * Performs a broadcat via the notification server.
   */
  static Future broadcast(Map map, Uri host, String serverToken) {
    final String context = '${className}.broadcast';

    if (!_UriEndsWithSlash(host)) {
      host = Uri.parse (host.toString() + '/');
    }

    host = Uri.parse('${host}${Protocol.BROADCAST_RESOURCE}?token=${serverToken}');

    return client.postUrl(host)
      .then(( HttpClientRequest req ) {
        req.headers.contentType = new ContentType( "application", "json", charset: "utf-8" );
        //req.headers.add( HttpHeaders.CONNECTION, "keep-alive");
        req.write( JSON.encode( map ));
        return req.close();
      }).catchError((error, StackTrace) => logger.errorContext('${error} : ${StackTrace}' , context));
  }

  static bool _UriEndsWithSlash (Uri uri) => uri.toString().endsWith('/');
}
