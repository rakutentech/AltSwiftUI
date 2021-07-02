//
//  TextFieldExampleView.swift
//  AltSwiftUIExample
//
//  Created by Lin, YingChieh on 2021/03/09.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct TextFieldExampleView: View {
    var viewStore = ViewValues()

    @State private var count = 0
    @State private var field: String = ""
    @State private var isFirstResponder = true

    var body: View {
        VStack(alignment: .center) {
            TextField("Search Keyword", text: $field, onCommit: {
                commitSearchField()
            })
            .firstResponder($isFirstResponder)
            .background(Color.yellow)
            .foregroundColor(Color.purple)
            .padding(.all, 16)

            Text("Search Keyword \(count) times")
                .underline(true, color: .red)
        }
    }

    private func commitSearchField() {
        count += 1
    }
}
