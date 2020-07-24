import 'package:flutter/material.dart';
import 'package:flutter_scandit/flutter_scandit.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BarcodeScanPage(),
    );
  }
}

class BarcodeScanPage extends StatefulWidget {
  @override
  _BarcodeScanPageState createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  BarcodeResult barcode;

  Future<void> _showError(BuildContext context, String errorMessage) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Barcode scan error'),
          content: Text(errorMessage ?? "Unknown error"),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Scandit example app'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () async {
                try {
                  BarcodeCaptureSettings barcodeCaptureSettings=BarcodeCaptureSettings();
                  CameraSettings cameraSettings=CameraSettings(VideoResolution.AUTO);

                  BarcodeResult result = await FlutterScandit(licenseKey: "AbHeeiyWM0OzLKPuUhhvcYtBK8IZEYmAAgxvon8T25WpdLOhOW8jZ0hKQQY7Tr/suEacZSgY/AfFUNBqdXIeFzRj5V2DZYpmlnpHmQBgz/BJQuecJgXC0eA0YG1dRF2yCh4bSf0wHSHGoUt9nTczkTCfY8QKsIIt0Cd8N4nBdZ3Nk9sTKEkfRKDQdCpl9/8NFZWuSIbu7CPBxqIbcdCRVaO2itEls2deK3fFYaXOiK3uxspoqu5n5k2nLRN9rlxVJgWwmDQfDvA4OCImB/gPhx/yhBmqgqFgLQSFUNEfxBydDMSyLn3m9uLMciRRZMVI/tFPJBQgdbJs1CB3ee5WkYf8NDxhz6jVAbFz2I9/k3bikBkV+pEH7SoNnT+vEmc47ru9xx7TkRikbi8HUrZdRtYx0aFefRhjshUPjuVJy+3fvwuNj+5VCU1AfQqmXqSidDAbMPHIGAdijvcn3K/ftWNLClMI8x2Ci+OEv24TdoyLXj9Y8X0KI0DrRTqgoy2PAU7GKQu+dOjiAgiaDWnIY56dVZTmq5Zy23Kflydx83ivuDYMvnY7Hp91FwBR1amzt8y9n64QjVgD+wqV/e8y19Qlevv0VkD1NpYnGEs4soooCD/eRF7seKnB6lKt8A/sqo/LOzsBnIx5J3kstPFHgTvyNs17le9VVEcrpfluyUBw+0CazFJ6PG1TmRR9FEsf4yyyZPYCjvlolWcUtWYWj0hNQEXTIN5+hNB810BpfA+0zJMawD1C9yEQ/yM1mJChT61Syh+IBEF+wH2RzlFCnXDaFFgsMgWSTOWGz8dUDC/UsM0Iug3j",
                    barcodeCaptureSettings: barcodeCaptureSettings,
                    cameraSettings: cameraSettings)
                      .scanBarcode();
                  setState(() {
                    barcode = result;
                  });
                } on BarcodeScanException catch (e) {
                  _showError(context, e.toString());
                }
              },
              child: Text('SCAN'),
            ),
            SizedBox(
              height: 32,
            ),
            barcode != null
                ? Text('${barcode.data} ${barcode.symbology}')
                : Text('please scan a barcode...'),
          ],
        ),
      ),
    );
  }
}
