class PayTrxn
{
  String terminalId;
  String password;
  String paymentType;
  String currency;
  Map<String, dynamic> customer;
  String amount;
  String customerIp;
  String merchantIp;
  String referenceId;
  Map<String, dynamic> order;
  String country;

  String signature;
 String deviceInfo;
  Map<String, dynamic> additionalDetails;
  Map<String, dynamic> tokenization;

  PayTrxn
      ({
    required this.terminalId,
    required this.password,
    required this.paymentType,
    required this.currency,
    required this.customer,
    required this.amount,
    required this.customerIp,
    required this.merchantIp,
    required this.order,
    required this.referenceId,
    required this.country,
    required this.tokenization,

    required this.signature,
   required this.deviceInfo,
   required this.additionalDetails

  });


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["terminalId"] = terminalId;
    map["password"] = password;
    map["paymentType"]= paymentType;
    map["customer"]=customer;
    map["currency"]=currency;
    map["order"] =order;
    map["referenceId"] =referenceId;
    map["signature"]=signature;
    map["tokenization"]=tokenization;
    map["country"] =country;
    map["amount"] =amount;
    map["customerIp"]=customerIp ;
    map["merchantIp"] =merchantIp;

    map["deviceInfo"]=deviceInfo;
    map["additionalDetails"]=additionalDetails;

    return map;
  }


}