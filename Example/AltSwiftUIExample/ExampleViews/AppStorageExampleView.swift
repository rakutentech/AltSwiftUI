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
//    @AppStorage("optionalInt") var optionalInt: Int?
//    @AppStorage("optionalDouble") var optionalDouble: Double?
//    @AppStorage("optionalString") var optionalString:String?
//    @AppStorage("optionalUrl") var optionalUrl:URL?
//    @AppStorage("optionalData") var optionalData:Data?
//
//    @AppStorage("initalBool") var initalBool = false
    @AppStorage("initalInt") var initalInt = 100
//    @AppStorage("initalDouble") var initalDouble = 100
//    @AppStorage("initalString") var initalString = 100
//    @AppStorage("initalUrl") var initalUrl = URL(string: "http://youtube.com")!
//    @AppStorage("initalData") var initalData = "AltSwiftUI AppStorage".data(using: .utf8)!
//
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
            /*HStack{
                if let tempOptionalInt = self.optionalInt {
                    Text("I am optionalInt variable and I am \(tempOptionalInt)").multilineTextAlignment(.leading)
                }else{
                    Text("I am optionalInt variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalInt == nil {
                        self.optionalInt = 0
                    }else{
                        self.optionalInt = self.optionalInt! + 1
                    }
                }
            }.padding()
            HStack{
                if let tempOptionalDouble = self.optionalDouble {
                    Text("I am optionalDouble variable and I am \(tempOptionalDouble)").multilineTextAlignment(.leading)
                }else{
                    Text("I am optionalDouble variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalDouble == nil {
                        self.optionalDouble = 0.1
                    }else{
                        self.optionalDouble = self.optionalDouble! + 0.1
                    }
                }
            }.padding()
            HStack{
                if let tempOptionalString = self.optionalString {
                    Text("I am optionalString variable and I am \(tempOptionalString)").multilineTextAlignment(.leading)
                }else{
                    Text("I am optionalString variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalString == nil {
                        self.optionalString = "Text Value"
                    }else{
                        self.optionalString = self.optionalString! + "|A|"
                    }
                }
            }.padding()
            HStack{
                if let tempOptionalUrl  = self.optionalUrl {
                    Text("I am optionalUrl variable and I am \(tempOptionalUrl)").multilineTextAlignment(.leading)
                }else{
                    Text("I am optionalUrl variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalUrl == nil {
                        self.optionalUrl = URL(string: "https://google.com")
                    }else{
                        self.optionalUrl = URL(string: "https://apple.com")
                    }
                }
            }.padding()
            HStack{
                if let tempOptionalData  = self.optionalData {
                    Text("I am optionalData variable and I am \(String(data: tempOptionalData, encoding: .utf8)!)").multilineTextAlignment(.leading)
                }else{
                    Text("I am optionalData variable and I am nil").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    if self.optionalData == nil {
                        self.optionalData = "123456789".data(using: .utf8)
                    }else{
                        self.optionalData = "abcdefg".data(using: .utf8)
                    }
                }
            }.padding()
            Text("Inital Value Demo").multilineTextAlignment(.center).background(.red).font(Font.largeTitle)
            HStack{
                if self.initalBool {
                    Text("I am InitalBool variable and I am true").multilineTextAlignment(.leading)
                }else{
                    Text("I am InitalBool variable and I am false").multilineTextAlignment(.leading)
                }
                Spacer()
                Button("Set Value") {
                    self.initalBool = !self.initalBool
                }
            }.padding()*/
        }
    }
}

