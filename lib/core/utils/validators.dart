class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse e-mail est requise';
    }
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Adresse e-mail invalide';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? required(String? value, [String field = 'Ce champ']) {
    if (value == null || value.isEmpty) {
      return '$field est requis';
    }
    return null;
  }

  static String? note(String? value) {
    if (value == null || value.isEmpty) {
      return 'La note est requise';
    }
    final note = double.tryParse(value.replaceAll(',', '.'));
    if (note == null) {
      return 'Note invalide';
    }
    if (note < 0 || note > 20) {
      return 'La note doit être entre 0 et 20';
    }
    return null;
  }

  static String? coefficient(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le coefficient est requis';
    }
    final coeff = double.tryParse(value.replaceAll(',', '.'));
    if (coeff == null || coeff <= 0) {
      return 'Coefficient invalide';
    }
    return null;
  }
}
