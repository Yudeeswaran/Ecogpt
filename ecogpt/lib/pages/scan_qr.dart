import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  _QRScanScreenState createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  String qrCodeResult = "Scan a QR code";
  bool _isAlertVisible = false; // Flag to control alert visibility

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> _sendQRCodeData(String qrUrl) async {
    const String apiUrl = "${AppConfig.baseUrl}/check_in_out";

    // Hardcoded values for demonstration
    Map<String, dynamic> requestBody = {
      "qr_url": qrUrl,
      "user_id": "2",
      "lat": 3,
      "lon": 4,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        _showAlert(responseData["message"]);
      } else {
        Map<String, dynamic> errorData = jsonDecode(response.body);
        _showAlert("Error: ${errorData["message"]}");
      }
    } catch (e) {
      _showAlert("Failed to connect to the server: $e");
    }
  }

  void _showAlert(String message) {
    if (!_isAlertVisible) {
      _isAlertVisible = true; // Set flag to true when alert is shown

      showDialog(
        context: context,
        builder:
            (BuildContext context) => AlertDialog(
              title: const Text("QR Scan Result"),
              content: Text(message),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    _isAlertVisible =
                        false; // Reset flag when alert is dismissed
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                if (barcode.rawValue != null && !_isAlertVisible) {
                  setState(() {
                    qrCodeResult = barcode.rawValue!;
                  });
                  _sendQRCodeData(qrCodeResult); // Send to Flask API
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(qrCodeResult, style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
