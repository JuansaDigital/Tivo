class DateFormatter {
  DateFormatter._();

  static const List<String> _monthsShort = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
  ];

  static const List<String> _monthsFull = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  static String dayMonth(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} ${_monthsShort[date.month - 1]}';
  }

  static String fullDate(DateTime date) {
    return '${date.day} de ${_monthsFull[date.month - 1]} de ${date.year}';
  }

  static String monthYear(DateTime date) {
    return '${_monthsFull[date.month - 1]} ${date.year}';
  }

  static String time(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  static String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final difference = today.difference(target).inDays;

    if (difference == 0) return 'Hoy, ${time(date)}';
    if (difference == 1) return 'Ayer, ${time(date)}';
    if (difference == -1) return 'Mañana, ${time(date)}';
    return '${dayMonth(date)}, ${time(date)}';
  }

  static String formatRelative(DateTime date) => relativeDay(date);
}
