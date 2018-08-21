//
//  CustomTabBarController.swift
//  TeamUp
//
//  Created by Vladimir on 4/20/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {
    
    @IBOutlet weak var mainUITabBar: UITabBar!
    
    override func viewDidLayoutSubviews() {
        mainUITabBar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: mainUITabBar.frame.size.height)
    }
}
