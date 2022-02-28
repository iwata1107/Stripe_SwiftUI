//
//  StripeSampleApp.swift
//  StripeSample
//
//  Created by 岩田照太 on 2021/09/22.
//

import SwiftUI
import Stripe

let BackendUrl = "http://localhost:8000/"

@main
struct StripeSampleAp: App {
    //publishablekeyを送ってもらう関数
    init() {
        let url = URL(string: BackendUrl + "config")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let publishableKey = json["publishableKey"] as? String else {
                print("Failed to retrieve publishableKey from /config")
                return
            }
            print("Fetched publishable key \(publishableKey)")
            StripeAPI.defaultPublishableKey = publishableKey
        })
        task.resume()
    }

    
    var body: some Scene {
        WindowGroup {
            ContentView().onOpenURL(perform: { url in
                    let stripeHandled = StripeAPI.handleURLCallback(with: url)
                    if (!(stripeHandled)) {
                        //This was not a Stripe URL - handle noemally
                    }
                })
        }
    }
}
