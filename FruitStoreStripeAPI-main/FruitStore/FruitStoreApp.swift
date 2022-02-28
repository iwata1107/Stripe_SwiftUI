//
//  FruitStoreApp.swift
//  FruitStore
//
//  Created by Mohammad Azam on 10/6/21.
//

import SwiftUI
import Stripe

@main
struct FruitStoreApp: App {
    
    init() {
        StripeAPI.defaultPublishableKey = "pk_test_51Jch2bCDF37nbEnL0zLYLdbTniQbQObPsjOWMpzPSkDEBQdBS4rs2mKAYgaLLYGGotCyd9Q3zWTEa56ohbCpqjga00nn0fWAQl"
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(Cart())
        }
    }
}
