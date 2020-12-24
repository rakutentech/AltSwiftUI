//
//  SecureFieldExampleView.swift
//  AltSwiftUIExample
//
//  Created by Elvis Lin on 2020/12/24.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct SecureFieldExampleView: View {
    var viewStore = ViewValues()

    @State private var field: String = ""
    @State private var isFirstResponder = true
    
    var body: View {
        VStack(alignment: .center) {
            SecureField("Title", text: $field)
                .firstResponder($isFirstResponder)
                .background(Color.yellow)
        }
    }
}
