import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

void main() async {
  const String cloudName = 'dpcjk1tab'; 
  const String apiKey = '263482225152376';
  const String apiSecret = '8za2qN0Xehd_2cen7tWq0bgCTXE';

  int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String toSign = 'timestamp=$timestamp$apiSecret';
  String signature = sha1.convert(utf8.encode(toSign)).toString();

  var uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
  var request = http.MultipartRequest('POST', uri)
    ..fields['api_key'] = apiKey
    ..fields['timestamp'] = timestamp.toString()
    ..fields['signature'] = signature;
    
  // create dummy file
  File dummy = File('test.txt');
  dummy.writeAsStringSync('dummy content');
  request.files.add(await http.MultipartFile.fromPath('file', dummy.path));

  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  print(response.statusCode);
  print(responseData);
}
