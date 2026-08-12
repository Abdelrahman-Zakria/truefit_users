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
          // Real 1D Barcode for Member ID
          BarcodeWidget(
            barcode: Barcode.code128(), // Code 128 is versatile and scannable
            data: memberId,
            width: double.infinity,
            height: 80,
            drawText: false,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          Text(
            'TF-2024-$memberId',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
