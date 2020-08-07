//
//  ViewController.swift
//  camera_test
//
//  Created by 史圣久 on 2020/8/6.
//  Copyright © 2020 史圣久. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCanUseCamera() == true {
            let vc = camerView()
            self.present(vc, animated:true, completion: { () -> Void in } )
        }
    }
}

