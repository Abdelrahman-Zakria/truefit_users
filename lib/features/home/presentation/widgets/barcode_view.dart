import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class BarcodeView extends StatelessWidget {
  final String memberId;
  const BarcodeView({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // QR Code encoding the raw numeric pers_ID (e.g. "50392")
          BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: memberId,
            width: 140,
            height: 140,
            drawText: false,
            color: Colors.black,
          ),
          const SizedBox(height: 16),
          // Barcode encoding the raw numeric pers_ID
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: memberId,
            width: double.infinity,
            height: 50,
            drawText: false,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Text(
            memberId,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }
}
