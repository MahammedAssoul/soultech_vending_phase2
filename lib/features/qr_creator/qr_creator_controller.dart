import 'package:flutter/foundation.dart';
import 'package:soultech_vending/core/localization/app_strings.dart';
import 'package:soultech_vending/features/qr_creator/qr_data_type.dart';
import 'package:soultech_vending/features/qr_creator/qr_payload_builder.dart';

/// State of the QR Creator.
enum QrCreatorStatus {
  /// No QR generated yet (placeholder preview).
  initial,

  /// A QR has been generated successfully.
  generated,

  /// The last generate attempt failed.
  error,
}

/// Business logic for the QR Creator screen.
///
/// Follows the app's state pattern: [ChangeNotifier] like
/// [ThemeController]. Keeps payload building and generation state separate
/// from the widgets. Uses plain `setState`-free [ListenableBuilder] in the
/// screen.
class QrCreatorController extends ChangeNotifier {
  QrCreatorController({QrDataType initialType = QrDataType.webUrl})
      : _type = initialType;

  QrDataType _type;
  QrDataType get type => _type;

  QrCreatorStatus _status = QrCreatorStatus.initial;
  QrCreatorStatus get status => _status;

  String _payload = '';
  String get payload => _payload;

  /// Localized content label shown in the preview (e.g. "Web URL").
  String? _contentLabel;
  String? get contentLabel => _contentLabel;

  /// One of [L] error keys when generation failed.
  String? _errorKey;
  String? get errorKey => _errorKey;

  void setType(QrDataType type) {
    if (type == _type) return;
    _type = type;
    _payload = '';
    _status = QrCreatorStatus.initial;
    _errorKey = null;
    _contentLabel = null;
    notifyListeners();
  }

  /// Validates the current input and, when valid, generates the payload
  /// (QR rendering itself is done by the widget via `QrImageView`).
  ///
  /// Returns `true` when the QR was generated.
  bool generate(QrInput input) {
    final errorKey = QrPayloadBuilder.validate(input);
    if (errorKey != null) {
      _status = QrCreatorStatus.error;
      _errorKey = errorKey;
      _payload = '';
      notifyListeners();
      return false;
    }
    try {
      _payload = QrPayloadBuilder.buildPayload(input);
      _contentLabel = QrTypes.localize(input.type);
      _status = QrCreatorStatus.generated;
      _errorKey = null;
      notifyListeners();
      return true;
    } catch (_) {
      _status = QrCreatorStatus.error;
      _errorKey = L.qrGenerateFail;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _payload = '';
    _status = QrCreatorStatus.initial;
    _errorKey = null;
    _contentLabel = null;
    notifyListeners();
  }
}
