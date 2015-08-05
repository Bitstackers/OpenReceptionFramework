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

part of openreception.storage;

/**
 * TODO: Deprecate the calendar*event methods and rename them to calendar*entry.
 */
abstract class Calendar {

  Future<Iterable<Model.CalendarEntry>> receptionCalendar (int receptionID);

  Future<Iterable<Model.CalendarEntry>> contactCalendar
    (int receptionID, int contactID);

  Future<Model.CalendarEntry> receptionCalendarEntry
    (int receptionID, int eventID);

  Future<Model.CalendarEntry> contactCalendarEntry
    (int receptionID, int contactID, int eventID);

  Future<Model.CalendarEntry> calendarEventCreate (Model.CalendarEntry event);

  Future<Model.CalendarEntry> calendarEventUpdate (Model.CalendarEntry event);

  Future calendarEventRemove (Model.CalendarEntry event);

}
