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
        ExampleViewData(title: "2 Axis Scroll", destination: ScrollView2AxisExampleView()),
        ExampleViewData(title: "Alerts", destination: AlertsExampleView()),
        ExampleViewData(title: "List", destination: ListExampleView()),
        ExampleViewData(title: "List + TextField", destination: ListTextFieldExampleView()),
        ExampleViewData(title: "Navigation", destination: NavigationExampleView()),
        ExampleViewData(title: "ScrollView + TextField", destination: ScrollViewTextFieldExampleView()),
        ExampleViewData(title: "SecureField", destination: SecureFieldExampleView()),
        ExampleViewData(title: "Stack Update", destination: StackUpdateExample()),
        ExampleViewData(title: "Menu", destination: MenuExampleView()),
        ExampleViewData(title: "Shapes", destination: ShapesExampleView()),
        ExampleViewData(title: "Stack Update", destination: StackUpdateExample()),
        ExampleViewData(title: "Texts", destination: TextExampleView()),
        ExampleViewData(title: "Ramen Example", destination: RamenExampleView())
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
