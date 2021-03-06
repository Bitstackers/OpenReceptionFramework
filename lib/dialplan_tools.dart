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

library openreception.dialplan_tools;

import 'dart:convert';

import 'model.dart' as model;
import 'pbx-keys.dart';

const String closedSuffix = 'closed';
const String outboundSuffix = 'outbound';

class DialplanCompilerOpts {
  final bool goLive;
  final String greetingDir;
  final String testNumber;
  final String testEmail;
  final String callerIdName;
  final String callerIdNumber;

  DialplanCompilerOpts(
      {this.goLive: false,
      this.greetingDir: 'converted-vox',
      this.testNumber: 'xxxxxxxx',
      this.testEmail: 'some-guy@somewhere',
      this.callerIdName: 'Undefined',
      this.callerIdNumber: '00000000'});
}

/**
 * Environment that enables state to be passed along to the next function in
 * the chain.
 */
class Environment {
  String channelState = '';
  bool channelAnswered = false;
  bool callAnnounced = false;
}

/**
 * Dialplan compiler. Builds xml dialplans, xml ivr menus and xml user
 * accounts for FreeSWITCH.
 */
class DialplanCompiler {
  DialplanCompilerOpts option;

  DialplanCompiler(this.option);

  String dialplanToXml(
          model.ReceptionDialplan dialplan, model.Reception reception) =>
      _dialplanToXml(dialplan, option, reception);

  String ivrToXml(model.IvrMenu menu) => _ivrToXml(menu, option);

  String voicemailToXml(model.Voicemail vm) => _voicemailToXml(vm, option);

  String userToXml(model.User user, model.PeerAccount account) => '''<include>
  <user id="${account.username}">
    <params>
      <param name="password" value="${account.password}"/>
    </params>
    <variables>
      <variable name="toll_allow" value="domestic,international,local"/>
      <variable name="accountcode" value="${account.username}"/>
      <variable name="user_context" value="${account.context}"/>
      <variable name="effective_caller_id_name" value="${user.name}"/>
      <variable name="effective_caller_id_number" value="${account.username}"/>
      <variable name="outbound_caller_id_name" value="\$\${outbound_caller_name}"/>
      <variable name="outbound_caller_id_number" value="\$\${outbound_caller_id}"/>
      <variable name="callgroup" value="${account.context}"/>
    </variables>
  </user>
</include>''';
}

List<String> _externalTrunkTransfer(
    String extension, int rid, DialplanCompilerOpts opts) {
  final String callerIdName =
      new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert(opts.callerIdName);
  final String callerIdNumber =
      new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert(opts.callerIdNumber);

  return [
    '<extension name="${extension}-${outboundSuffix}-trunk" continue="true">',
    '  <condition field="destination_number" expression="^${PbxKey.externalTransfer}_(\\d+)\$">',
    '    <action application="set" data="ringback=\${dk-ring}"/>',
    '    <action application="ring_ready" />',
    '    <action application="bridge" data="{${ORPbxKey.receptionId}=${rid},originate_timeout=120,origination_caller_id_name=$callerIdName,origination_caller_id_number=$callerIdNumber}[leg_timeout=50,${ORPbxKey.receptionId}=${rid},fifo_music=default]sofia/gateway/\${default_trunk}/\$1"/>',
    '    <action application="hangup"/>',
    '  </condition>',
    '</extension>'
  ];
}

List<String> _externalSipTransfer(
    String extension, int rid, DialplanCompilerOpts opts) {
  final String callerIdName =
      new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert(opts.callerIdName);
  final String callerIdNumber =
      new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert(opts.callerIdNumber);
  return [
    '<extension name="${extension}-${outboundSuffix}-sip" continue="true">',
    '  <condition field="destination_number" expression="^${PbxKey.externalTransfer}_(.*)">',
    '    <action application="set" data="ringback=\${dk-ring}"/>',
    '    <action application="ring_ready" />',
    '    <action application="bridge" data="{${ORPbxKey.receptionId}=${rid},originate_timeout=120,origination_caller_id_name=$callerIdName,origination_caller_id_number=$callerIdNumber}[leg_timeout=50,${ORPbxKey.receptionId}=${rid},fifo_music=default]sofia/external/\$1"/>',
    '    <action application="hangup"/>',
    '  </condition>',
    '</extension>'
  ];
}

/**
 * Normalizes an opening hour string for use in extension name by removing the
 * spaces and removing other odd characters.
 */
String _normalizeOpeningHour(String string) =>
    string.replaceAll(' ', '_').replaceAll(':', '');

/**
 * Indent a string by [count] spaces.
 */
String _indent(String item, {int count: 2}) =>
    '${new List.filled(count, ' ').join('')}$item';

/**
 *
 */
List<String> _openingHourToXmlDialplan(
    String extension,
    model.OpeningHour oh,
    Iterable<model.Action> actions,
    DialplanCompilerOpts option,
    Environment env,
    model.Reception reception) {
  List<String> lines = new List<String>();
  Iterable<String> actionLines = actions
      .map((action) => _actionToXmlDialplan(action, option, env, reception))
      .fold(
          new List<String>(),
          (List<String> combined, List<String> current) =>
              combined..addAll(current.map((e) => _indent(e, count: 4))));

  lines.addAll([
    '',
    _comment('Actions for opening hour $oh'),
    '<extension name="${extension}-${_normalizeOpeningHour(oh.toString())}" continue="true">'
  ]);

  if (env.callAnnounced) {
    lines.add(
        '  <condition field="\${${ORPbxKey.receptionOpen}}" expression="^true\$"/>');
  }
  lines
    ..add(
        '  <condition ${_openingHourToFreeSwitch(oh)} break="${PbxKey.onTrue}">')
    ..addAll(actionLines)
    ..add('    <action application="hangup"/>')
    ..add('  </condition>')
    ..add('</extension>');
  return lines;
}

/**
 * Generate A fallback extension.
 */
List<String> _fallbackToDialplan(
    String extension,
    Iterable<model.Action> actions,
    DialplanCompilerOpts option,
    Environment env,
    model.Reception reception) {
  return new List<String>.from([
    '',
    _comment('Default fallback actions for $extension'),
    '<extension name="${extension}-$closedSuffix">',
    '  <condition>',
  ])
    ..addAll(actions
        .map((action) => _actionToXmlDialplan(action, option, env, reception))
        .fold(
            new List<String>(),
            (List<String> combined, List<String> current) =>
                combined..addAll(current.map((String item) => _indent(item)))))
    ..add('    <action application="hangup"/>')
    ..add('  </condition>')
    ..add('</extension>');
}

/**
 *
 */
Iterable<Iterable<String>> _hourActionToXmlDialplan(
        String extension,
        model.HourAction hourAction,
        DialplanCompilerOpts option,
        model.Reception reception) =>
    hourAction.hours.map((oh) => _openingHourToXmlDialplan(extension, oh,
        hourAction.actions, option, new Environment(), reception));

/**
 *
 */
Iterable<String> _hourActionsToXmlDialplan(
        String extension,
        Iterable<model.HourAction> hourActions,
        DialplanCompilerOpts option,
        model.Reception reception) =>
    hourActions.map((ha) =>
        _hourActionToXmlDialplan(extension, ha, option, reception)
            .fold([], (combined, current) => combined..addAll(current)));

/**
 * Turns a [NamedExtension] into a dialplan document fragment.
 */
Iterable<String> _namedExtensionToDialPlan(
        model.NamedExtension extension,
        DialplanCompilerOpts option,
        Environment env,
        model.Reception reception) =>
    [
      '',
      _noteTemplate('Extra-extension ${extension.name}'),
      '<extension name="${extension.name}" continue="true">',
      '  <condition field="destination_number" '
          'expression="^${extension.name}\$" '
          'break="${PbxKey.onFalse}">',
    ]
      ..addAll(extension.actions
          .map((action) => _actionToXmlDialplan(action, option, env, reception))
          .fold(
              [],
              (combined, current) =>
                  combined..addAll(current.map(_indent).map(_indent))))
      ..add('    <action application="hangup"/>')
      ..add('  </condition>')
      ..add('</extension>');

Iterable<String> _extraExtensionsToDialplan(
        Iterable<model.NamedExtension> extensions,
        DialplanCompilerOpts option,
        model.Reception reception) =>
    extensions
        .map((ne) =>
            _namedExtensionToDialPlan(ne, option, new Environment(), reception))
        .fold([], (combined, current) => combined..addAll(current));

/**
 *
 */
String _dialplanToXml(model.ReceptionDialplan dialplan,
    DialplanCompilerOpts option, model.Reception reception) {
  final String htmlEncodedReceptionName =
      new HtmlEscape(HtmlEscapeMode.ATTRIBUTE).convert(reception.name);

  return '''<!-- Dialplan for extension ${dialplan.extension}. Generated ${new DateTime.now()} -->
<include>
  <context name="reception-${dialplan.extension}">

    <!-- Initialize channel variables -->
    <extension name="${dialplan.extension}" continue="true">
      <condition field="destination_number" expression="^${dialplan.extension}\$" break="${PbxKey.onFalse}">
        <action application="log" data="INFO Setting variables of call to ${dialplan.extension}, currently allocated to rid ${reception.ID}."/>
        ${_setVar(ORPbxKey.receptionId, reception.ID)}
        ${_setVar(ORPbxKey.greetingPlayed, false)}
        ${_setVar(ORPbxKey.locked, false)}
        ${_setVar(ORPbxKey.receptionName, htmlEncodedReceptionName)}
      </condition>
    </extension>

    ${_extraExtensionsToDialplan(dialplan.extraExtensions, option, reception).join('\n    ')}
    <!-- Perform outbound PSTN calls -->
    ${_externalTrunkTransfer(dialplan.extension, reception.ID, option).join('\n    ')}

    <!-- Perform outbound SIP calls -->
    ${_externalSipTransfer(dialplan.extension, reception.ID, option).join('\n    ')}

    ${_hourActionsToXmlDialplan(dialplan.extension, dialplan.open, option, reception).fold([], (combined, current) => combined..addAll(current)).join('\n    ')}
    ${_fallbackToDialplan(dialplan.extension, dialplan.defaultActions, option, new Environment(), reception).join('\n    ')}

  </context>
</include>''';
}

/**
 * Detemine whether or not an extension is local or not.
 */
bool _isInternalExtension(String extension) => extension.contains('-');

/**
 * Template for dialout action.
 */
String _dialoutTemplate(String extension, DialplanCompilerOpts option) =>
    _isInternalExtension(extension)
        ? extension
        : option.goLive
            ? '${PbxKey.externalTransfer}_${extension}'
            : '${PbxKey.externalTransfer}_${option.testNumber}';

/**
 *
 */
String _liveCheckEmail(String email, DialplanCompilerOpts option) =>
    option.goLive ? email : option.testEmail;

/**
* Template for dialplan note.
*/
String _noteTemplate(String note) => _comment('Note: $note');

/**
 * Template for a comment.
 */
String _comment(String text) => '<!-- $text -->';

/**
 * Template transfer action.
 */
String _transferTemplate(String extension, DialplanCompilerOpts option) =>
    '<action application="transfer" data="${_dialoutTemplate(extension, option)}"/>';

/**
 * Template fo [ReceptionTransfer] action.
 */
String _receptionTransferTemplate(
        String extension, DialplanCompilerOpts option) =>
    '<action application="transfer" data="${extension} XML reception-${extension}"/>';

/**
 * Template for a sleep action.
 */
String _sleep(int msec) => '<action application="sleep" data="$msec"/>';

/**
 * Template for a call lock event.
 */
String get _lock => '<action application="${PbxKey.event}" '
    'data="${PbxKey.eventSubclass}=${ORPbxKey.callLock},${PbxKey.eventName}=${PbxKey.custom}"/>';

/**
 * Template for a call unlock event.
 */
String get _unlock => '<action application="${PbxKey.event}" '
    'data="${PbxKey.eventSubclass}=${ORPbxKey.callUnlock},${PbxKey.eventName}=${PbxKey.custom}"/>';

/**
 * Template for a set variable action.
 */
String _setVar(String key, dynamic value) =>
    '<action application="set" data="$key=$value"/>';

/**
 * Template for a ring tone event.
 */
String get _ringTone => '<action application="${PbxKey.event}" '
    'data="${PbxKey.eventSubclass}=${ORPbxKey.ringingStart},${PbxKey.eventName}=${PbxKey.custom}" />';
/**
 * Template for a ring stop event.
 */
String get _ringToneStop => '<action application="${PbxKey.event}" '
    'data="${PbxKey.eventSubclass}=${ORPbxKey.ringingStop},${PbxKey.eventName}=${PbxKey.custom}"/>';

/**
 * Template for a notify event.
 */
String get _callNotify => '<action application="${PbxKey.event}" '
    'data="${PbxKey.eventSubclass}=${ORPbxKey.callNotify},${PbxKey.eventName}=${PbxKey.custom}" />';

/**
 * Convert an action a xml dialplan entry.
 */
List<String> _actionToXmlDialplan(model.Action action,
    DialplanCompilerOpts option, Environment env, model.Reception reception) {
  List<String> returnValue = [];

  /// Transfer action.
  if (action is model.Transfer) {
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));
    if (!env.channelAnswered) {
      returnValue.add('<action application="answer"/>');
      env.channelAnswered = true;
    }
    returnValue.add('<action application="playback" '
        'data="{loops=1}${option.greetingDir}/A-no-sound-message.wav"/>');

    returnValue.add(_transferTemplate(action.extension, option));
  }

  /// Notify action.
  else if (action is model.Notify) {
    returnValue.addAll([
      _comment('Announce the call to the receptionists'),
      _setVar(ORPbxKey.state, 'new'),
      _callNotify
    ]);
    env.callAnnounced = true;
  }

  /// ReceptionTransfer action.
  else if (action is model.ReceptionTransfer) {
    returnValue.addAll([
      _comment('Transfer call to other reception'),
      _receptionTransferTemplate(action.extension, option)
    ]);
  }

  /// Ringtone action.
  else if (action is model.Ringtone) {
    returnValue.addAll([
      _comment('Sending ringtones'),
      _setVar(ORPbxKey.state, PbxKey.ringing),
      _ringTone,
      '<action application="ring_ready"/>',
      _sleep(5000 * action.count),
      _ringToneStop,
    ]);
  }

  /// Playback action.
  else if (action is model.Playback) {
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));
    returnValue.addAll([_comment('Playback file ${action.filename}')]);

    returnValue..add(_setVar(ORPbxKey.state, PbxKey.playback));

    if (!env.channelAnswered) {
      returnValue.add('<action application="answer"/>');
      env.channelAnswered = true;
    }

    if (env.callAnnounced) {
      returnValue.addAll([_setVar(ORPbxKey.locked, true), _lock]);
    }

    returnValue.addAll([
      '<action application="playback" '
          'data="{loops=${action.repeat}}${option.greetingDir}/${action.filename}"/>',
      _setVar(ORPbxKey.greetingPlayed, true),
    ]);

    if (env.callAnnounced) {
      returnValue.addAll([_setVar(ORPbxKey.locked, false), _unlock]);
    }
  }

  /// Enqueue action.
  else if (action is model.Enqueue) {
    if (!env.channelAnswered) {
      returnValue.add('<action application="answer"/>');
      env.channelAnswered = true;
    }

    returnValue.addAll([
      _comment('Enqueue call'),
      _setVar(ORPbxKey.state, PbxKey.queued),
      '<action application="${PbxKey.event}" data="${PbxKey.eventSubclass}=${ORPbxKey.waitQueueEnter},${PbxKey.eventName}=${PbxKey.custom}" />',
      _setVar('fifo_music', 'local_stream://${action.holdMusic}'),
      '<action application="fifo" data="${action.queueName}@\${domain_name} in"/>'
    ]);
  }

  /// Voicemail  action.
  else if (action is model.Voicemail) {
    if (!env.channelAnswered) {
      returnValue.add('<action application="answer"/>');
      env.channelAnswered = true;
    }
    if (action.note.isNotEmpty) returnValue.add(_noteTemplate(action.note));
    returnValue.addAll([
      _setVar(
          ORPbxKey.emailDateHeader, '\${strftime(%a, %d %b %Y %H:%M:%S %z)}'),
      _setVar('record_waste_resources', 'true'),
      '<action application="voicemail" data="default \$\${domain} ${action.vmBox}"/>'
    ]);
  }

  /// Ivr action.
  else if (action is model.Ivr) {
    if (!env.channelAnswered) {
      returnValue.add('<action application="answer"/>');
      env.channelAnswered = true;
    }

    returnValue.addAll([
      _setVar('record_waste_resources', 'true'),
      _setVar(
          ORPbxKey.emailDateHeader, '\${strftime(%a, %d %b %Y %H:%M:%S %z)}'),
      '<action application="ivr" data="${action.menuName}"/>'
    ]);
  } else {
    throw new StateError('Unsupported action type: ${action.runtimeType}');
  }

  return returnValue;
}

/**
 * Turns a [model.WeekDay] into a FreeSWITCH weekday index.
 */
int _weekDayToFreeSwitch(model.WeekDay wday) => (wday.index) + 1;

/**
 * Formats an [model.OpeningHour] into a format that FreeSWITCH understands.
 */
String _openingHourToFreeSwitch(model.OpeningHour oh) {
  String wDayString = '';

  /// Prefixes string of integer with a '0' if the integer value is below 10.
  String _twoDigitInt(int i) => i < 10 ? '0$i' : '$i';

  if ([oh.fromDay, oh.toDay].contains(model.WeekDay.all)) {
    wDayString = '';
  } else if (oh.fromDay == oh.toDay) {
    wDayString = 'wday="${_weekDayToFreeSwitch(oh.fromDay)}"';
  } else {
    wDayString =
        'wday="${_weekDayToFreeSwitch(oh.fromDay)}-${_weekDayToFreeSwitch(oh.toDay)}"';
  }

  String ohString =
      '${_twoDigitInt(oh.fromHour)}:${_twoDigitInt(oh.fromMinute)}:00-'
      '${_twoDigitInt(oh.toHour)}:${_twoDigitInt(oh.toMinute)}:00';

  return '$wDayString time-of-day="$ohString"';
}

/**
 *
 */

List<String> _ivrMenuToXml(model.IvrMenu menu, DialplanCompilerOpts option) =>
    menu.entries
        .map((entry) => _ivrEntryToXml(entry, option))
        .fold([], (combined, current) => combined..addAll(current));

String _generateXmlFromIvrMenu(
        model.IvrMenu menu, DialplanCompilerOpts option) =>
    '''<menu name="${menu.name}"
      ${PbxKey.greetLong}="\$\${sounds_dir}/${option.greetingDir}/${menu.greetingLong.filename}"
      ${PbxKey.greetShort}="\$\${sounds_dir}/${option.greetingDir}/${menu.greetingShort.filename}"
      ${PbxKey.timeout}="\$\${IVR_timeout}"
      ${PbxKey.maxFailures}="\$\${IVR_max-failures}"
      ${PbxKey.maxTimeouts}="\$\${IVR_max-timeout}">

    ${(_ivrMenuToXml(menu, option)).join('\n    ')}
  </menu>

  ${menu.submenus.map((menu) => _generateXmlFromIvrMenu (menu, option)).join('\n  ')}
''';

String _ivrToXml(model.IvrMenu menu, DialplanCompilerOpts option) => '''
<include>
  ${_generateXmlFromIvrMenu(menu, option)}
</include>''';

List<String> _ivrEntryToXml(model.IvrEntry entry, DialplanCompilerOpts option) {
  List<String> returnValue = [];

  /// IvrTransfer action
  if (entry is model.IvrTransfer) {
    if (entry.transfer.note.isNotEmpty)
      returnValue.add(_noteTemplate(entry.transfer.note));
    returnValue.add(
        '<entry action="${PbxKey.menuExecApp}" digits="${entry.digits}" '
        'param="transfer ${_dialoutTemplate(entry.transfer.extension, option)}"/>');

    /// IvrReceptionTransfer action
  } else if (entry is model.IvrReceptionTransfer) {
    if (entry.transfer.note.isNotEmpty)
      returnValue.add(_noteTemplate(entry.transfer.note));
    returnValue.add(
        '<entry action="${PbxKey.menuExecApp}" digits="${entry.digits}" '
        'param="transfer ${entry.transfer.extension} XML reception-${entry.transfer.extension}"/>');
  } else if (entry is model.IvrVoicemail) {
    returnValue.add(
        '<entry action="${PbxKey.menuExecApp}" digits="${entry.digits}" param="voicemail default \$\${domain} ${entry.voicemail.vmBox}"/>');
  } else if (entry is model.IvrSubmenu) {
    returnValue.add(
        '<entry action="${PbxKey.menuSub}" digits="${entry.digits}" param="${entry.name}"/>');
  } else if (entry is model.IvrTopmenu) {
    returnValue
        .add('<entry action="${PbxKey.menuTop}" digits="${entry.digits}"/>');
  } else
    throw new ArgumentError.value(
        entry.runtimeType,
        'entry'
        'type ${entry.runtimeType} is not supported by translation tool');

  return returnValue;
}

Iterable<String> ivrOf(model.ReceptionDialplan rdp) => rdp.allActions
    .where((action) => action is model.Ivr)
    .map((ivr) => (ivr as model.Ivr).menuName);

/**
 *
 */
String _voicemailToXml(model.Voicemail vm, DialplanCompilerOpts option) =>
    '''<include>
  <user id="${vm.vmBox}">
    <params>
      <param name="password" value=""/>
      <param name="vm-password" value=""/>
      <param name="http-allowed-api" value="voicemail"/>
      <param name="vm-mailto" value="${_liveCheckEmail(vm.recipient, option)}"/>
      <param name="vm-email-all-messages" value="true"/>
      <param name="vm-notify-mailto" value="${_liveCheckEmail(vm.recipient, option)}"/>
      <param name="vm-attach-file" value="true" />
      <param name="vm-skip-instructions" value="true"/>
      <param name="vm-skip-greeting" value="true"/>
    </params>
    <variables>
      <variable name="toll_allow" value=""/>
      <variable name="user_context" value="voicemail"/>
    </variables>
  </user>
</include>''';
