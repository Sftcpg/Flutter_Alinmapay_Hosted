class DeviceDetailsModel
{
  String? deviceModel ="";
  String? deviceOSVersion ="";
  String? clientPlatform ="";
  String? pluginName="";
  String? pluginVersion="";
  String? deviceType="";

  DeviceDetailsModel({required this.pluginName,required this.pluginVersion,required this.deviceType,required this.deviceModel, required this.deviceOSVersion,required this.clientPlatform});


  factory DeviceDetailsModel.fromJson(Map<String, dynamic> json)
  {
    DeviceDetailsModel pay;
    pay=DeviceDetailsModel(
      pluginName:json['pluginName'] as String,
      pluginVersion:json['pluginVersion'] as String,
      deviceType:json['deviceType'] as String,
      deviceModel:json['deviceModel'] as String,

        deviceOSVersion:json['deviceOSVersion'] as String,
        clientPlatform:json['clientPlatform'] as String,
  );
    return pay;
  }


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["pluginName"]=pluginName;
    map["pluginVersion"]=pluginVersion;
    map["deviceType"]=deviceType;
    map["deviceModel"] = deviceModel;
    map["deviceOSVersion"] = deviceOSVersion;
    map["clientPlatform"]= clientPlatform;


    return map;
  }


}