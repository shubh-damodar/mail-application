import 'package:intl/intl.dart';

class DateCategory {
  DateFormat ddMMyyyyDateFormat = DateFormat('dd/MM/yyyy'),
      MMMMddDateFormat = DateFormat('MMMM dd'),
      hhmmDateFormat = DateFormat('H:mm'),
      ddMMyyyyhhmmDateFormat = DateFormat('dd/MM/yyyy H:mm'),
      EEEEMMMMdhhmmaDateFormat = DateFormat('EEEE, MMMM d, hh:mm a');
  DateTime _currentDateTime = DateTime.now();

  String sentDate(DateTime messageDateTime) {
    return (_currentDateTime.year == messageDateTime.year &&
        _currentDateTime.month == messageDateTime.month)
        ? (_currentDateTime.day == messageDateTime.day)
        ? hhmmDateFormat.format(messageDateTime)
        : (_currentDateTime.day - messageDateTime.day == 1)
        ? 'Yesterday' : (_currentDateTime.day - messageDateTime.day < 9)
        ? '${_currentDateTime.day - messageDateTime.day} days ago'
        : ddMMyyyyDateFormat.format(messageDateTime).toString()
        : ddMMyyyyDateFormat.format(messageDateTime).toString();
  }
}
