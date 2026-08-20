import Flutter
import UIKit
import Foundation
import PassKit

typealias AuthorizationCompletion = (_ payment: Any) -> Void
typealias AuthorizationViewControllerDidFinish = (_ error : NSDictionary) -> Void

public class SwiftApplePayFlutterPlugin: NSObject, FlutterPlugin, PKPaymentAuthorizationViewControllerDelegate {
    var authorizationCompletion : AuthorizationCompletion!
    var authorizationViewControllerDidFinish : AuthorizationViewControllerDidFinish!
    var pkrequest = PKPaymentRequest()
    var flutterResult: FlutterResult!


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_payment_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftApplePayFlutterPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        flutterResult = result;

        if (call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
            return
        }

        if (call.method != "makePayment") {
            result(FlutterMethodNotImplemented)
            return
        }

        let parameters = NSMutableDictionary()
        var payments: [PKPaymentNetwork] = []
        var items = [PKPaymentSummaryItem]()
        var totalPrice:Double = 0.0

        guard let arguments = call.arguments as? NSDictionary else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments are not a dictionary", details: nil))
            return
        }

        guard let paymentNeworks = arguments["paymentNetworks"] as? [String] else {return}
        guard let countryCode = arguments["countryCode"] as? String else {return}
        guard let currencyCode = arguments["currencyCode"] as? String else {return}
        guard let companyName = arguments["companyName"] as? String else {return}
        guard let paymentItems = arguments["paymentItems"] as? [NSDictionary] else {return}
        guard let merchantIdentifier = arguments["merchantIdentifier"] as? String else {return}

        for dictionary in paymentItems {
            guard let label = dictionary["label"] as? String else {return}
            guard let price = dictionary["amount"] as? Double else {return}
            guard let shippingcharge = dictionary["shippingcharge"] as? Double else {return}
            let type = PKPaymentSummaryItemType.final

            totalPrice = price+shippingcharge
            items.append(PKPaymentSummaryItem(label: "SHIPPING", amount: NSDecimalNumber(floatLiteral: shippingcharge), type: type))
            items.append(PKPaymentSummaryItem(label: "SUBTOTAL", amount: NSDecimalNumber(floatLiteral: price), type: type))
        }

        let total = PKPaymentSummaryItem(label: companyName , amount: NSDecimalNumber(floatLiteral:totalPrice), type: .final)
        items.append(total)

        paymentNeworks.forEach {

            guard let paymentType = PaymentSystem(rawValue: $0) else
            {
                assertionFailure("No payment type found")
                return
            }
            payments.append(paymentType.paymentNetwork)
        }

        parameters["paymentNetworks"] = payments
        parameters["merchantCapabilities"] = PKMerchantCapability.capability3DS // optional

        parameters["merchantIdentifier"] = merchantIdentifier
        parameters["countryCode"] = countryCode
        parameters["currencyCode"] = currencyCode

        parameters["paymentSummaryItems"] = items

        makePaymentRequest(parameters: parameters,  authCompletion: authorizationCompletion, authControllerCompletion: authorizationViewControllerDidFinish)
    }

    func authorizationCompletion(_ payment: Any) {
        // success
        flutterResult(payment)
    }

    func authorizationViewControllerDidFinish(_ error : NSDictionary) {
        //error
        flutterResult(error)
    }

    enum PaymentSystem: String {
        case visa
        case mastercard
        case amex
        case mada
        case quicPay
        case chinaUnionPay
        case discover
        case interac
        case privateLabel

        var paymentNetwork: PKPaymentNetwork {

            switch self {
                case .mastercard: return PKPaymentNetwork.masterCard
                case .visa: return PKPaymentNetwork.visa
                case .amex: return PKPaymentNetwork.amex
            case .mada: if #available(iOS 12.1.1, *) {
                    return PKPaymentNetwork.mada
                }else{
                    return PKPaymentNetwork.amex
                }
                case .quicPay: return PKPaymentNetwork.quicPay
                case .chinaUnionPay: return PKPaymentNetwork.chinaUnionPay
                case .discover: return PKPaymentNetwork.discover
                case .interac: return PKPaymentNetwork.interac
                case .privateLabel: return PKPaymentNetwork.privateLabel
            }
        }
    }

    func makePaymentRequest(parameters: NSDictionary, authCompletion: @escaping AuthorizationCompletion, authControllerCompletion: @escaping AuthorizationViewControllerDidFinish) {
        guard let paymentNetworks               = parameters["paymentNetworks"]                 as? [PKPaymentNetwork] else {return}
        let merchantCapabilities : PKMerchantCapability = parameters["merchantCapabilities"]    as? PKMerchantCapability ?? .capability3DS

        guard let merchantIdentifier            = parameters["merchantIdentifier"]              as? String else {return}
        guard let countryCode                   = parameters["countryCode"]                     as? String else {return}
        guard let currencyCode                  = parameters["currencyCode"]                    as? String else {return}

        guard let paymentSummaryItems           = parameters["paymentSummaryItems"]             as? [PKPaymentSummaryItem] else {return}

        authorizationCompletion = { [weak self] payment in
            self?.flutterResult?(payment)
        }
        authorizationViewControllerDidFinish = { [weak self] error in
            self?.flutterResult?(error)
        }

        // Cards that should be accepted
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {

            pkrequest.merchantIdentifier = merchantIdentifier
            pkrequest.countryCode = countryCode
            pkrequest.currencyCode = currencyCode
            pkrequest.supportedNetworks = paymentNetworks
            pkrequest.merchantCapabilities = merchantCapabilities

            pkrequest.paymentSummaryItems = paymentSummaryItems

            let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: pkrequest)

            if let viewController = authorizationViewController {
                viewController.delegate = self
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let viewControllerToPresent = windowScene.windows.first?.rootViewController?.topMostViewController() else {
                    return
                }
                viewControllerToPresent.present(viewController, animated: true)
            }
        } else {
            let error: NSDictionary = ["message": "No payment method found", "code": "404", "ok": false]
            authorizationViewControllerDidFinish!(error)
         }

        return
    }

    public func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {

        var paymentType = "";

        switch payment.token.paymentMethod.type {
            case .debit:
                paymentType = "debit"
            case .credit:
                paymentType = "credit"
            case .store:
                paymentType = "store"
            case .prepaid:
                paymentType = "prepaid"
            default:
                paymentType = "unknown"
            }

        let paymentMethodDictionary: [AnyHashable: Any] = ["network": payment.token.paymentMethod.network?.rawValue ?? "", "type": paymentType, "displayName": payment.token.paymentMethod.displayName ?? ""]

        let encryptedPaymentData = payment.token.paymentData
        let decryptedPaymentData = String(data: encryptedPaymentData, encoding: .utf8)

        let PaymentData: NSDictionary = [
            "ok": true,
            "paymentMethod": paymentMethodDictionary,
            "paymentType": paymentType,
            "paymentData": decryptedPaymentData ?? "",
            "transactionIdentifier": payment.token.transactionIdentifier,
        ]

        completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        authorizationCompletion(PaymentData)
    }


    public func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let viewControllerToDismiss = windowScene.windows.first?.rootViewController?.topMostViewController() else {
            return
        }
        viewControllerToDismiss.dismiss(animated: true, completion: nil)
        let error: NSDictionary = ["message": "User closed apple pay", "code": "400", "ok": false]
        authorizationViewControllerDidFinish(error)
    }
}

extension UIViewController {
    func topMostViewController() -> UIViewController? {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController()
        }
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController()
        }
        return self
    }
}
