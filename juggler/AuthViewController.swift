//
//  AuthViewController.swift
//  juggler
//
//  Created by Nico Hämäläinen on 03/02/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit

class AuthViewController: UIViewController, UIActionSheetDelegate {

  var fbase: Firebase!
  var authHelper: TwitterAuthHelper!
  var accounts: [ACAccount]!

  override func viewDidLoad() {
    super.viewDidLoad()

    fbase = Firebase(url: "https://boiling-inferno-3181.firebaseio.com")
    authHelper = TwitterAuthHelper(firebase: fbase, twitterAppId: "WxSQLK5xFYWqFGg6YuIa6YiU8")
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    title = "Juggler"
  }

  @IBAction func login(sender: UIButton) {
    self.authWithTwitter()
  }

  func authWithTwitter() {
    authHelper.selectTwitterAccount { (error, accounts) -> Void in
      self.accounts = accounts as [ACAccount]!
      self.handleMultipleTwitterAccounts(self.accounts)
    }
  }

  func authAccount(account: ACAccount) {
    authHelper.authenticateAccount(account, completion: { (error, authData) -> Void in
      if error != nil {
        // There was an error authenticating
      } else {
        // segue to chat
        self.performSegueWithIdentifier("ShowMainView", sender: authData)
      }
    })
  }

  func selectTwitterAccount(accounts: [ACAccount]) {
    var selectUserActionSheet = UIActionSheet(title: "Select Twitter Account", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: "Close")

    for account in accounts {
      selectUserActionSheet.addButtonWithTitle(account.username)
    }

    selectUserActionSheet.cancelButtonIndex = selectUserActionSheet.addButtonWithTitle("Cancel")
    selectUserActionSheet.showInView(self.view);
  }

  func handleMultipleTwitterAccounts(accounts: [ACAccount]) {
    switch accounts.count {
    case 0:
      UIApplication.sharedApplication().openURL(NSURL(string: "https://twitter.com/signup")!)
    case 1:
      self.authAccount(accounts[0])
    default:
      self.selectTwitterAccount(accounts)
    }
  }

  func actionSheet(actionSheet: UIActionSheet!, clickedButtonAtIndex buttonIndex: Int) {
    let currentTwitterHandle = actionSheet.buttonTitleAtIndex(buttonIndex)
    for acc in accounts {
      if acc.username == currentTwitterHandle {
        self.authAccount(acc)
      }
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    var messagesVc = segue.destinationViewController as MessagesViewController
    if let authData = sender as? FAuthData {
      messagesVc.user = authData
      messagesVc.fbase = fbase
      messagesVc.sender = authData.providerData["username"] as? NSString
    }
  }

}
