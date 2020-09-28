//
//  ListExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/09/28.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct ListExampleView: View {
    var viewStore = ViewValues()
    @StateObject var ramenModel = RamenModel()
    
    var body: View {
        VStack {
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
            }
            List(ramenModel.ramenList) { ramen in
                RamenCell(ramen: ramen)
            }
            .listStyle(listStyle)
        }
        .onAppear {
            ramenModel.loadRamen()
        }
    }
    
    var listStyle: ListStyle {
        if #available(iOS 13.0, *) {
            return InsetGroupedListStyle()
        } else {
            return PlainListStyle()
        }
    }
}
