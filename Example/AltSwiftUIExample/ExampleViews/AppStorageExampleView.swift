//
//  AppStorageExampleView.swift
//  AltSwiftUIExample
//
//  Created by yang.q.wang on 2021/3/1.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

enum Day: Int {
    case Monday,Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}
enum Country: String {
    case China = "China"
    case Japan = "Japan"
}
struct AppStorageExampleView: View {
    var viewStore = ViewValues()
    @AppStorage("username" , store:UserDefaults(suiteName: "com.rakuten.www")) var username = "David"
    @AppStorage("optionalBool") var optionalBool: Bool?
    @AppStorage("initalInt") var initalInt:Int = 10
    @AppStorage("today") var today = Day.Monday
    var body: View {    
        VStack {
            Text("\(self.username)")
            TextField("Please enter your name", text: $username)
            HStack{
                if let tempOptionalBool = self.optionalBool {
                    if tempOptionalBool {
                        Text("I am optionalBool variable and I am true").multilineTextAlignment(.leading)
                    }else{
                        Text("I am optionalBool variable and I am false").multilineTextAlignment(.leading)
                    }
                }else{
                    Text("I am optionalBool variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalBool == nil {
                        self.optionalBool = true
                    }else{
                        self.optionalBool = !self.optionalBool!
                    }
                }
                Button("Set nil Value") {
                    self.optionalBool = nil
                }
            }.padding()
            HStack{
                switch self.today {
                case .Monday:
                    Text("I am Enum variable and today is Monday").multilineTextAlignment(.leading)
                case .Tuesday:
                    Text("I am Enum variable and today is Tuesday").multilineTextAlignment(.leading)
                case .Wednesday:
                    Text("I am Enum variable and today is Wednesday").multilineTextAlignment(.leading)
                case .Thursday:
                    Text("I am Enum variable and today is Thursday").multilineTextAlignment(.leading)
                case .Friday:
                    Text("I am Enum variable and today is Friday").multilineTextAlignment(.leading)
                case .Saturday:
                    Text("I am Enum variable and today is Saturday").multilineTextAlignment(.leading)
                case .Sunday:
                    Text("I am Enum variable and today is Sunday").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.today.rawValue < 6{
                        self.today = Day(rawValue: self.today.rawValue + 1)!
                    }else{
                        self.today = .Monday
                    }
                }
            }.padding()
            HStack{
                Text("I am IntialInt variable and value is \(self.initalInt)").multilineTextAlignment(.leading)
                Spacer()
                Button("Set Value") {
                    self.initalInt += 20
                }
            }.padding()
        }
    }
}

