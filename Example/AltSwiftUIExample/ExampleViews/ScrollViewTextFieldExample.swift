//
//  ScrollViewTextFieldExample.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2021/04/15.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI
import UIKit

struct ScrollViewTextFieldExampleView: View {
    var viewStore = ViewValues()
    
    @State private var text1: String = ""
    @State private var text2: String = ""
    @State private var keyboardDismissType: UIScrollView.KeyboardDismissMode = .onDrag
    
    var body: View {
        VStack {
            Text("Keyboard Dismiss Mode")
            HStack {
                Button("interactive") { keyboardDismissType = .interactive }
                Button("onDrag") { keyboardDismissType = .onDrag }
                Button("none") { keyboardDismissType = .none }
            }
            ScrollView {
                VStack {
                    TextField("Input 1", text: $text1)
                    Rectangle()
                        .fill(.red)
                        .frame(width: 10, height: 1000)
                    TextField("Input 2", text: $text2)
                }
            }
            .keyboardDismissMode(keyboardDismissType)
        }
    }
}
