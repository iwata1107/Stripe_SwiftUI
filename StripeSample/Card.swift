//
//  Card.swift
//  StripeSample
//
//  Created by 岩田照太 on 2021/12/17.
//

import SwiftUI
import Stripe

struct Card: View {
    @ObservedObject var model = BackendModel()
    @State var loading = false
    @State var paymentMethodParams: STPPaymentMethodParams?
    let testamount = 100 //自分で追加した
    
    var body: some View {
        VStack {
            STPPaymentCardTextField.Representable(paymentMethodParams: $paymentMethodParams).padding()
            
            if let paymentIntent = model.paymentIntentParams { //サーバーが起動していればBuyがでた
                Button("Buy"){
                    paymentIntent.paymentMethodParams = paymentMethodParams
                    loading = true
                }.paymentConfirmationSheet(isConfirmingPayment: $loading, paymentIntentParams: paymentIntent, onCompletion: model.onCompletion).disabled(loading)
            }else{
                Text("Loading...") //サーバーが起動していないときにやったらこれが出た
            }
        }.onAppear {
            model.preparePaymentIntent(paymentMethodType: "card", currency: "jpy", testamount: testamount) //ここに数字渡すだけで良い
        }
        //こっから
        if let paymentStatus = model.paymentStatus {
            HStack{
                switch paymentStatus {
                case .succeeded:
                    Text("Payment complete!")
                case .failed:
                    Text("Payment failed!")
                case .canceled:
                    Text("Unknown status!")
                }
            }
        }
        //ここまでテンプレート
    }
}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card()
    }
}
