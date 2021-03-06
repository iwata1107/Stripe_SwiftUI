//
//  ContentView.swift
//  FruitStore
//
//  Created by Mohammad Azam on 10/6/21.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var cart: Cart
    @State private var isActive: Bool = false
    
    private func startCheckout(completion: @escaping (String?) -> Void) {
       //URLの生成
        let url = URL(string: "https://everlasting-scythe-airplane.glitch.me/create-payment-intent")!
    
        //URLリクエストの生成
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(cart.items)
        //URLにアクセス
        let task = URLSession.shared.dataTask(with: request) {( data, response, error ) in 
                
            guard let data = data, error == nil,
                  (response as? HTTPURLResponse)?.statusCode == 200
            else {
                completion(nil)
                return
            }
            
            let checkoutIntentResponse = try? JSONDecoder().decode(CheckoutIntentResponse.self, from: data)
            completion(checkoutIntentResponse?.clientSecret)
            
        }
        task.resume()
    }
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                List(Product.all()) { product in
                    HStack {
                        Text(product.photo)
                        Text(formatPrice(product.price) ?? "")
                        Spacer()
                        Button {
                            // action
                            cart.addToCart(product)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                
                NavigationLink(isActive: $isActive) {
                    CheckoutView()
                } label: {
                    Button("Checkout") {
                        print("pushed")
                        print(cart.items)
                        startCheckout { clientSecret in
                            
                            PaymentConfig.shared.paymentIntentClientSecret = clientSecret
                            
                            DispatchQueue.main.async {
                                isActive = true
                            }
                        }
                    }
                }
                
                .navigationTitle("Products")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        VStack {
                            Text("\(cart.cartCount)")
                            Image(systemName: "cart")
                        }
                    }
                }
                
            }
            
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Cart())
    }
}
