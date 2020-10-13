//
//  TextExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/10/13.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct TextExampleView: View {
    var viewStore = ViewValues()
    var body: View {
        VStack {
            Text("Properties")
                .strikethrough(true, color: .red)
                .underline(true, color: .green)
        }
    }
}
