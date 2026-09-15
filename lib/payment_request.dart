class PaymentRequest {
  // Payment details
  String amount;
  String paymentType;
  String currency;

  // Order
  String trackId;

  // Customer
  String email;
  String cardHolderName;
  String address;
  String city;
  String state;
  String zipCode;
  String country;


  // Tokenization
  String cardOperation;
  String cardToken;
  String tokenizationType;

  // Transaction
  String transactionId;

  // Metadata
  String metadata;

  // Dynamic objects
  Map<String, dynamic>? airline;

  PaymentRequest({
    this.amount = "",
    this.paymentType = "",
    this.currency = "",

    this.trackId = "",

    this.email = "",
    this.cardHolderName = "",
    this.address = "",
    this.city = "",
    this.state = "",
    this.zipCode = "",
    this.country = "",


    this.cardOperation = "",
    this.cardToken = "",
    this.tokenizationType = "",

    this.transactionId = "",

    this.metadata = "",

    this.airline,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> request = {
      "paymentType": paymentType,
      "currency": currency,
      "amount": amount,

      "order": {
        "orderId": trackId,
        "description": "",
      },

      "customer": {
        "customerEmail": email,
        "cardHolderName": cardHolderName,
        "billingAddressStreet": address,
        "billingAddressCity": city,
        "billingAddressState": state,
        "billingAddressPostalCode": zipCode,
        "billingAddressCountry": country,
      },

      "additionalDetails": {
        "userData": metadata,
      },

      "tokenization": {
        "operation": cardOperation,
        "cardToken": cardToken,
        "tokenizationType": tokenizationType,
      },
    };




    // Add airline only when supplied
    if (airline != null) {
      request["airline"] = airline;
    }

    // Add referenceId only when supplied
    if (transactionId.isNotEmpty) {
      request["referenceId"] = transactionId;
    }

    return request;
  }
}