library flutter_alinmapay_hosted;

import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:flutter_alinmapay_hosted/payment_request.dart';

import 'package:yaml/yaml.dart';
// import 'dart:html' as html; // Only for Web
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:convert/convert.dart';
import 'package:dart_ipify/dart_ipify.dart';
import 'package:device_info_plus/device_info_plus.dart';


import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';


import 'Constantvals.dart';
import 'Model/DeviceDetailsModel.dart';

import 'Model/PayVoidTrxn.dart';
import 'Model/PaymentReq.dart';

import 'Model/TrxnRespModel.dart';
import 'ResponseConfig.dart';
import 'TransactPage.dart';
import 'package:crypto/crypto.dart';
import 'apple_pay_flutter.dart';
import 'TransactWebpage.dart';

enum DeviceType { Phone, Tablet }

class Payment {

  static Future get _localPath async {
    String? dirPath;
    /**
     * Based on Platform Direct is created
     * */

    if (kIsWeb) {
      print("Running on a Web Browser");
    } else {
      if (Platform.isIOS) {
        print("Running on a iOS");
        final appDirectory = await getApplicationDocumentsDirectory();
        dirPath = appDirectory.path;
      }

      else if (Platform.isAndroid)
      {
        print("Running on a Android");
        // External storage directory: /storage/emulated/0
        final externalDirectory = await getExternalStorageDirectory();
        dirPath = externalDirectory!.path;
      }
    }
    return dirPath;
  }

  static Future get _localFile async {
    final path = await _localPath;
    final folderName = "flutter_plugin";


    return File('$path/RespReqLog.txt');
  }


  /**
   * This method is used to write Response and Request to File
   * */
  // static Future _writetoFile(String text) async {
  //
  //
  //   final file = await _localFile;
  //
  //
  //   var now1 = new DateTime.now();
  //   String datetime = now1.toString();
  //   var header = datetime + ": " + text;
  //   File result = await file.writeAsString(header, mode: FileMode.append);
  //
  //   if (result == null)
  //   {
  //     print("Writing to file failed");
  //   }
  //   else
  //   {
  //
  //   }
  // }

  /**
   * This method is used to check Device Size *****/

  static String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 550 ? "Phone" : "Tablet";
  }


  /**
   *  Read Flutter version
   */

  static Future<String?> getFlutterVersion() async {
    try {
      // Read the pubspec.lock file
      final file = File('pubspec.lock');
      if (await file.exists()) {
        final content = await file.readAsString();
        final yaml = jsonDecode(jsonEncode(loadYaml(content)));

        // Access the Flutter version under 'sdks'
        final sdks = yaml['sdks'];
        return sdks?['flutter'];
      }
    } catch (e) {
      print('Error fetching Flutter version: $e');
    }
    return null;
  }


  /**
   * This method is used to perform Transactions
   * This method takes Transaction Details as @params*****/

  // static Future<String> makepaymentService({
  //   required BuildContext context, required String country, required firstname,required lastname,required String action, required String currency,
  //   required String amt, required String customerEmail, required String trackid, required String address, required String city,
  //   required String zipCode, required String state, required String cardToken,required transid, required String tokenizationType,
  //   required String tokenOperation,required metadata
  // }) async {

  static Future<String> makePayment({
    required BuildContext context,
    required PaymentRequest request,
  }) async {
    assert(context != null, "context is null!!");

    String payRespData = "";
    String instrumentType = "";

    /**
     *  Initial Check for Transaction Processing  *****/
    if (ResponseConfig.startTrxn != Constantvals.appinitiateTrxn) {
      ResponseConfig.startTrxn = true;

      try {
        final List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());





        if ( ! connectivityResult.contains(ConnectivityResult.none) )
        {
          var order = await callAPI(context,request);
          // print('DATTA $order');
          payRespData = order;
        }
        else {
          ResponseConfig.startTrxn = false;
          showalertDailog(context, 'Internet Connection',
              'Please check your Internet Connection  ');
        }
      }
      on SocketException catch (e) {
        print(e);
        ResponseConfig.startTrxn = false;
        showalertDailog(context, 'Alert', "Please check Provided Data");
        //payRespData="Please check internet connection";
      }
    }
    else {
      payRespData = "Transaction already initiated";
    }

    return payRespData;
  }



  /**
   *
   *  Api calling for First leg
   * */
  static Future<String> callAPI(BuildContext context,
   PaymentRequest paymentRequest,
)
  async {
    String text;

    String readRespData= "";

    String pipeSeperatedString;
    var body;

    Map<String, dynamic> request = paymentRequest.toJson();

    String compURL;
    String? devicemodel;
    String? deviceVersion;
    var devicePlatform = "";
    var pluginName = "";
    var pluginVersion = "";
    var paymentMethod = "";
    String? pluginPlatform;
var ipAdd = "";

    text =  await DefaultAssetBundle.of(context).loadString('assets/appconfig.json');
    final jsonResponse = json.decode(text);
    var t_id = jsonResponse["terminalId"] as String;
    var t_pass = jsonResponse["terminalPass"] as String;
    var merc = jsonResponse["merchantKey"] as String;
    var req_url = jsonResponse["requestUrl"] as String;
    Constantvals.termId = t_id;
    Constantvals.termpass = t_pass;
    Constantvals.merchantkey = merc;
    Constantvals.requrl = req_url;

    final paymentType = paymentRequest.paymentType;
    final currency = paymentRequest.currency;
    final amount = paymentRequest.amount;

    final orderID = paymentRequest.trackId;


    /**
     * Connectivity is checked as there is server call
     * It will fetch v6 but if not then will fetch v4
     * */
    try {
    final ipv64 = await Ipify.ipv64();
    ipAdd = ipv64;
    pipeSeperatedString = orderID + "|" + Constantvals.termId + "|" + Constantvals.termpass +"|" +Constantvals.merchantkey + "|" + amount + "|" + currency;


    print('$pipeSeperatedString');

    var bytes = utf8.encode(pipeSeperatedString);
    Digest sha256Result = sha256.convert(bytes);
    final digestHex = hex.encode(sha256Result.bytes);
    print('$digestHex');

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    print('App Name : $appName');

    String appversion = packageInfo.version;


    try {

      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      var devicedata = getDeviceType();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        pluginName = "Flutter Android";
        pluginVersion = "3.0.3";
        pluginPlatform = devicedata;

        devicemodel = androidInfo.model;
        deviceVersion = androidInfo.version.sdkInt.toString();
        devicePlatform = appName + " " + appversion;
      }
      else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        pluginName = "Flutter iOS";
        pluginVersion = "3.0.3";
        pluginPlatform = iosInfo.model;
        devicemodel = iosInfo.name;
        deviceVersion = iosInfo.systemVersion;
        devicePlatform = appName + " " + appversion;
      }




      // }
    } catch(e)
    {
      ResponseConfig.startTrxn = false;
      showalertDailog(context, 'Device Information',
          'Please check your Internet Connection $e');
    }

    DeviceDetailsModel detailsModel = new DeviceDetailsModel(
        pluginName: pluginName,
        pluginVersion: pluginVersion,
        deviceType: pluginPlatform,
        deviceModel: devicemodel,
        deviceOSVersion: deviceVersion,
        clientPlatform: devicePlatform);

    var devicebody = json.encode(detailsModel.toMap());
    request["deviceInfo"] = detailsModel.toMap();
    request["signature"] = digestHex;
    request["password"] = Constantvals.termpass;
    request["terminalId"] = Constantvals.termId;
    // request["customerIp"] = "10.10.8.99";

    // Validate Airline Request

        if (request.containsKey("airline") && (paymentType != "1" && paymentType != "4")) {
          ResponseConfig.startTrxn = false;

          showalertDailog(
            context,
            "Invalid Request",
            "For Airline transactions, paymentType must be 1 or 4.",
          );

          return "";
        }

      else {

        print('REQUEST in MAP $request');
        body = json.encode(request);
        // debugPrint(
        //   body,
        //   wrapWidth: 20000,
        // );
        // print('Request Body  $body');
        String requestBody = jsonEncode(request);

        printLongString(requestBody);
        try {
          Map<String, String> headers = {
            'Content-type': 'application/json',
            'Accept': 'application/json'
          };

          var requrl = Uri.parse(Constantvals.requrl);
          var response = await http.post(requrl, headers: headers, body: body);


          /**
           * Response is checked */
          if (response.statusCode == 200) {
            var data = json.decode(response.body);
            var cc = data["responseCode"];

            if (data["responseCode"] == '001') {
              var payId = data["transactionId"];
              var linkurl = data["paymentLink"];
              var tar_url = "";
              var data1 = linkurl["linkUrl"];

              compURL = data1 + payId;


              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => TransactWebpage(inURL: compURL),
                ),
              );


              if (result == null) {
                //print("in result null");
                Navigator.of(context)
                    .pop();
                ResponseConfig.startTrxn = false;
              }
              else {
                ResponseConfig.startTrxn = false;
                readRespData = result;
                print(" in if $compURL");
                print(' Data3  $readRespData');
              }
            }
            else if (data["responseCode"] == '000') {
              var pay = null;

              ResponseConfig.startTrxn = false;

              var data = response.body;

              readRespData = data;
              print(' Data2  $readRespData');
            }
            else {
              ResponseConfig.startTrxn = false;

              var responseData = response.body;
              var data = json.decode(response.body);
              String RESString = data.toString();
              Map<String, dynamic> mapdata = data;
              print('RESPONSE 000 $mapdata');
              mapdata.forEach((key, value) {
                String strvalue = value.toString();

                if (strvalue == null || strvalue == "null") {
                  value = '';


                  mapdata.update(key, (value) => '');
                }
              });

              String data1 = mapdata.toString();
              print(' Data1  $RESString');
              readRespData = responseData;
              print(' Data1  $readRespData');
            }
          }
          else {
            String respCode = response.statusCode.toString();
            //_writetoFile("Response :" + body + "\n");
            showalertDailog(context, 'Error', 'Invalid Request with $respCode');
          }
        }
        catch (e) {
          ResponseConfig.startTrxn = false;
          showalertDailog(context, 'Internet Connection response ',
              'Please check your Internet Connection  with $e');
        }
      }

  } catch (e) {
  // Handle the exception here
  print('Error: Unable to reach the Ipify service.');
  print('Exception: $e');

  ResponseConfig.startTrxn = false;
  showalertDailog(context, 'Alert', "Please check Internet Connection");
  }

  return readRespData;
}


  static void printLongString(String text) {
    const int chunkSize = 800;

    for (int i = 0; i < text.length; i += chunkSize) {
      int end = (i + chunkSize < text.length)
          ? i + chunkSize
          : text.length;

      debugPrint(text.substring(i, end));
    }
  }

  /***
   * This method is used to validate Data passes to perform Transaction Details
   * */
  static bool isValidationSucess(BuildContext context, String amount,
      String email, String Action, String CountryCode, String Currency,
      String track, String cardOperation, String cardToken)
  {
    bool d = false;


    if (amount.isEmpty) {
      showalertDailog(context, 'Error', 'Amount should not be empty');
      ResponseConfig.startTrxn = false;
    }

    else if (Action.isEmpty || Action.length == 0) {
      showalertDailog(context, 'Error', 'Action Code should not be empty');
      ResponseConfig.startTrxn = false;
    }

    else if (Currency.isEmpty || Currency.length == 0) {
      showalertDailog(context, 'Error', 'Currency should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (CountryCode.isEmpty || CountryCode.length == 0) {
      showalertDailog(context, 'Error', 'Country Code should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if (track.isEmpty || track.length == 0) {
      showalertDailog(context, 'Error', 'Track ID should not be empty');
      ResponseConfig.startTrxn = false;
    }
    // else if (Currency.length > 3) {
    //   showalertDailog(context, 'Error', 'Currency should be proper');
    //   ResponseConfig.startTrxn = false;
    // }

    else if (Action.length > 3) {
      showalertDailog(context, 'Error', 'Action Code should be proper ');
      ResponseConfig.startTrxn = false;
    }
    else if (CountryCode.length > 2) {
      showalertDailog(context, 'Error', 'CountryCode should be proper');
      ResponseConfig.startTrxn = false;
    }
    // else if (email.isEmpty) {
    //   showalertDailog(context, 'Error', 'Email should not be empt');
    //   ResponseConfig.startTrxn = false;
    // }
    // else if (!email.isEmpty && (isValidEmail == false)) {
    //   showalertDailog(context, 'Error', 'Email should be proper');
    //   ResponseConfig.startTrxn = false;
    // }
    else
    if (((Action == '12') && (cardOperation == 'U')) && (cardToken.isEmpty)) {
      showalertDailog(context, 'Error', 'Card Token should not be empty');
      ResponseConfig.startTrxn = false;
    }
    else if ((Action == '12') && (cardOperation == 'D') && cardToken.isEmpty) {
      showalertDailog(context, 'Error', 'Card Token should not be empty');
      ResponseConfig.startTrxn = false;
    }

    else if ((Action == "14") && (cardToken.isEmpty)) {
//      alert.showAlertDialog(context, "Invalid Refund", "Card Token Should not be empty ", false);
      showalertDailog(
          context, 'Invalid Refund', 'Card Token should not be empty ');
      ResponseConfig.startTrxn = false;
    }
    else {
      d = true;
    }
    return d;
  }


  /**
   * This method is used to display Alert for invalid or error response*/
  static void showalertDailog(BuildContext context, String title,
      String description) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Container(

            margin: EdgeInsets.only(top: Constantvals.marginTop),

            child: Column(
              mainAxisSize: MainAxisSize.min, // To make the card compact
              children: <Widget>[

                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 24.0),
                Align(
                  alignment: Alignment.center,

                  child: ElevatedButton(


                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // To close the dialTraog//todo close plugin
                      ResponseConfig.startTrxn = false;
                    },
                    child: Text('OK'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      elevation: 10,
    );
    showDialog(
      context: context,

      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static bool isValidEmailchk(String emailCheck) {
    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@[a-z]+\.+[a-z]$';
    RegExp regExp = new RegExp(pattern.toString());
    bool chk = regExp.hasMatch(emailCheck);
    return chk;
  }


  /**
   *  This method is use to perform Apple Pay transaction From Customer UserInterface
   */
  static Future<String> makeapplepaypaymentService({
    required BuildContext context, required String firstname,required String lastname,required String country, required String action, required String currency, required String amt, required String customerEmail, required String trackid, required String tokenizationType, required String merchantIdentifier, required String shippingCharge, required String companyName,required String metadata
  }) async {
    assert(context != null, "context is null!!");
    dynamic applePaymentData;
    String appleRespdata="";


    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

        print('$merchantIdentifier');
        try {

          if (companyName.isEmpty) {
            showalertDailog(context, 'Error','Company Name should not be empty');
            ResponseConfig.startTrxn = false;
          }
          else if (shippingCharge.isEmpty) {
            showalertDailog(context, 'Error','Shipping Charges should not be empty');
            ResponseConfig.startTrxn = false;
          }
          else {

            var dblamt = double.parse(amt);
            var dblshippingcharge = double.parse(shippingCharge);

            List<PaymentItem> paymentItems1 = [
              PaymentItem(label: 'Label', amount: dblamt,shippingcharge: dblshippingcharge)
            ];

            // initiate payment
            applePaymentData = await ApplePayFlutter.makePayment(
              countryCode: country,
              currencyCode: currency,
              paymentNetworks: [
                PaymentNetwork.visa,
                PaymentNetwork.mastercard,
                PaymentNetwork.amex,
                PaymentNetwork.mada
              ],
              merchantIdentifier: merchantIdentifier,
              paymentItems: paymentItems1,
              customerEmail: customerEmail,
              customerName: firstname+" "+lastname ,
              companyName: companyName,

            );
             print(" Apple token Data :" + applePaymentData.toString());
          }
        }
          on PlatformException {
            print('Failed payment');
          }
        var totalcharge= double.parse(amt)+double.parse(shippingCharge);
        String strtlchr=totalcharge.toString();


      if(applePaymentData.toString().contains("code"))
        {
           return "";
        }


      else {
            var order = await applepayapi(
            context,
            country,
            firstname,lastname,
            action,
            currency,
            strtlchr,
            customerEmail,
            trackid,

            tokenizationType,
            applePaymentData,
                metadata);

            appleRespdata = order;
         }
        }
      }
      on SocketException catch (e) {
      ResponseConfig.startTrxn = false;
      //appleRespdata = "Please check internet connection";

      showalertDailog(context, 'Alert', "Please check Internet Connection");
    }

    return appleRespdata;
  }

  /**
   *  This method is use to perform Apple Pay transaction in merchant PG
   */
  static Future<String> applepayapi(BuildContext context, String country,String firstname,String lastname,
      String action, String currency, String amt, String customerEmail,
      String trackid, String tokenizationType, dynamic appleToken , String metadata) async {
    String text;
    String RespData ="";


    String pipeSeperatedString;

    ResponseConfig resp = ResponseConfig();
    var ipAdd;

    dynamic paymentTokk;
    text =
    await DefaultAssetBundle.of(context).loadString('assets/appconfig.json');
    final jsonResponse = json.decode(text);
    var t_id = jsonResponse["terminalId"] as String;
    var t_pass = jsonResponse["terminalPass"] as String;
    var merc = jsonResponse["merchantKey"] as String;
    var req_url = jsonResponse["requestUrl"] as String;
    Constantvals.termId = t_id;
    Constantvals.termpass = t_pass;
    Constantvals.merchantkey = merc;
    Constantvals.requrl = req_url;

    var connectivityResult = await (Connectivity().checkConnectivity());
    final ipv64 = await Ipify.ipv64();
    ipAdd = ipv64;

    //   try {
    //
    //     final ipv4 = await Ipify.ipv4();
    //
    //     ipAdd = ipv4;
    //
    //   } on PlatformException {
    //     print('Failed to get broadcast IP.');
    //   }
    //
    // }
    // else {
    //   print("Unable to connect. Please Check Internet Connection");
    // }
    var dblamt = double.parse(amt);

    if (isValidationSucess(
        context,
        amt,
        customerEmail,
        action,
        country,
        currency,
        trackid,
        "",
        "")) {
      if (["", null].contains(appleToken['paymentData'])) {

      }
      else {
        paymentTokk = jsonDecode(appleToken['paymentData']) ?? "empty";
      }

      pipeSeperatedString =
          trackid + "|" + Constantvals.termId + "|" + Constantvals.termpass +
              "|" +
              Constantvals.merchantkey + "|" + dblamt.toStringAsFixed(2) + "|" + currency;
      print('$pipeSeperatedString');
      var bytes = utf8.encode(pipeSeperatedString);
      Digest sha256Result = sha256.convert(bytes);
      final digestHex = hex.encode(sha256Result.bytes);
      print('$digestHex');
//TODO make changes for Proper Request JSON for Apple Pay
      // 'customer': customerJson,
      //  'order': orderjson,
      // 'additionalDetails' : additionalJson,
      Map<String, dynamic> customerJson = {
        'cardHolderName': firstname+" "+lastname,
        'customerEmail': customerEmail,
        'billingAddressStreet': '',
        // "billingAddressCity": city,
        // "billingAddressState": state,
        // "billingAddressPostalCode": zipCode,
        "billingAddressCountry": country
      };

      try {
        final Map<String, dynamic> jsonBody = {


//TODO make changes for Proper Request JSON

          'terminalId': Constantvals.termId,
          'password': Constantvals.termpass,
          'signature': digestHex,

          'paymentType': 1,
          'merchantIp': ipAdd,

          'amount': dblamt.toStringAsFixed(2),
          'country': country,
          'currency': currency,
          "order": {
            "orderId": trackid
          },
          'customerIp': ipAdd,
          'customer': customerJson,
          'paymentToken': {
            "paymentData": paymentTokk,
            "transactionIdentifier": appleToken['transactionIdentifier'],
            "paymentMethod": appleToken['paymentMethod']
          },

          "paymentInstrument": {
            "paymentMethod": "APPLEPAY"
          },


        };
        var requrl = Uri.parse(Constantvals.requrl);
        print('Request URL $requrl');
        final response = await http.post(
          requrl,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(jsonBody),
        );

        //  _writetoFile("Request apple pay :" + jsonBody + "\n");
        print('Request BODY $jsonBody');
        print('Resonse BODY $jsonDecode(response)');
        if (response.statusCode == 200) {
          //_writetoFile("Response apple pay  1:" + response.body.toString() + "\n");

          var data = response.body;
          print('Resonse DATA $data');
          return data;
        }
      }
      on Exception catch (e) {
        ResponseConfig.startTrxn = false;
        //appleRespdata = "Please check internet connection";
        print('Exception: $e');
        showalertDailog(context, 'Alert', "Payment Gateway Exception $e");
      }
    }
    else
    {
      ResponseConfig.startTrxn = false;
    }

return RespData;
  }


}

