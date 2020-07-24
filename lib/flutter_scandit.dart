import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:enum_to_string/enum_to_string.dart';

part 'models/symbology.dart';
part 'utils/symbology_utils.dart';
part 'models/barcode_result.dart';
part 'models/exception.dart';
part 'models/enumeration.dart';

class FlutterScandit {
  static const MethodChannel _channel = const MethodChannel('flutter_scandit');

  static const String _licenseKeyField = "licenseKey";
  static const String _barcodeCaptureSettingsField = "barcodeCaptureSettings";
  static const String _cameraSettingsField = "cameraSettings";

  // errors
  static const String _errorNoLicence = "MISSING_LICENCE";
  static const String _errorPermissionDenied = "CAMERA_PERMISSION_DENIED";
  static const String _errorCameraInitialisation = "CAMERA_INITIALISATION_ERROR";
  static const String _errorNoCamera = "NO_CAMERA";
  static const String _errorUnknown = "UNKNOWN_ERROR";

  final String licenseKey;

  CameraSettings cameraSettings;
  BarcodeCaptureSettings barcodeCaptureSettings;


  final BarcodeCaptureSettings defaultBarcodeCaptureSettings =  BarcodeCaptureSettings();
  final CameraSettings defaultCameraSettings = CameraSettings(VideoResolution.AUTO);


  FlutterScandit({this.licenseKey,this.barcodeCaptureSettings,this.cameraSettings}){
    barcodeCaptureSettings = barcodeCaptureSettings ?? defaultBarcodeCaptureSettings;
    cameraSettings = cameraSettings ?? defaultCameraSettings;
  }

  /// Scan barcode using camera and get a `BarcodeResult` back
  Future<BarcodeResult> scanBarcode() async {

    Map<String, dynamic> arguments = {
      _licenseKeyField: licenseKey,
      _barcodeCaptureSettingsField: jsonEncode(barcodeCaptureSettings),
      _cameraSettingsField:jsonEncode(cameraSettings)
    };

    try {
      var result = await _channel.invokeMethod('scanBarcode', arguments);
      final Map<String, dynamic> barcode = Map<String, dynamic>.from(result);

      return BarcodeResult(
        data: barcode["data"],
        symbology: SymbologyUtils.getSymbology(barcode["symbology"] as String),
      );
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      throw _resolveException(e);
    }
  }

  static BarcodeScanException _resolveException(PlatformException e) {
    switch (e.code) {
      case _errorNoLicence:
        return MissingLicenceException.fromPlatformException(e);
      case _errorPermissionDenied:
        return CameraPermissionDeniedException.fromPlatformException(e);
      case _errorCameraInitialisation:
        return CameraInitialisationException.fromPlatformException(e);
      case _errorNoCamera:
        return NoCameraException.fromPlatformException(e);
      case _errorUnknown:
        return BarcodeScanException.fromPlatformException(e);
      default:
        return BarcodeScanException(
            e.message ?? e.code ?? BarcodeScanException.defaultErrorMessage);
    }
  }
}

class CameraSettings {
  VideoResolution preferredResolution;
  double maxFrameRate;
  double zoomFactor;
  bool shouldPreferSmoothAutoFocus;

  static const VideoResolution defaultResolution=VideoResolution.AUTO;
  static const double defaultMaxFrameRate=60;
  static const double defaultZoomFactor=0;
  static const bool defaultShouldPreferSmoothAutoFocus=false;

  CameraSettings(this.preferredResolution , {this.maxFrameRate = defaultMaxFrameRate, this.zoomFactor = defaultZoomFactor, this.shouldPreferSmoothAutoFocus = defaultShouldPreferSmoothAutoFocus});

  Map<String, dynamic> toJson(){
    return {
      'preferredResolution': EnumToString.parse(preferredResolution),
      'maxFrameRate': maxFrameRate,
      'zoomFactor': zoomFactor,
      'shouldPreferSmoothAutoFocus': shouldPreferSmoothAutoFocus
    };
  }
}

class BarcodeCaptureSettings {
  List<Symbology> symbologies;
  double codeDuplicateFilter;

  static const List<Symbology> defaultSymbologoes = [Symbology.EAN13_UPCA, Symbology.CODE39, Symbology.CODE128, Symbology.DATA_MATRIX, Symbology.QR];
  static const double defaultCodeDuplicateFilter =  0;

  BarcodeCaptureSettings({this.symbologies = defaultSymbologoes, this.codeDuplicateFilter = defaultCodeDuplicateFilter});

  Map<String, dynamic> toJson(){
    return{
      'symbologies':encodeToJson(symbologies),
      'codeDuplicateFilter':codeDuplicateFilter
    };
  }

  static List encodeToJson(List<Symbology> list){
    List jsonList = List();
    list.map( (item) => jsonList.add(EnumToString.parse(item))
      ).toList();
    return jsonList;
  }
}

class TimeInterval {
  final double seconds;

  TimeInterval({this.seconds = 0});
}
