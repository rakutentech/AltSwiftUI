//
//  AppDelegate.swift
//  AltSwiftUI
//
//  Created by Wong, Kevin a on 2019/08/26.
//  Copyright © 2019 Rakuten Travel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var mainController: UIViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow()
        mainController = UIHostingController(rootView: ExampleView())
        window?.rootViewController = mainController
        window?.makeKeyAndVisible()
        
        return true
    }
}
