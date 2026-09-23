// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get logout_button => 'Abmelden';

  @override
  String get note => 'Notiz';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get yes => 'Ja';

  @override
  String get delete => 'Löschen';

  @override
  String get sharing => 'Teilen';

  @override
  String get ok => 'OK';

  @override
  String get login => 'Einloggen';

  @override
  String get verify_email => 'E-Mail verifizieren';

  @override
  String get register => 'Registrieren';

  @override
  String get restart => 'Neustarten';

  @override
  String get start_typing_your_note =>
      'Fangen Sie an, Ihre Notiz zu schreiben...';

  @override
  String get delete_note_prompt =>
      'Sind Sie sicher, dass Sie diese Notiz löschen möchten?';

  @override
  String get cannot_share_empty_note_prompt =>
      'Sie können keine leere Notiz teilen!';

  @override
  String get generic_error_prompt => 'Ein Fehler ist aufgetreten.';

  @override
  String get logout_dialog_prompt =>
      'Sind Sie sicher, dass Sie sich abmelden möchten?';

  @override
  String get password_reset => 'Passwort zurücksetzen';

  @override
  String get password_reset_dialog_prompt =>
      'Wir haben Ihnen einen Link zum Zurücksetzen gesendet. Bitte überprüfen Sie Ihre E-Mails.';

  @override
  String get login_error_cannot_find_user =>
      'Benutzer mit den angegebenen Daten wurde nicht gefunden.';

  @override
  String get login_error_wrong_credentials => 'Falsche Anmeldedaten!';

  @override
  String get login_error_auth_error => 'Authentifizierungsfehler aufgetreten!';

  @override
  String get login_view_prompt =>
      'Bitte loggen Sie sich ein, um Ihre Notizen zu sehen!';

  @override
  String get login_view_forgot_password => 'Passwort vergessen?';

  @override
  String get login_view_not_registered_yet =>
      'Noch nicht registriert? Hier registrieren!';

  @override
  String get name_text_field_placeholder => 'Geben Sie Ihre Name ein';

  @override
  String get email_text_field_placeholder =>
      'Geben Sie Ihre E-Mail-Adresse ein';

  @override
  String get password_text_field_placeholder => 'Geben Sie Ihr Passwort ein';

  @override
  String get forgot_password => 'Passwort vergessen';

  @override
  String get forgot_password_view_generic_error =>
      'Wir konnten Ihre Anfrage nicht bearbeiten. Bitte versuchen Sie es erneut.';

  @override
  String get forgot_password_view_prompt =>
      'Wenn Sie Ihr Passwort vergessen haben, geben Sie Ihre E-Mail-Adresse ein, damit wir Ihnen einen Link senden können.';

  @override
  String get forgot_password_view_send_me_link => 'Link senden';

  @override
  String get forgot_password_view_back_to_login =>
      'Zurück zum Login-Bildschirm';

  @override
  String get register_error_weak_password =>
      'Ihr Passwort ist nicht sicher genug. Bitte wählen Sie ein stärkeres Passwort.';

  @override
  String get register_error_email_already_in_use =>
      'Die eingegebene E-Mail-Adresse wird bereits verwendet. Bitte versuchen Sie es erneut.';

  @override
  String get register_error_generic =>
      'Registrierung fehlgeschlagen. Bitte versuchen Sie es später noch einmal.';

  @override
  String get register_error_invalid_email =>
      'Dies scheint keine gültige E-Mail-Adresse zu sein. Bitte versuchen Sie es erneut.';

  @override
  String get register_view_prompt =>
      'Bitte geben Sie Ihre Name, E-Mail-Adresse und Ihr Passwort ein, um sich zu registrieren!';

  @override
  String get register_view_already_registered =>
      'Bereits registriert? Hier einloggen!';

  @override
  String get verify_email_view_prompt =>
      'Wir haben Ihnen eine Bestätigungs-E-Mail gesendet. Bitte öffnen Sie diese, um Ihr Konto zu aktivieren.';

  @override
  String get verify_email_send_email_verification =>
      'Bestätigungs-E-Mail erneut senden';

  @override
  String notes_title(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen',
      one: '1 Notiz',
      zero: 'Keine Notizen',
    );
    return '$_temp0';
  }
}
