import 'package:firebase_test/l10n/app_localizations.dart';
import 'package:flutter/material.dart' show BuildContext;

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}
