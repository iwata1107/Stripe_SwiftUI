//
//  BackendModel.swift
//  StripeSample
//
//  Created by 岩田照太 on 2021/12/17.
//

import Foundation
import Stripe

class BackendModel : ObservableObject {
    @Published var paymentStatus: STPPaymentHandlerActionStatus?
    @Published var paymentIntentParams: STPPaymentIntentParams?
    @Published var lastPaymentError: NSError?
    var paymentMethodType: String?
    var currency: String?
    var testamount:Int? //?つけないと"Class 'BackendModel' has no initializers"が出る
    
    func preparePaymentIntent(paymentMethodType: String, currency: String, testamount: Int) { //card()から送られてくる
        self.paymentMethodType = paymentMethodType
        self.currency = currency
        self.testamount = testamount
        //URLの生成
        let url = URL(string: BackendUrl + "create-payment-intent")!
        
        var request = URLRequest(url: url)
        let json: [String: Any] = [
            "paymentMethodType": paymentMethodType,
            "currency": currency,
            "testamount": testamount,
        ]
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["clientSecret"] as? String else {
                    let message = error?.localizedDescription ?? "Failed to decode response from server."
                print(message)
                return
            }
            print("Created the PaymentIntent")
            DispatchQueue.main.async {
                self.paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            }
        })
        task.resume()
    }
    func onCompletion(status: STPPaymentHandlerActionStatus, pi:STPPaymentIntent?, error:NSError?) {
        self.paymentStatus = status
        self.lastPaymentError = error
        
        if status == .succeeded {
            self.paymentIntentParams = nil
            preparePaymentIntent(paymentMethodType: self.paymentMethodType!, currency: self.currency!, testamount: self.testamount!)
        }
    }
}
