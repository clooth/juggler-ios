//
//  Message.swift
//  juggler
//
//  Created by Nico Hämäläinen on 30/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

class Message: NSObject, JSQMessageData {
  var text_: String
  var sender_: String
  var date_: NSDate
  var juggler: Juggler

  init(text: String?, sender: String?) {
    self.text_ = text!
    self.sender_ = sender!
    self.date_ = NSDate()
    self.juggler = Juggler()
  }

  func text() -> String! {
    return text_
  }

  func sender() -> String! {
    return sender_
  }

  // MARK: JSQMessageDatas

  func senderId() -> String! {
    return sender_
  }

  func senderDisplayName() -> String! {
    return sender_
  }

  func date() -> NSDate! {
    return date_
  }

  func isMediaMessage() -> Bool {
    return false
  }

  func hash() -> UInt {
    return UInt(super.hash)
  }
}
