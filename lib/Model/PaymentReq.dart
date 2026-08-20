class PaymentReq
{
  String terminalId;
  String password;
  String action;
  String currency;
  String customerEmail;
  String country;
  String amount;
  String customerIp;

  String merchantIp;
  String trackid;

  late String address;
  late String city;
  late String zipCode;
  late String state;
  late String tokenOperation;
  late String cardToken;
  late String tokenizationType;
  late String requestHash;

  late String deviceInfo;
  late String metaData;

  PaymentReq({required this.terminalId, required this.password, required this.action, required this.currency,
    required this.customerEmail,required this.country,required this.amount,required this.customerIp,
    required this.merchantIp,required this.trackid,required this.address, required this.city,required this.zipCode,required this.state,required this.tokenOperation,
    required this.cardToken,required this.tokenizationType,required this.requestHash,required this.deviceInfo,required this.metaData});


  //action12
  PaymentReq.tokenize({required this.terminalId,required this.password,required this.action,required this.currency,
    required this.customerEmail,required this.country,required this.amount,required this.customerIp,
    required this.merchantIp,required this.trackid,required this.tokenOperation,
    required this.cardToken,required this.requestHash,required this.deviceInfo});

//  action 14
  PaymentReq.refund({required this.terminalId, required this.password, required this.action, required this.currency,
    required this.customerEmail, required this.country, required this.amount, required this.customerIp,
    required this.merchantIp, required this.trackid,
    required this.cardToken,required this.requestHash,required this.deviceInfo});

  factory PaymentReq.fromJson(Map<String, dynamic> json)
  {
    PaymentReq pay;
     pay=PaymentReq(
        terminalId:json['terminalId'] as String,
        password:json['password'] as String,
        action:json['action'] as String,
        currency:json['currency'] as String,

        customerEmail:json['customerEmail'] as String,
        country:json['country'] as String,
        amount:json['amount'] as String,
        customerIp:json['customerIp'] as String,

        merchantIp:json['merchantIp'] as String,
        trackid:json['trackid'] as String,
        // udf1:json['udf1'] as String,
        // udf2:json['udf2'] as String,
        // udf3:json['udf3'] as String,
        // udf4:json['udf4'] as String,
        // udf5:json['udf5'] as String,
        // udf7:json['udf7'] as String,
        address:json['address'] as String,
        city:json['city'] as String,
        zipCode:json['zipCode'] as String,
        state:json['state'] as String,
        cardToken:json['cardToken'] as String,
        tokenOperation:json['tokenOperation'] as String,
        tokenizationType:json['tokenizationType'] as String,
        requestHash: json['requestHash'] as String,

         deviceInfo: json['deviceinfo'] as String,
       metaData: json['metaData'] as String,
    );

     pay=PaymentReq.tokenize(terminalId:json['terminalId'] as String,
         password:json['password'] as String,
         action:json['action'] as String,
         currency:json['currency'] as String,

         customerEmail:json['customerEmail'] as String,
         country:json['country'] as String,
         amount:json['amount'] as String,
        customerIp:json['customerIp'] as String,

         merchantIp:json['merchantIp'] as String,
         trackid:json['trackid'] as String,
         // udf1:json['udf1'] as String,
         // udf2:json['udf2'] as String,
         // udf3:json['udf3'] as String,
         // udf4:json['udf4'] as String,
         // udf5:json['udf5'] as String,
         // udf7:json['udf7'] as String,

         cardToken:json['cardToken'] as String,
         tokenOperation:json['tokenOperation'] as String,
         requestHash: json['requestHash'] as String,
        deviceInfo: json['deviceinfo'] as String
     );


     pay=PaymentReq.refund(
         terminalId:json['terminalId'] as String,
         password:json['password'] as String,
         action:json['action'] as String,
         currency:json['currency'] as String,

         customerEmail:json['customerEmail'] as String,
         country:json['country'] as String,
         amount:json['amount'] as String,
         customerIp:json['customerIp'] as String,

         merchantIp:json['merchantIp'] as String,
         trackid:json['trackid'] as String,
         // udf1:json['udf1'] as String,
         // udf2:json['udf2'] as String,
         // udf3:json['udf3'] as String,
         // udf4:json['udf4'] as String,
         // udf5:json['udf5'] as String,
         // udf7:json['udf7'] as String,

         cardToken:json['cardToken'] as String,
         requestHash: json['requestHash'] as String,
         deviceInfo: json['deviceInfo'] as String
     );
     return pay;
  }


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["terminalId"] = terminalId;
    map["password"] = password;
    map["action"]= action;
    map["currency"]=currency;
    map["customerEmail"]=customerEmail;
    map["country"] =country;
    map["amount"] =amount;
   map["customerIp"]=customerIp ;
    map["merchantIp"] =merchantIp;
    map["trackid"] =trackid;
    // map["udf1"] =udf1;
    // map["udf2"]=udf2;
    // map["udf3"]=udf3;
    // map["udf4"] =udf4;
    // map["udf5"]=udf5;
    // map["udf7"]=udf7;
    map["address"]=address;
    map["city"]=city;
    map["zipCode"]=zipCode;
    map["state"]=state;
    map["cardToken"]=cardToken;
    map["tokenOperation"]=tokenOperation;
    map["tokenizationType"]=tokenizationType;
    map["requestHash"]=requestHash;

    map["deviceInfo"]=deviceInfo;
    map["metaData"]=metaData;
    return map;
  }


}
