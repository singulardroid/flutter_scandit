package za.co.palota.flutter_scandit;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.scandit.datacapture.barcode.data.Symbology;
import com.scandit.datacapture.core.common.geometry.MeasureUnit;
import com.scandit.datacapture.core.source.VideoResolution;


import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public final class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    private static final String TAG = FlutterScanditPlugin.class.getSimpleName();
    private static final String PLUGIN_CHANNEL = "flutter_scandit";

    // activity request
    private static final int REQUEST_CODE_BARCODE_CAPTURE = 1111;

    // available methods
    public static final String METHOD_SCAN_BARCODE = "scanBarcode";

    // parameters
    public static final String PARAM_SYMBOLOGIES = "symbologies";
    public static final String PARAM_BARCODE_CAPTURE_SETTINGS = "barcodeCaptureSettings";
    public static final String PARAM_CAMERA_SETTINGS = "cameraSettings";
    public static final String PARAM_LICENSE_KEY = "licenseKey";
    public static final String PARAM_LOCATION_SELECTION="locationSelection";

    // errors
    public static final String ERROR_NO_LICENSE = "MISSING_LICENCE";
    public static final String ERROR_PERMISSION_DENIED = "CAMERA_PERMISSION_DENIED";
    public static final String ERROR_CAMERA_INITIALISATION = "CAMERA_INITIALISATION_ERROR";
    public static final String ERROR_NO_CAMERA = "NO_CAMERA";
    public static final String ERROR_UNKNOWN = "UNKNOWN_ERROR";


    private final Activity activity;
    private final BinaryMessenger messenger;
    private final MethodChannel methodChannel;

    private MethodChannel.Result pendingActivityResult;


    public MethodCallHandlerImpl(Activity activity, BinaryMessenger messenger) {
        this.activity = activity;
        this.messenger = messenger;

        methodChannel = new MethodChannel(messenger, PLUGIN_CHANNEL);
        methodChannel.setMethodCallHandler(this);
    }


    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case METHOD_SCAN_BARCODE:
                handleScanBarcodeMethod(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void handleScanBarcodeMethod(MethodCall call, MethodChannel.Result result) {
        Map<String, Object> args = (Map<String, Object>) call.arguments;
        if (args.containsKey(PARAM_LICENSE_KEY)) {
            Log.i(TAG, "handleScanBarcodeMethod: args "+args);

            String barcodeCaptureSettingsJSON = (String)args.get(PARAM_BARCODE_CAPTURE_SETTINGS);
            //Log.i(TAG, "handleScanBarcodeMethod: barcodeCaptureSettings="+barcodeCaptureSettingsJSON);

            String cameraSettingsJSON = (String)args.get(PARAM_CAMERA_SETTINGS);
            //Log.i(TAG, "handleScanBarcodeMethod: cameraSettings="+cameraSettingsJSON);

            startBarcodeScanner((String) args.get(PARAM_LICENSE_KEY), barcodeCaptureSettingsJSON,
                    cameraSettingsJSON, result);


        } else {
            result.error(ERROR_NO_LICENSE, null, null);
        }
    }

    private void startBarcodeScanner(String licenseKey, String barcodeCaptureSettingsJSON,
                                     String cameraSettingsJSON,
                                     MethodChannel.Result result) {
        try {
            this.pendingActivityResult = result;
            Intent intent = new Intent(activity, BarcodeScanActivity.class);
            intent.putExtra(PARAM_LICENSE_KEY, licenseKey);
            intent.putExtra(PARAM_BARCODE_CAPTURE_SETTINGS, barcodeCaptureSettingsJSON);
            intent.putExtra(PARAM_CAMERA_SETTINGS, cameraSettingsJSON);
//            intent.putStringArrayListExtra(PARAM_SYMBOLOGIES, symbologies);
            activity.startActivityForResult(intent, REQUEST_CODE_BARCODE_CAPTURE);
        } catch (Exception e) {
            result.error(ERROR_UNKNOWN, e.getMessage(), null);
            this.pendingActivityResult = null;
            Log.e(TAG, METHOD_SCAN_BARCODE + ": " + e.getLocalizedMessage());
        }
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE_BARCODE_CAPTURE:
                if (this.pendingActivityResult != null) { // if we are awaiting a response
                    handleBarcodeScanResult(resultCode, data, this.pendingActivityResult);
                    this.pendingActivityResult = null; // reset
                }
                break;
            default:
                return false;
        }
        return true;
    }

    private void handleBarcodeScanResult(int resultCode, Intent data, MethodChannel.Result channelResult) {
        if (resultCode == Activity.RESULT_OK) {
            try {
                String barcode = data.getStringExtra(BarcodeScanActivity.BARCODE_DATA);
                String symbology = data.getStringExtra(BarcodeScanActivity.BARCODE_SYMBOLOGY);
                Map<String, String> result = new HashMap<String, String>();
                result.put("data", barcode);
                result.put("symbology", symbology);
                channelResult.success(result);
            } catch (Exception e) {
                channelResult.error(ERROR_UNKNOWN, e.toString(), null);
            }
        } else if (resultCode == Activity.RESULT_CANCELED && data != null && data.hasExtra(BarcodeScanActivity.BARCODE_ERROR)) {
            String errorCode = data.getStringExtra(BarcodeScanActivity.BARCODE_ERROR);
            String errorMessage = data.hasExtra(BarcodeScanActivity.EXCEPTION_MESSAGE) ? data.getStringExtra(BarcodeScanActivity.EXCEPTION_MESSAGE) : null;
            channelResult.error(errorCode, errorMessage, null);
        } else if (resultCode == Activity.RESULT_CANCELED) {
            channelResult.success(new HashMap<String, String>());
        } else {
            channelResult.error(ERROR_UNKNOWN, null, null);
        }
    }

    void stopListening() {
        methodChannel.setMethodCallHandler(null);
    }

    public static MeasureUnit convertToMeasureUnit(String name){
        switch (name) {
            case "PIXEL":
                return MeasureUnit.PIXEL;
            case "DIP":
                return MeasureUnit.DIP;
            case "FRACTION":
                return MeasureUnit.FRACTION;
            default:
                return MeasureUnit.DIP;
        }
    }

    public static VideoResolution convertToVideoResolution(String name){
        switch (name) {
            case "AUTO":
                return VideoResolution.AUTO;
            case "FULL_HD":
                return VideoResolution.FULL_HD;
            case "HD":
                return VideoResolution.HD;
            case "UHD4K":
                return VideoResolution.UHD4K;
            case "HIGHEST":
                return VideoResolution.HIGHEST;
            default:
                return VideoResolution.AUTO;
        }
    }

    public static Symbology convertToSymbology(String name) {
        switch (name) {
            case "EAN13_UPCA":
                return Symbology.EAN13_UPCA;
            case "UPCE":
                return Symbology.UPCE;
            case "EAN8":
                return Symbology.EAN8;
            case "CODE39":
                return Symbology.CODE39;
            case "CODE128":
                return Symbology.CODE128;
            case "CODE11":
                return Symbology.CODE11;
            case "CODE25":
                return Symbology.CODE25;
            case "CODABAR":
                return Symbology.CODABAR;
            case "INTERLEAVED_TWO_OF_FIVE":
                return Symbology.INTERLEAVED_TWO_OF_FIVE;
            case "MSI_PLESSEY":
                return Symbology.MSI_PLESSEY;
            case "QR":
                return Symbology.QR;
            case "DATA_MATRIX":
                return Symbology.DATA_MATRIX;
            case "AZTEC":
                return Symbology.AZTEC;
            case "MAXI_CODE":
                return Symbology.MAXI_CODE;
            case "DOT_CODE":
                return Symbology.DOT_CODE;
            case "KIX":
                return Symbology.KIX;
            case "RM4SCC":
                return Symbology.RM4SCC;
            case "GS1_DATABAR":
                return Symbology.GS1_DATABAR;
            case "GS1_DATABAR_EXPANDED":
                return Symbology.GS1_DATABAR_EXPANDED;
            case "GS1_DATABAR_LIMITED":
                return Symbology.GS1_DATABAR_LIMITED;
            case "PDF417":
                return Symbology.PDF417;
            case "MICRO_PDF417":
                return Symbology.MICRO_PDF417;
            case "MICRO_QR":
                return Symbology.MICRO_QR;
            case "CODE32":
                return Symbology.CODE32;
            case "LAPA4SC":
                return Symbology.LAPA4SC;
            default:
                return null;
        }
    }
}
