import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart' as ident;
import 'package:nfc_manager/nfc_manager.dart';

import 'nfc_manager_nfc_tag.dart';
import 'platform_tag_type.dart';

/// [NfcScanner] implementation based on nfc_manager.
///
/// Allows reading NFC tags and converts them to the ad_hoc_ident interface
/// types. Currently only supports IsoDep format.
class NfcManagerNfcScanner implements ident.NfcScanner {
  final StreamController<AdHocIdentity?> _controller =
      StreamController.broadcast();

  @override
  AdHocIdentityDetector<ident.NfcTag> detector;

  @override
  AdHocIdentityEncrypter encrypter;

  /// The preferred tag format when connecting to a tag.
  ///
  /// Currently only IsoDep is supported.
  List<PlatformTagType> preferredTagTypes;

  /// Creates a [NfcManagerNfcScanner].
  ///
  /// Detected NFC tags are passed to the [detector]. Detected identities are
  /// passed to the [encrypter]. Specify the technical connection to use when
  /// connecting to tags by the [preferredTagTypes]. The scanner attempts to
  /// connect using the [preferredTagTypes] in order, until the first one is
  /// successful.
  NfcManagerNfcScanner(
      {required this.detector,
      required this.encrypter,
      this.preferredTagTypes = const []});

  void _ignoreError(Object error, StackTrace stackStrace) {}

  @override
  void close() {
    _controller.close();
  }

  @override
  Future<bool> isAvailable() => NfcManager.instance.isAvailable();

  /// Stops and restarts listening for NFC tags.
  ///
  /// If the [NfcScanner] was stopped before and is not running,
  /// this can safely be used to restart the [NfcScanner].
  /// Retries to connect to the NFC service until [gracePeriod] expires.
  @override
  Future<void> restart(
      [Duration gracePeriod = const Duration(seconds: 1)]) async {
    await stop().catchError(_ignoreError);
    return await start(gracePeriod);
  }

  /// Starts listening for NFC tags.
  ///
  /// Retries to connect to the NFC service until [gracePeriod] expires.
  @override
  Future<void> start(
      [Duration gracePeriod = const Duration(seconds: 1)]) async {
    final timestamp = DateTime.timestamp();
    final delay = gracePeriod.inMilliseconds > 100
        ? const Duration(milliseconds: 100)
        : gracePeriod;
    bool available;
    do {
      available = await isAvailable();
      if (!available) {
        await Future.delayed(delay);
      }
    } while (
        !available && timestamp.difference(DateTime.timestamp()) < gracePeriod);

    await NfcManager.instance.startSession(onDiscovered: (tag) async {
      final identTag = await _toIdentTag(tag);
      try {
        final identity = await detector.detect(identTag);
        if (identity == null) {
          _controller.add(null);
          return;
        }
        final encryptedIdentity = await encrypter.encrypt(identity);
        _controller.add(encryptedIdentity);
      } catch (error) {
        _controller.addError(error);
      }
    });
  }

  @override
  Future<void> stop() async {
    await NfcManager.instance.stopSession();
  }

  @override
  Stream<AdHocIdentity?> get stream => _controller.stream;

  Future<ident.NfcTag> _toIdentTag(NfcTag tag) async {
    final nativeTag = NfcManagerNfcTag(
      handle: tag.handle,
      raw: tag,
    );

    // iterate through the preferred tag types until one matches
    for (PlatformTagType tagType in preferredTagTypes) {
      if (await nativeTag.trySetPlatformTag(tagType)) {
        break;
      }
    }
    return nativeTag;
  }
}
