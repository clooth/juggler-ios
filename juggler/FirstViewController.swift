//
//  FirstViewController.swift
//  juggler
//
//  Created by Nico Hämäläinen on 29/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
  var juggler = Juggler()

  @IBOutlet weak var gimmeButton: UIButton!
  @IBOutlet weak var sentenceView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
    juggler.learnFromFile("sentences", type: "txt")
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func gimmeButtonTapped(sender: AnyObject) {
    sentenceView.text = juggler.generateSentence()
  }

}

