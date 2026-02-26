import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

/// Service d'envoi d'e-mails via Gmail SMTP
class EmailService {
  // Configuration SMTP Gmail
  static const String _smtpHost = 'smtp.gmail.com';
  static const int _smtpPort = 587;
  static const String _smtpUser = 'ghaithslama26@gmail.com';
  static const String _smtpPass = 'bghhlyuexfyskmqv';

  static SmtpServer get _smtpServer => SmtpServer(
    _smtpHost,
    port: _smtpPort,
    username: _smtpUser,
    password: _smtpPass,
    ssl: false,
    allowInsecure: false,
  );

  /// Envoyer un e-mail de bienvenue lors de la création d'un compte
  static Future<bool> sendWelcomeEmail({
    required String toEmail,
    required String userName,
    required String role,
  }) async {
    final message = Message()
      ..from = const Address(_smtpUser, 'DEVMOB-EduLycee')
      ..recipients.add(toEmail)
      ..subject = 'Bienvenue sur DEVMOB-EduLycee 🎓'
      ..html = _buildWelcomeHtml(userName, role, toEmail);

    try {
      await send(message, _smtpServer);
      return true;
    } catch (e) {
      debugPrint('Erreur envoi email: $e');
      return false;
    }
  }

  /// Envoyer un e-mail de notification de connexion Google
  static Future<bool> sendGoogleSignInNotification({
    required String toEmail,
    required String userName,
  }) async {
    final message = Message()
      ..from = const Address(_smtpUser, 'DEVMOB-EduLycee')
      ..recipients.add(toEmail)
      ..subject = 'Nouvelle connexion Google - DEVMOB-EduLycee'
      ..html = _buildGoogleSignInHtml(userName);

    try {
      await send(message, _smtpServer);
      return true;
    } catch (e) {
      debugPrint('Erreur envoi email Google notification: $e');
      return false;
    }
  }

  /// Envoyer un e-mail personnalisé
  static Future<bool> sendCustomEmail({
    required String toEmail,
    required String subject,
    required String htmlBody,
  }) async {
    final message = Message()
      ..from = const Address(_smtpUser, 'DEVMOB-EduLycee')
      ..recipients.add(toEmail)
      ..subject = subject
      ..html = htmlBody;

    try {
      await send(message, _smtpServer);
      return true;
    } catch (e) {
      debugPrint('Erreur envoi email: $e');
      return false;
    }
  }

  static String _buildWelcomeHtml(String userName, String role, String email) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Segoe UI', Roboto, sans-serif; background: #f5f6fa; margin: 0; padding: 20px; }
    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .header { background: linear-gradient(135deg, #1B2A4A, #2C3E6B); padding: 40px 30px; text-align: center; }
    .header h1 { color: white; margin: 0; font-size: 28px; }
    .header p { color: rgba(255,255,255,0.7); margin: 8px 0 0; }
    .icon { font-size: 48px; margin-bottom: 12px; }
    .body { padding: 30px; }
    .body h2 { color: #1B2A4A; margin-top: 0; }
    .body p { color: #6B7B8D; line-height: 1.6; }
    .info-box { background: #f5f6fa; border-radius: 12px; padding: 20px; margin: 20px 0; }
    .info-box p { margin: 6px 0; color: #1B2A4A; }
    .info-box strong { color: #E67E22; }
    .footer { background: #f5f6fa; padding: 20px 30px; text-align: center; }
    .footer p { color: #6B7B8D; font-size: 13px; margin: 4px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="icon">🎓</div>
      <h1>DEVMOB-EduLycee</h1>
      <p>Gestion Scolaire Lycée</p>
    </div>
    <div class="body">
      <h2>Bienvenue, $userName ! 🎉</h2>
      <p>Votre compte a été créé avec succès sur la plateforme <strong>DEVMOB-EduLycee</strong>.</p>
      <div class="info-box">
        <p>👤 <strong>Nom :</strong> $userName</p>
        <p>📧 <strong>E-mail :</strong> $email</p>
        <p>🏷️ <strong>Rôle :</strong> $role</p>
      </div>
      <p>Vous pouvez dès maintenant vous connecter à l'application et commencer à utiliser toutes les fonctionnalités adaptées à votre profil.</p>
      <p>Si vous avez des questions, n'hésitez pas à contacter l'administration de votre établissement.</p>
    </div>
    <div class="footer">
      <p>© 2026 DEVMOB-EduLycee — Application de Gestion Scolaire</p>
      <p>Cet e-mail a été envoyé automatiquement, merci de ne pas y répondre.</p>
    </div>
  </div>
</body>
</html>
''';
  }

  static String _buildGoogleSignInHtml(String userName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    body { font-family: 'Segoe UI', Roboto, sans-serif; background: #f5f6fa; margin: 0; padding: 20px; }
    .container { max-width: 600px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.08); }
    .header { background: linear-gradient(135deg, #1B2A4A, #2C3E6B); padding: 40px 30px; text-align: center; }
    .header h1 { color: white; margin: 0; font-size: 28px; }
    .body { padding: 30px; }
    .body h2 { color: #1B2A4A; margin-top: 0; }
    .body p { color: #6B7B8D; line-height: 1.6; }
    .footer { background: #f5f6fa; padding: 20px 30px; text-align: center; }
    .footer p { color: #6B7B8D; font-size: 13px; margin: 4px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div style="font-size:48px; margin-bottom:12px;">🔐</div>
      <h1>DEVMOB-EduLycee</h1>
    </div>
    <div class="body">
      <h2>Bonjour $userName,</h2>
      <p>Une connexion via <strong>Google</strong> a été détectée sur votre compte DEVMOB-EduLycee.</p>
      <p>Si vous n'êtes pas à l'origine de cette connexion, veuillez contacter immédiatement l'administration de votre établissement.</p>
    </div>
    <div class="footer">
      <p>© 2026 DEVMOB-EduLycee — Application de Gestion Scolaire</p>
    </div>
  </div>
</body>
</html>
''';
  }
}
