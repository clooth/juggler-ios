//
//  MessagesTableViewController.swift
//  juggler
//
//  Created by Nico Hämäläinen on 30/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

let MessageBubbleFactory = JSQMessagesBubbleImageFactory()

class MessagesViewController: JSQMessagesViewController {

  // User and messages information
  var user: FAuthData?
  var senderImageUrl: String!

  // Firebase
  var fbase: Firebase!
  var messagesFbase: Firebase!
  var batchMessages = true

  var messages = [Message]()
  var users = []
  var avatars  = [String: UIImage]()
  var jugglers = [String: Juggler]()

  // Setup firebase
  func setupFirebase() {
    messagesFbase = Firebase(url: "https://boiling-inferno-3181.firebaseio.com/messages")
    messagesFbase.observeEventType(.ChildAdded, withBlock: { (snapshot) -> Void in
      let text = snapshot.value["text"] as? String

      if let sender = snapshot.value["sender"] as? String {
        var message = Message(text: text, sender: sender)
        self.messages.append(message)
        self.juggleMessages()
        self.finishReceivingMessage()
      }
    })
  }

  // Bubbles!
  var outgoingBubbleImageView = MessageBubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
  var incomingBubbleImageView = MessageBubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())

  var sender: String?

  // MARK: Initializers

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  func juggleMessages()
  {
    for msg in messages {
      msg.juggler.forgetEverything()

      let date = msg.date()
      let senderId = msg.senderId()

      // Find messages sent after this date by the same person
      let after = messages.filter({ (msg: Message) -> Bool in
        return msg.date().timeIntervalSince1970 > date.timeIntervalSince1970 && senderId == msg.senderId()
      })

      // Scramble if any
      if after.count > 1 {
        for afterMsg in after {
          msg.juggler.learnSentence(afterMsg.text())
        }
        msg.text_ = msg.juggler.generateSentence()
      }
    }
  }

  // MARK: Messages

  func sendMessage(text: String!, sender: String!) {
    messagesFbase.childByAutoId().setValue([
      "text": text,
      "sender": sender
    ])
  }

  func tempSendMessage(text: String!, sender: String!) {
    let message = Message(text: text, sender: sender)
    messages.append(message)
  }

  // MARK: View Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    inputToolbar.contentView.leftBarButtonItem = nil
    automaticallyScrollsToMostRecentMessage = true
    navigationController?.navigationBar.topItem?.title = "Juggler"
    self.automaticallyAdjustsScrollViewInsets = false

    sender = (sender != nil) ? sender : "Anonymous"

    setupFirebase()
//
//    for i in 0..<dummyMessages.count {
//      let user = (i % 2 == 0) ? "Hülje" : "Clååth"
//      let userId = (i % 2 == 0) ? "0" : "1"
//
//      var message = Message(
//        body: dummyMessages[i],
//        sender: user,
//        senderId: userId,
//        created: NSDate()
//      )
//      message.juggler = Juggler()
//
//      messages.append(message)
//    }
//
//    for msg in messages {
//      let date = msg.date()
//      let senderId = msg.senderId()
//
//      // Find messages sent after this date
//      let after = messages.filter({ (msg: Message) -> Bool in
//        return msg.date().timeIntervalSince1970 > date.timeIntervalSince1970 && senderId == msg.senderId()
//      })
//
//      // Scramble
//      if after.count > 1 {
//        for afterMsg in after {
//          msg.juggler.learnSentence(afterMsg.text())
//        }
//        msg.body = msg.juggler.generateSentence()
//      }
//    }

    collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
    collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    collectionView.collectionViewLayout.springinessEnabled = true
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    if fbase != nil {
      fbase.unauth()
    }
  }

  override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
    JSQSystemSoundPlayer.jsq_playMessageSentSound()

    sendMessage(text, sender: sender)
    finishSendingMessage()
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }

  // MARK: JSQMessagesCollectionViewDataSource

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.messages.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    var cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell

    let message = self.messages[indexPath.item]
    if message.senderId() == self.senderId {
      cell.textView.textColor = UIColor.blackColor()
    }
    else {
      cell.textView.textColor = UIColor.whiteColor()
    }

    return cell
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    return self.messages[indexPath.item]
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = self.messages[indexPath.item]

    if message.senderId() == self.senderId {
      return self.outgoingBubbleImageView
    }

    return incomingBubbleImageView
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
    var message = self.messages[indexPath.item]

    if message.sender() == self.sender {
      return nil
    }

    if indexPath.item - 1 > 0 {
      var previousMessage = self.messages[indexPath.item - 1]
      if previousMessage.sender() == message.sender() {
        return nil
      }
    }

    return NSAttributedString(string: message.sender())
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
    return nil
  }

  override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
    let message = messages[indexPath.item]

    // Sent by me, skip
    if message.sender() == sender {
      return CGFloat(0.0);
    }

    // Same as previous sender, skip
    if indexPath.item > 0 {
      let previousMessage = messages[indexPath.item - 1];
      if previousMessage.sender() == message.sender() {
        return CGFloat(0.0);
      }
    }

    return kJSQMessagesCollectionViewCellLabelHeightDefault
  }

//  override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
//    var message = Message(body: text, sender: senderId)
//    messages.append(message)
//  }
}
