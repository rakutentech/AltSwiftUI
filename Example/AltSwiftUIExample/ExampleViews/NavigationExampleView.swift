//
//  NavigationExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/11/06.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct NavigationExampleView: View {
    var viewStore = ViewValues()
    
    @State private var sheet1 = false
    @State private var sheet2 = false
    @State private var sheet3 = false
    @State private var sheet4 = false
    
    var body: View {
        VStack {
            Button("Sheet 1") {
                sheet1 = true
            }
            .sheet(isPresented: $sheet1) {
                Text("Sheet 1")
            }
            
            Button("Sheet 2") {
                sheet2 = true
            }
            .sheet(isPresented: $sheet2) {
                Text("Sheet 2")
            }
            
            Button("Sheet 3 - NextView") {
                sheet3 = true
            }
            .sheet(isPresented: $sheet3) {
                NavigationExampleNextView(show: $sheet3)
            }
            
            Button("Sheet 4 - NextView") {
                sheet4 = true
            }
            .sheet(isPresented: $sheet4) {
                NavigationExampleNextView(show: $sheet4)
            }
        }
    }
}

struct NavigationExampleNextView: View {
    var viewStore = ViewValues()
    @Binding var show: Bool
    
    var body: View {
        Button("Close") {
            show = false
        }
    }
}
