//
//  UIApplication.swift
//  AltSwiftUI
//
//  Created by Tanabe, Alex on 2020/07/20.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import UIKit

extension UIApplication {
    var activeWindow: UIWindow? {
        if #available(iOS 13, *),
            let foregroundActiveScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let activeWindow = (foregroundActiveScene.delegate as? UIWindowSceneDelegate)?.window {
            return activeWindow
        } else {
            return keyWindow
        }
    }
}
