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

part of openreception.service;

/**
 * Client for contact service.
 */
class RESTContactStore implements Storage.Contact {
  static final String className = '${libraryName}.RESTContactStore';
  static final Logger log = new Logger(className);

  WebService _backend = null;
  Uri _host;
  String _token = '';

  RESTContactStore(Uri this._host, String this._token, this._backend);

  Future<Iterable<int>> receptions(int contactID) {
    Uri url = Resource.Contact.receptions(this._host, contactID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<int>> organizations(int contactID) {
    Uri url = Resource.Contact.organizations(this._host, contactID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<Model.Contact>> managementServerList(int receptionID) {
    Uri url = Resource.Contact.managementServerList(this._host, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response)['receptionContacts'] as Iterable)
            .map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Model.BaseContact> get(int contactID) {
    Uri url = Resource.Contact.single(this._host, contactID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<Model.BaseContact> create(Model.BaseContact contact) {
    Uri url = Resource.Contact.root(this._host);
    url = _appendToken(url, this._token);

    String data = JSON.encode(contact.asMap);
    return this._backend.post(url, data).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future<Model.BaseContact> update(Model.BaseContact contact) {
    Uri url = Resource.Contact.single(this._host, contact.id);
    url = _appendToken(url, this._token);

    String data = JSON.encode(contact.asMap);
    return this._backend.put(url, data).then((String response) =>
        new Model.BaseContact.fromMap(JSON.decode(response)));
  }

  Future remove(contactId) {
    Uri url = Resource.Contact.single(this._host, contactId);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  Future<Iterable<Model.BaseContact>> list() {
    Uri url = Resource.Contact.list(this._host);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future<Model.Contact> getByReception(int contactID, int receptionID) {
    Uri url =
        Resource.Contact.singleByReception(this._host, contactID, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.Contact>> listByReception(int receptionID,
      {Model.ContactFilter filter}) {
    Uri url = Resource.Contact.listByReception(this._host, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.Contact.fromMap(map)));
  }

  Future<Iterable<Map>> endpointsMap(int contactID, int receptionID) {
    Uri url = Resource.Contact.endpoints(this._host, contactID, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<Model.MessageEndpoint>> endpoints(
          int contactID, int receptionID) =>
      this.endpointsMap(contactID, receptionID).then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.MessageEndpoint.fromMap(map)));

  Future<Iterable<Map>> phonesMap(int contactID, int receptionID) {
    Uri url = Resource.Contact.phones(this._host, contactID, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then(JSON.decode);
  }

  Future<Iterable<Model.PhoneNumber>> phones(int contactID, int receptionID) =>
      this.endpointsMap(contactID, receptionID).then((Iterable<Map> maps) =>
          maps.map((Map map) => new Model.PhoneNumber.fromMap(map)));

  Future<Iterable<Model.BaseContact>> colleagues(int contactId) {
    Uri url = Resource.Contact.colleagues(this._host, contactId);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future<Model.Contact> addToReception(Model.Contact contact, int receptionID) {
    Uri url =
        Resource.Contact.singleByReception(this._host, contact.ID, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.post(url, JSON.encode(contact)).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }

  Future<Iterable<Model.BaseContact>> organizationContacts(int organizationId) {
    Uri url = Resource.Contact.organizationContacts(this._host, organizationId);
    url = _appendToken(url, this._token);

    return this._backend.get(url).then((String response) =>
        (JSON.decode(response) as Iterable)
            .map((Map map) => new Model.BaseContact.fromMap(map)));
  }

  Future removeFromReception(int contactId, int receptionID) {
    Uri url =
        Resource.Contact.singleByReception(this._host, contactId, receptionID);
    url = _appendToken(url, this._token);

    return this._backend.delete(url);
  }

  Future<Model.Contact> updateInReception(Model.Contact contact) {
    Uri url = Resource.Contact
        .singleByReception(this._host, contact.ID, contact.receptionID);
    url = _appendToken(url, this._token);

    return this._backend.put(url, JSON.encode(contact)).then(
        (String response) => new Model.Contact.fromMap(JSON.decode(response)));
  }
}
