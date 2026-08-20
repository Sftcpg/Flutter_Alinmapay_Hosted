import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'Constantvals.dart';
import 'Model/RespDataModel.dart';
import 'ResponseConfig.dart';

import 'dart:typed_data';

class TransactWebpage extends StatefulWidget {

  final String inURL;

  const TransactWebpage({Key? key,required this.inURL}) : super(key: key);

  @override
  _TransactWebpageState createState() => _TransactWebpageState();
}

class _TransactWebpageState extends State<TransactWebpage> {
  late final WebViewController _controller;

  bool _hasReturnedResult = false;

  double _progress = 0.0;
  String url = "";
  List<RespDataModel> resSplitData = [];

  Future<bool> _onBackPressed() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to go back'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              ResponseConfig.startTrxn = false;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  @override
  void initState() {
    super.initState();


      // Initialize WebViewController
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(NavigationDelegate(
            onProgress: (progress) {
        setState(() {
        _progress = progress / 100;
        });
        },

          onPageStarted: (String url) {
            setState(() {
              this.url = url;
            });
          },
            onPageFinished: (String url) async {
              if (_hasReturnedResult) return;

              if (url.contains("data=")) {
                _hasReturnedResult = true;

                print('Finish Data handling');

                final arr = url.split('?');
                if (arr.length < 2) return;

                final resDataResponse = Uri.decodeComponent(arr[1]);


                final mapData = await RespJson(resDataResponse);


                if (!mounted) return;

                // Let WebView detach safely
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && Navigator.canPop(context)) {
                    Navigator.pop(context, mapData);
                  }
                });
              }
            },

        ));


    // if (Platform.isAndroid) {
    //   _controller
    //
    //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
    //
    //     ..setUserAgent(
    //         "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
    //     );
    // }

    // Load request after applying all settings
    _controller.loadRequest(Uri.parse(widget.inURL));
  }



  @override
  Widget build(BuildContext context)  {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.blueGrey, //or set color with: Color(0xFF0000FF)
    ));
    return new WillPopScope(
      onWillPop: _onBackPressed,
      child:
      Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            title: const Text('Payment', style: TextStyle(color: Colors.black)),
          ),
        body:  Stack(
          children: [
            WebViewWidget(controller: _controller), // ✅ No more uninitialized error
            if (_progress < 1) LinearProgressIndicator(value: _progress),
          ],
        ),
      ),
    );
  }
   //String RespJson(String resultData)
  Future<String>  RespJson(String resultData) async {


    print(resultData);
      List<String> resultParameters = resultData.split("&");
      String finalDecryptedResp ="";

      for(final params in resultParameters)
      {
        List parts = params.split("=");
        String key = parts[0];
        String value = parts[1];
        //  print(key);
        if ([null, "null"].contains(parts[1]))
        {
          value = "";
        }

        if ("data".contains(parts[0])) {
          String strdecoded = parts[1];


          var strkey = Constantvals.merchantkey;


          String decodedResponse = Uri.decodeFull(strdecoded);
          String finalResp = await decodeAndDecryptV2(decodedResponse, strkey);

          finalDecryptedResp = finalResp ;
         }
      }

      print("FINAL RESPONSE 2 $finalDecryptedResp");

      return finalDecryptedResp;


    }


  Future<String> decodeAndDecryptV2(String encryptedResponse, String merKey) async {
    // Convert hex string to Uint8List
    final byteArray11 = hexStringToBytes(merKey);




    // Create the encryption key
    final secretKey = encrypt.Key(byteArray11);

    // Decrypt the data
    String decryptedData = decryptData(encryptedResponse, secretKey);


    print("Decrypted Data: $decryptedData");

    return decryptedData;
  }

  Uint8List hexStringToBytes(String hexString) {
    final len = hexString.length;
    final List<int> bytes = [];

    for (int i = 0; i < len; i += 2) {
      bytes.add(int.parse(hexString.substring(i, i + 2), radix: 16));
    }

    // Convert List<int> to Uint8List
    return Uint8List.fromList(bytes);
  }

  String decryptData(String encodedText, encrypt.Key secretKey) {
    int remainder = encodedText.length % 4;
    if (remainder != 0) {
      encodedText = encodedText.padRight(encodedText.length + (4 - remainder), '=');
    }



    // Base64 decode the encoded text
    final decodedBytes = base64.decode(encodedText);

    // Initialize the AES cipher with ECB mode and PKCS7 padding
    final encrypter = encrypt.Encrypter(encrypt.AES(
      secretKey,
      mode: encrypt.AESMode.ecb,
      padding: 'PKCS7',
    ));

    // Decrypt the bytes
    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(decodedBytes), );

    // Convert decrypted bytes to a UTF-8 string
    return utf8.decode(decryptedBytes);
  }

// Function to convert Uint8List to signed byte list
  List<int> toSignedByteList(Uint8List uint8List) {
    return uint8List.map((byte) => byte > 127 ? byte - 256 : byte).toList();
  }

  }
