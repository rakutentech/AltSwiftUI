//
//  RamenExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/09/24.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit
import AltSwiftUI
import protocol AltSwiftUI.ObservableObject
import class AltSwiftUI.Published

struct Ramen: Identifiable {
    var id: String
    var name: String
    var score: Int
    var price: String
}

class RamenModel: ObservableObject {
    @Published var ramenList: [Ramen] = []

    func loadRamen() {
        ramenList = [
            Ramen(id: "0", name: "Tonkotsu Ramen", score: 4, price: "¥890"),
            Ramen(id: "1", name: "Shio Ramen", score: 3, price: "¥900"),
            Ramen(id: "2", name: "Miso Ramen", score: 5, price: "¥900"),
            Ramen(id: "3", name: "Shoyu Ramen", score: 3, price: "¥920"),
            Ramen(id: "4", name: "Taiwan Ramen", score: 4, price: "¥1000"),
            Ramen(id: "5", name: "Tonkotsu Ramen Extra", score: 3, price: "¥1100"),
            Ramen(id: "6", name: "Shio Ramen Extra", score: 3, price: "¥1200"),
            Ramen(id: "7", name: "Miso Ramen Extra", score: 2, price: "¥1200"),
            Ramen(id: "8", name: "Shoyu Ramen Extra", score: 4, price: "¥1300"),
            Ramen(id: "9", name: "Taiwan Ramen Extra", score: 5, price: "¥1400"),
            Ramen(id: "10", name: "Miso Ramen Extra 2", score: 2, price: "¥1200"),
            Ramen(id: "11", name: "Shoyu Ramen Extra 2", score: 4, price: "¥1300"),
            Ramen(id: "12", name: "Taiwan Ramen Extra 2", score: 5, price: "¥1400")
        ]
    }
}

extension Color {
    static var label: Color {
        if #available(iOS 13.0, *) {
            return Color(.label)
        } else {
            return Color(.black)
        }
    }
}

struct RamenExampleView: View {
    var viewStore = ViewValues()
    
    @StateObject var ramenModel = RamenModel()
    @State private var ramenInOrder: Bool = false
    @State private var offset: CGPoint = .zero
    @State private var imageGeometry: GeometryProxy = .default
    @State private var appliedRect: CGRect?
    @State private var interactiveScrollEnabled = true
    
    var body: View {
        NavigationView {
            ScrollView {
                VStack {
                    RamenIcon(imageGeometry: $imageGeometry, offset: $offset)
                    
                    if ramenInOrder {
                        ramenInOrderView
                            .transition(.opacity)
                    }
                    
                    HStack {
                        Button("Remove") {
                            withAnimation {
                                _ = ramenModel.ramenList.remove(at: 3)
                            }
                        }
                        Button("Add") {
                            withAnimation {
                                ramenModel.ramenList.insert(Ramen(id: UUID().uuidString, name: "Insert Ramen", score: 3, price: "20"), at: 3)
                            }
                        }
                        Button("Update") {
                            withAnimation {
                                ramenModel.ramenList[3].name = "Updated Ramen"
                                ramenModel.ramenList[3].price = "100"
                            }
                        }
                        Button("Toggle") {
                            withAnimation {
                                if ramenModel.ramenList[3].score == 6 {
                                    ramenModel.ramenList[3].score = 5
                                } else {
                                    ramenModel.ramenList[3].score = 6
                                }
                            }
                        }
                        Button("Int. Lock") {
                            interactiveScrollEnabled.toggle()
                        }
                        Button("Visible") {
                            withAnimation {
                                appliedRect = CGRect(x: 0, y: 0, width: 1, height: 1)
                            }
                        }
                    }

                    ForEach(ramenModel.ramenList) { ramen in
                        // ...
                        NavigationLink(destination: RamenDetailView(ramenInOrder: $ramenInOrder, ramen: ramen)) {
                            RamenCell(ramen: ramen)
                        }
                        .accentColor(Color.label)
                    }
                }
                .skipHighPerformanceUpdate()
            }
            .contentOffset($offset)
            .appliedVisibleRect($appliedRect)
            .interactiveScrollEnabled(interactiveScrollEnabled)
            .navigationBarTitle("My Ramen Store", displayMode: .inline)
            .onAppear {
                ramenModel.loadRamen()
            }
        }
    }
    
    var ramenInOrderView: View {
        VStack {
            Text("Preparing Ramen")
                .font(.title)
            Text("Please wait...")
    
            Button("Cancel") {
                withAnimation {
                    ramenInOrder = false
                }
            }
            .frame(width: 120, height: 30)
            .cornerRadius(10)
            .background(Color.blue)
            .accentColor(Color.white)
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(Color(white: 0.9))
    }
}

struct RamenIcon: View {
    var viewStore = ViewValues()
    
    @Binding var imageGeometry: GeometryProxy
    @Binding var offset: CGPoint
    var imageScaleIncrease: CGFloat {
        -(offset.y / 200)
    }
    
    var body: View {
        Image("icon")
            .offset(y: min(0, -(imageGeometry.size.height * imageScaleIncrease / 2)))
            .scaleEffect(max(1, 1 + imageScaleIncrease))
            .geometryListener($imageGeometry)
            .padding(20)
    }
}

struct RamenCell: View {
    var viewStore = ViewValues()
    let ramen: Ramen

    var body: View {
        HStack {
            Text("\(ramen.score)")
                .frame(width: 30, height: 30)
                .cornerRadius(15)
                .background(Color.green)
            Text("\(ramen.name)")
                .padding(.leading, 10)
            Spacer()
            Text("\(ramen.price)")
        }
        .frame(height: ramen.score == 6 ? 260 : 40)
        .padding(10)
    }
}

struct RamenDetailView: View {
    var viewStore = ViewValues()

    @Binding var ramenInOrder: Bool
    let ramen: Ramen
    
    // RamenDetailView
    @Environment(\.presentationMode) var presentationMode

    var body: View {
        VStack(alignment: .trailing, spacing: 10) {
            Text(ramen.price)
                .font(.headline)

            Button("Order") {
                ramenInOrder = true
                presentationMode.wrappedValue.dismiss()
            }
            .font(.headline)
            .accessibility(identifier: "OrderButton")

            Spacer()
        }
        // ...
        .frame(maxWidth: .infinity)
        .padding(10)
        .navigationBarTitle(ramen.name, displayMode: .large)
    }
}
