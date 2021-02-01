//
//  AlertsExampleView.swift
//  AltSwiftUIExample
//
//  Created by Tanabe, Alex | Rx | TID on 2021/02/01.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI
import UIKit

struct AlertsExampleView: View {
    var viewStore = ViewValues()
    @State var foregroundDisplayNeeded: Bool = false
    @State var showAlert: Bool = false
    @State var showActionSheet: Bool = false
    @State var showSheet: Bool = false
    
    var body: View {
        VStack(spacing: 8) {
            Button("Show modal sheet") {
                showSheet = true
            }
            
            Button("Show alert from this view") {
                showAlert = true
            }
            
            Button("Show action sheet from this view") {
                showActionSheet = true
            }
            
            HStack {
                Toggle(isOn: $foregroundDisplayNeeded) {
                    Text("Show Alerts from foreground view")
                        .font(.system(size: 12))
                }
                Spacer()
            }
        }
        .padding(.horizontal, 16.0)
        .sheet(isPresented: $showSheet) {
            VStack(spacing: 8) {
                Button("Show alert from prev. screen") {
                    showAlert = true
                }
                
                Button("Show action sheet from prev. screen") {
                    showActionSheet = true
                }
                
                Text("Alerts/Action sheets are shown from previous screen")
                    .font(.system(size: 12))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
        }
        .alert(isPresented: $showAlert, onForegroundView: foregroundDisplayNeeded) {
            Alert(
                title: Text("Alert!"),
                message: Text("Dismiss me please :("),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        showAlert = false
                    }
                )
            )
        }
        .actionSheet(isPresented: $showActionSheet, onForegroundView: foregroundDisplayNeeded) {
            ActionSheet(
                title: Text("Action Sheet!"),
                message: Text("Dismiss me please :("),
                buttons: [.default(
                    Text("OK"),
                    action: {
                        showActionSheet = false
                    }
                )]
            )
        }
    }
}
