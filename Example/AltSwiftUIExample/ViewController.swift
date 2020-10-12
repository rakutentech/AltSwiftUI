//
//  ViewController.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2019/08/26.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit
import AltSwiftUI
import protocol AltSwiftUI.ObservableObject
import class AltSwiftUI.Published

struct ExampleViewData {
    var title: String
    var destination: View
}

struct ExampleView: View {
    var viewStore = ViewValues()

    var views: [ExampleViewData] = [
        ExampleViewData(title: "Ramen Example", destination: RamenExampleView()),
        ExampleViewData(title: "List", destination: ListExampleView()),
        ExampleViewData(title: "Shapes", destination: ShapesExampleView())
    ]
    
    var body: View {
        NavigationView {
            List(views, id: \ExampleViewData.title) { view in
                NavigationLink(destination: view.destination) {
                    Text("\(view.title)")
                        .multilineTextAlignment(.leading)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarTitle("AltSwiftUI Examples", displayMode: .inline)
    }
}
