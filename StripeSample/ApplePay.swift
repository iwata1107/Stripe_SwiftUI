//
//  ApplePay.swift
//  StripeSample
//
//  Created by 岩田照太 on 2021/12/17.
//

import SwiftUI
import Stripe

struct ApplePay: View {
    @ObservedObject var backendModel = BackendModel()
    var body: some View {
        VStack{
            if backendModel.paymentIntentParams != nil {
                 Text("")
            } else {
                Text("Loading...")
            }
        }.onAppear {
            if (!StripeAPI.deviceSupportsApplePay()) {
                print("Apple Pay is not supported on this device")
            } else {
                backendModel.preparePaymentIntent(paymentMethodType: "card", currency: "usd", testamount: 100)
            }
        }
    }
}

struct ApplePay_Previews: PreviewProvider {
    static var previews: some View {
        ApplePay()
    }
}
