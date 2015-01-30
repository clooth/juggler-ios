//
//  MessageViewModel.swift
//  juggler
//
//  Created by Nico Hämäläinen on 30/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

class MessageViewModel {

  var messageContent: String?

  init(messageContent: String? = nil) {
    self.messageContent = messageContent
  }

  func createMessage() -> Message? {
    switch (messageContent) {
    case let (.Some(messageContent)):
      return Message(content: messageContent, createdAt: NSDate())
    default:
      return nil
    }
  }

}
