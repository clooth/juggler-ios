//
//  Message.swift
//  juggler
//
//  Created by Nico Hämäläinen on 30/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

class Message {

  var content: String
  var createdAt: NSDate

  init(content: String, createdAt: NSDate) {
    self.content = content
    self.createdAt = createdAt
  }

  class func allMessages() -> [Message] {
    return []
  }
   
}
