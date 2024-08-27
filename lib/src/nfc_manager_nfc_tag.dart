import 'dart:async';
import 'dart:typed_data';

import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart' as ident;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import 'platform_tag_type.dart';

class _PlatformTag {
  final Future<Uint8List?> Function()? _identifierAccessor;
  final Future<Uint8List?> Function()? _getAt;
  final Future<Uint8List?> Function(Uint8List data)? _transceive;

  _PlatformTag(
      {required Future<Uint8List?> Function() identifierAccessor,
      required Future<Uint8List?> Function()? getAt,
      required Future<Uint8List?> Function(Uint8List data)? transceive})
      : _identifierAccessor = identifierAccessor,
        _getAt = getAt,
        _transceive = transceive;

  Future<Uint8List?> get identifier async => await _identifierAccessor?.call();

  Future<Uint8List?> getAt() async => await _getAt?.call();

  Future<Uint8List?> transceive(Uint8List data) async =>
      await _transceive?.call(data);
}

/// Implementation of the [ident.NfcTag] interface based on nfc_manager.
class NfcManagerNfcTag extends ident.NfcTag {
  //TODO: implement other platform tag types
  // _PlatformTag? _platformTag;
  // Future<bool> _isInitialized = Future.value(false);

  /// Create a [NfcManagerNfcTag] from the nfc_manager [NfcTag] and its handle.
  NfcManagerNfcTag({required super.handle, required super.raw});
  //
  // static Future<_PlatformTag?> _getSpecificPlatformTag(
  //     dynamic raw, ident.PlatformTagType tagType) {
  //   switch (tagType) {
  //     case ident.PlatformTagType.ndef:
  //       return _ndef(raw);
  //     case ident.PlatformTagType.isoDep:
  //       return _isoDep(raw);
  //     case ident.PlatformTagType.feliCa:
  //       return _feliCa(raw);
  //     case ident.PlatformTagType.nfcA:
  //       return _nfcA(raw);
  //     case ident.PlatformTagType.nfcB:
  //       return _nfcB(raw);
  //     case ident.PlatformTagType.ndefFormattable:
  //       return _ndefFormattable(raw);
  //     case ident.PlatformTagType.iso7816:
  //       return _iso7816(raw);
  //     case ident.PlatformTagType.iso15693:
  //       return _iso15693(raw);
  //     case ident.PlatformTagType.nfcF:
  //       return _nfcF(raw);
  //     case ident.PlatformTagType.nfcV:
  //       return _nfcV(raw);
  //     case ident.PlatformTagType.mifareClassic:
  //       return _mifareClassic(raw);
  //     case ident.PlatformTagType.mifareClassic:
  //       return _mifareClassic(raw);
  //     case ident.PlatformTagType.mifare:
  //       return _mifare(raw);
  //     case ident.PlatformTagType.mifareUltralight:
  //       return _mifareUltralight(raw);
  //   }
  // }
  //
  // Future<_PlatformTag?> _autoDetectPlatformTag(dynamic raw) async {
  //   // await each call immediately to avoid conflicting access to the tag
  //   for (Future<_PlatformTag?> Function(dynamic) accessor
  //       in _platformAccessors) {
  //     try {
  //       final tag = await accessor(raw);
  //       if (tag != null) {
  //         _setPlatformTag(tag);
  //         return tag;
  //       }
  //     } catch (error) {
  //       continue;
  //     }
  //   }
  //   return null;
  // }

  /// Sets the underlying technical connection.
  ///
  /// Returns true if the connection type is supported by the tag.
  /// Currently only IsoDep is supported.
  Future<bool> trySetPlatformTag(PlatformTagType tagType) async {
    return tagType == PlatformTagType.isoDep;
    // final isInitialized = await _isInitialized;
    // if (!isInitialized) {
    //   return _isInitialized =
    //       _getSpecificPlatformTag(raw, tagType).then((platformTag) {
    //     if (platformTag != null) {
    //       _setPlatformTag(platformTag);
    //       return true;
    //     }
    //     return false;
    //   });
    // }
    //
    // return _getSpecificPlatformTag(raw, tagType).then((platformTag) {
    //   if (platformTag != null) {
    //     _setPlatformTag(platformTag);
    //     return true;
    //   }
    //   return false;
    // });
  }
  //
  // void _setPlatformTag(_PlatformTag platformTag) {
  //   _platformTag = platformTag;
  // }
  //
  // Future<_PlatformTag?> _getOrDetectPlatformTag() async {
  //   final isInitialized = await _isInitialized;
  //   if (isInitialized) {
  //     return _platformTag;
  //   }
  //
  //   final completer = Completer<bool>();
  //   _isInitialized = completer.future;
  //   final platformTag = await _autoDetectPlatformTag(raw);
  //   if (platformTag != null) {
  //     _setPlatformTag(platformTag);
  //   }
  //   // we set initialized to true, even if we did not detect any plaform tag.
  //   // this way we avoid rescanning all technologies.
  //   // this case should never happen, as we need some technology to detect
  //   // the tag in the first place
  //   completer.complete(true);
  //   return platformTag;
  // }

  @override
  Future<Uint8List?> getAt() async {
    final tag = await _isoDep(raw);
    return await tag?.getAt();
  }

  @override
  Future<Uint8List?> get identifier async {
    final tag = await _isoDep(raw);
    return tag?.identifier;
  }

  @override
  Future<Uint8List?> transceive(Uint8List data) async {
    final tag = await _isoDep(raw);
    return await tag?.transceive(data);
  }
}

// all supported identifier accessors ordered by the ones
// with the most supported capabilities first
// const List<Future<_PlatformTag?> Function(dynamic)> _platformAccessors = [
//   _isoDep,
//   _ndef,
//   _feliCa,
//   _nfcA,
//   _nfcB,
//   _ndefFormattable,
//   _iso7816,
//   _iso15693,
//   _nfcF,
//   _nfcV,
//   _mifareClassic,
//   _mifare,
//   _mifareUltralight,
// ];
//
// Future<_PlatformTag?> _ndef(dynamic raw) async {
//   final platformTag = Ndef.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async {
//         final message = await platformTag.read();
//         final identifier = message.records.firstOrNull?.identifier;
//         return identifier;
//       },
//       getAt: null,
//       transceive: null);
// }

// android formats

Future<_PlatformTag?> _isoDep(dynamic raw) async {
  final platformTag = IsoDep.from(raw);
  if (platformTag == null) {
    return null;
  }

  return _PlatformTag(
      identifierAccessor: () async => platformTag.identifier,
      getAt: () async =>
          platformTag.historicalBytes ?? // used in NfcA underlying tech
          platformTag.hiLayerResponse, // used in NfcB underlying tech,
      transceive: (data) async => await platformTag.transceive(data: data));
}
//
// Future<_PlatformTag?> _nfcA(dynamic raw) async {
//   final platformTag = NfcA.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _nfcB(dynamic raw) async {
//   final platformTag = NfcB.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _nfcF(dynamic raw) async {
//   final platformTag = NfcF.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _nfcV(dynamic raw) async {
//   final platformTag = NfcV.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _ndefFormattable(dynamic raw) async {
//   final platformTag = NdefFormattable.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _mifareClassic(dynamic raw) async {
//   final platformTag = MifareClassic.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _mifareUltralight(dynamic raw) async {
//   final platformTag = MifareUltralight.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// // ios formats
//
// Future<_PlatformTag?> _feliCa(dynamic raw) async {
//   final platformTag = FeliCa.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.currentIDm,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _iso7816(dynamic raw) async {
//   final platformTag = Iso7816.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _iso15693(dynamic raw) async {
//   final platformTag = Iso15693.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
//
// Future<_PlatformTag?> _mifare(dynamic raw) async {
//   final platformTag = MiFare.from(raw);
//   if (platformTag == null) {
//     return null;
//   }
//
//   return _PlatformTag(
//       identifierAccessor: () async => platformTag.identifier,
//       getAt: () async => null,
//       transceive: (data) async => null);
// }
