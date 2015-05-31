part of openreception.test;

void testResourceCallFlowControl() {
  group('Resource.CallFlowControl', () {
    test('userStatusMap', ResourceCallFlowControl.userStatusMap);
    test('channelList', ResourceCallFlowControl.channelList);
    test('userStatusIdle', ResourceCallFlowControl.userStatusIdle);
    test('userStatusKeepAlive', ResourceCallFlowControl.userStatusKeepAlive);
    test('userStatusLoggedOut', ResourceCallFlowControl.userStatusLogout);
    test('peerList', ResourceCallFlowControl.peerList);
    test('single', ResourceCallFlowControl.single);
    test('pickup', ResourceCallFlowControl.pickup);
    test('originate', ResourceCallFlowControl.originate);
    test('park', ResourceCallFlowControl.park);
    test('hangup', ResourceCallFlowControl.hangup);
    test('transfer', ResourceCallFlowControl.transfer);
    test('list', ResourceCallFlowControl.list);
  });
}
abstract class ResourceCallFlowControl {
  static Uri callFlowControlUri = Uri.parse('http://localhost:4242');

  static void userStatusMap() => expect(
      Resource.CallFlowControl.userStatus(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1')));

  static void channelList() => expect(
      Resource.CallFlowControl.channelList(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/channel/list')));

  static void userStatusIdle() => expect(
      Resource.CallFlowControl.userStatusIdle(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/idle')));

  static void userStatusKeepAlive() => expect(
      Resource.CallFlowControl.userStateKeepAlive(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/keep-alive')));

  static void userStatusLogout() => expect(
      Resource.CallFlowControl.userStateLoggedOut(callFlowControlUri, 1),
      equals(Uri.parse('${callFlowControlUri}/userstate/1/loggedOut')));

  static void peerList() => expect(
      Resource.CallFlowControl.peerList(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/peer/list')));

  static void single() => expect(
      Resource.CallFlowControl.single(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde')));

  static void pickup() => expect(
      Resource.CallFlowControl.pickup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/pickup')));

  static void originate() => expect(
      Resource.CallFlowControl.originate(callFlowControlUri, '12345678', 1, 2),
      equals(Uri.parse(
          '${callFlowControlUri}/call/originate/12345678/reception/2/contact/1')));

  static void park() => expect(
      Resource.CallFlowControl.park(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/park')));

  static void hangup() => expect(
      Resource.CallFlowControl.hangup(callFlowControlUri, 'abcde'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/hangup')));

  static void transfer() => expect(
      Resource.CallFlowControl.transfer(callFlowControlUri, 'abcde', 'edcba'),
      equals(Uri.parse('${callFlowControlUri}/call/abcde/transfer/edcba')));

  static void list() => expect(
      Resource.CallFlowControl.list(callFlowControlUri),
      equals(Uri.parse('${callFlowControlUri}/call')));
}