String baseUrl = "medicprohn.app";
String baseUrlSsl = "https://medicprohn.app/core/";

/// Dropdown list items for recurrenceType
List<String> repeatOption = <String>[
  'Nunca',
  'Diaria',
  'Semanalmente',
  'Mensual',
  'Anual'
];

/// Dropdown list items for day of week
List<String> weekDay = <String>[
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves`',
  'Viernes',
  'Sábado',
  'Domingo'
];

/// Dropdown list items for end range
List<String> ends = <String>[
  'Nunca',
  'Hasta que',
  'Contar',
];

/// Dropdown list items for months of year
List<String> dayMonths = <String>[
  'Enero',
  'Febrero',
  'Marzo',
  'Abril',
  'Mayo',
  'Junio',
  'Julio',
  'Augosto',
  'Septiembre',
  'Octubre',
  'Noviembre',
  'Diciembre'
];

/// Dropdown list items for week number of the month.
List<String> daysPosition = <String>[
  'First',
  'Second',
  'Third',
  'Fourth',
  'Last'
];

/// Dropdown list items for mobile recurrenceType
List<String> mobileRecurrence = <String>['Dia', 'Semana', 'Mes', 'Año'];

/// Returns the month name based on the month value passed from date.
String getMonthDate(int month) {
  if (month == 01) {
    return 'Enero';
  } else if (month == 02) {
    return 'Febrero';
  } else if (month == 03) {
    return 'Marzo';
  } else if (month == 04) {
    return 'Abril';
  } else if (month == 05) {
    return 'Mayo';
  } else if (month == 06) {
    return 'Junio';
  } else if (month == 07) {
    return 'Julio';
  } else if (month == 08) {
    return 'Agosto';
  } else if (month == 09) {
    return 'Septiembre';
  } else if (month == 10) {
    return 'Octubre';
  } else if (month == 11) {
    return 'Noviembre';
  } else {
    return 'Diciembre';
  }
}


enum EndRule { never, endDate, count }
enum SelectRule {
  doesNotRepeat,
  everyDay,
  everyWeek,
  everyMonth,
  everyYear,
  custom
}
enum Delete { event, series }



/// Dropdown list items for week number of the month.
List<String> weekDayPosition = <String>[
  'Primero',
  'Segundo',
  'Tercero',
  'Cuarto',
  'último'
];
