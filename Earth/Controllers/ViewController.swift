//
//  ViewController.swift
//  Earth
//
//  Created by Kacy James on 3/29/18.
//  Copyright © 2018 Kacy James. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var earthView: EarthView!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func prefersHomeIndicatorAutoHidden() -> Bool {
    return true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    earthView.allowsCameraControl = true
    // earthView.showsStatistics = true
  }

}

