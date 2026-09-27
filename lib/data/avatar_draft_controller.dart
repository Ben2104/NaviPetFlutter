import 'dart:async';

import 'package:flutter/foundation.dart';

import 'profile_gateway.dart';

/// Tracks the one unsaved avatar upload on the edit-profile screen.
///
/// Uploads go to temporary storage and only become the avatar when a profile
/// update commits them, so every upload this screen abandons (replaced by a
/// newer pick, or left behind on cancel) is discarded on the server.
class AvatarDraftController extends ChangeNotifier {
  AvatarDraftController(this._gateway);

  static const maxBytes = 5 * 1024 * 1024;
  static const tooLargeMessage = 'Image must be 5 MB or smaller.';
  static const unsupportedMessage = 'Use a JPEG, PNG, or WebP image.';
  static const expiredMessage =
      'That photo is no longer available. Please choose it again.';
  static const failedMessage = 'Could not upload that photo. Please try again.';

  final ProfileGateway _gateway;

  /// Bumped by every pick and by [discard]; an upload whose generation is no
  /// longer current was superseded and must not touch the draft.
  int _generation = 0;
  bool _uploading = false;
  String? _uploadId;
  String? _previewUrl;
  String? _error;
  bool _disposed = false;

  bool get isUploading => _uploading;
  String? get pendingUploadId => _uploadId;
  String? get previewUrl => _previewUrl;
  String? get errorMessage => _error;

  /// Uploads a picked image, replacing (and discarding) any earlier one.
  /// Returns the user-facing error when this upload failed and was not
  /// superseded by a newer pick in the meantime; otherwise `null`.
  Future<String?> upload(List<int> bytes, String filename) async {
    if (_disposed) return null;
    final generation = ++_generation;
    _discardPending();
    _previewUrl = null;
    _error = null;
    if (bytes.length > maxBytes) {
      _uploading = false;
      _error = tooLargeMessage;
      _notify();
      return _error;
    }
    _uploading = true;
    _notify();
    try {
      final upload = await _gateway.uploadAvatar(
        bytes: bytes,
        filename: filename,
      );
      if (generation != _generation) {
        unawaited(_discardQuietly(upload.uploadId));
        return null;
      }
      _uploadId = upload.uploadId;
      _previewUrl = upload.avatarUrl;
      return null;
    } on Object catch (error) {
      if (generation != _generation) return null;
      _error = error is ProfileApiException
          ? switch (error.statusCode) {
              413 => tooLargeMessage,
              415 => unsupportedMessage,
              0 || 408 => error.message,
              _ => failedMessage,
            }
          : failedMessage;
      return _error;
    } finally {
      if (generation == _generation) {
        _uploading = false;
        _notify();
      }
    }
  }

  /// Hands the pending upload to a profile update. From here on the draft no
  /// longer owns it, so leaving the screen mid-save cannot discard an upload
  /// the update is committing. Pair with [restoreAfterFailedCommit].
  String? takeForCommit() {
    final uploadId = _uploadId;
    _uploadId = null;
    return uploadId;
  }

  /// Returns an upload after its profile update failed. [expired] means the
  /// server no longer has it, so the user has to pick again.
  void restoreAfterFailedCommit(String uploadId, {required bool expired}) {
    // A newer pick replaced this upload while the update ran, or the screen
    // is gone. The update may have committed it before failing (e.g. a
    // timeout), so it is left for the server's 24-hour cleanup rather than
    // discarded.
    if (_disposed || _uploadId != null) return;
    if (expired) {
      _previewUrl = null;
      _error = expiredMessage;
    } else {
      _uploadId = uploadId;
    }
    _notify();
  }

  /// Abandons the draft: an in-flight upload is discarded when it lands and a
  /// finished one is discarded now. Fire-and-forget; the server also deletes
  /// pending uploads after 24 hours.
  void discard() {
    _generation++;
    _uploading = false;
    _discardPending();
    _previewUrl = null;
    _notify();
  }

  void _discardPending() {
    final uploadId = _uploadId;
    _uploadId = null;
    if (uploadId != null) unawaited(_discardQuietly(uploadId));
  }

  Future<void> _discardQuietly(String uploadId) async {
    try {
      await _gateway.discardAvatarUpload(uploadId);
    } on Object {
      // Best effort: the server removes abandoned uploads after 24 hours.
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    discard();
    super.dispose();
  }
}
