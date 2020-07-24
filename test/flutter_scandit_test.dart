import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_scandit/flutter_scandit.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_scandit');

  BarcodeCaptureSettings barcodeCaptureSettings=BarcodeCaptureSettings();
  CameraSettings cameraSettings=CameraSettings(VideoResolution.AUTO);

  final FlutterScandit plugin = FlutterScandit(licenseKey: "123", barcodeCaptureSettings: barcodeCaptureSettings, cameraSettings: cameraSettings);

  setUp(() {
    
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('scanBarcode', () async {
    expect(await plugin.scanBarcode(), '42');
  });
}
