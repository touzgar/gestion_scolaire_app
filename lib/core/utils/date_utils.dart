import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat _dayMonth = DateFormat('dd MMM', 'fr_FR');
  static final DateFormat _fullDate = DateFormat('EEEE dd MMMM yyyy', 'fr_FR');

  static String formatDate(DateTime date) => _dateFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatFullDate(DateTime date) => _fullDate.format(date);

  /// Retourne le trimestre courant (1, 2 ou 3)
  static int getCurrentTrimestre() {
    final now = DateTime.now();
    if (now.month >= 9 && now.month <= 12) return 1;
    if (now.month >= 1 && now.month <= 3) return 2;
    return 3;
  }

  /// Retourne l'année scolaire courante (ex: "2025-2026")
  static String getCurrentAnneeScolaire() {
    final now = DateTime.now();
    if (now.month >= 9) {
      return '${now.year}-${now.year + 1}';
    }
    return '${now.year - 1}-${now.year}';
  }

  /// Retourne les dates de début/fin du trimestre
  static (DateTime start, DateTime end) getTrimestreDates(
    int trimestre,
    int startYear,
  ) {
    switch (trimestre) {
      case 1:
        return (DateTime(startYear, 9, 1), DateTime(startYear, 12, 20));
      case 2:
        return (DateTime(startYear + 1, 1, 3), DateTime(startYear + 1, 3, 31));
      case 3:
        return (DateTime(startYear + 1, 4, 1), DateTime(startYear + 1, 7, 5));
      default:
        return (DateTime(startYear, 9, 1), DateTime(startYear + 1, 7, 5));
    }
  }
}
