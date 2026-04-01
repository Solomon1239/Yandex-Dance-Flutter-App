class Validators {
  static String? email(String value) {
    if (value.trim().isEmpty) return 'Введите email';

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'Некорректный email';

    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) return 'Введите пароль';
    if (value.length < 6) return 'Минимум 6 символов';
    return null;
  }

  static String? requiredText(String value, {String field = 'Поле'}) {
    if (value.trim().isEmpty) return 'Заполните "$field"';
    return null;
  }

  static String? age(String value) {
    if (value.trim().isEmpty) return null;
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 120) {
      return 'Некорректный возраст';
    }
    return null;
  }
}
