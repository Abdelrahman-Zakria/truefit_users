import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static const String instaPayLink = 'https://ipn.eg/S/oka4ms/instapay/0X3nSB';
  
  // Replace with actual ImgBB API key if available
  static const String _imgBBApiKey = '5a8e1934484d1ac759c8d0598c20ca14';

  final ImagePicker _picker = ImagePicker();

  Future<void> openInstaPay() async {
    final Uri url = Uri.parse(instaPayLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch InstaPay link');
    }
  }

  Future<File?> pickPaymentScreenshot() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  Future<String> uploadScreenshot(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBApiKey'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      
      if (response.statusCode == 200 && json['success'] == true) {
        return json['data']['url'];
      } else {
        throw Exception('Failed to upload image: ${json['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // For local development/testing if API key is missing, 
      // we might want to return a dummy link or throw.
      // Returning a dummy link for now so the user can see the flow.
      if (_imgBBApiKey == 'YOUR_IMGBB_API_KEY') {
        print('WARNING: ImgBB API Key is missing. Returning dummy URL.');
        return 'https://i.ibb.co/dummy-screenshot.png';
      }
      rethrow;
    }
  }
}
