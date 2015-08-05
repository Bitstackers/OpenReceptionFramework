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

library openreception.storage;

import 'dart:async';
import 'model.dart' as Model;

part 'storage/storage-cdr.dart';
part 'storage/storage-calendar.dart';
part 'storage/storage-contact.dart';
part 'storage/storage-message.dart';
part 'storage/storage-message_queue.dart';
part 'storage/storage-organization.dart';
part 'storage/storage-reception.dart';
part 'storage/storage-user.dart';

class StorageException implements Exception {}

class NotFound implements StorageException {

  final String message;
  const NotFound([this.message = ""]);

  String toString() => "NotFound: $message";
}


class SaveFailed implements StorageException {

  final String message;
  const SaveFailed([this.message = ""]);

  String toString() => "SaveFailed: $message";
}

class Forbidden implements StorageException {

  final String message;
  const Forbidden([this.message = ""]);

  String toString() => "Forbidden: $message";
}

class Conflict implements StorageException {

  final String message;
  const Conflict([this.message = ""]);

  String toString() => "Conflict: $message";
}


class NotAuthorized implements StorageException {

  final String message;
  const NotAuthorized([this.message = ""]);

  String toString() => "NotAuthorized: $message";
}

class ClientError implements StorageException {

  final String message;
  const ClientError([this.message = ""]);

  String toString() => "ClientError: $message";
}

class ServerError implements StorageException {

  final String message;
  const ServerError([this.message = ""]);

  String toString() => "ServerError: $message";
}
