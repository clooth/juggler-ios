//
//  TwitterAuthHelper.swift
//  juggler
//
//  Created by Nico Hämäläinen on 03/02/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit
import Social

enum AuthHelperError: Int {
  case AuthHelperErrorAccountAccessDenied = 0
}

typealias AuthUserCallback = (error: NSError?, authData: FAuthData?) -> Void

class TwitterAuthHelper: NSObject {

  var store: ACAccountStore?
  var fbase: Firebase
  var appId: String

  private var request:  SLRequest?
  private var account:  ACAccount?
  private var callback: AuthUserCallback?

  // MARK: Initializers

  init(firebase: Firebase, twitterAppId: String) {
    self.store = ACAccountStore()
    self.appId = twitterAppId
    self.fbase = firebase
    super.init()
  }

  // MARK: Twitter Callbacks

  func selectTwitterAccount(completion block: (error: NSError?, accounts: [ACAccount]?) -> Void) {
    let accountType = store?.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

    store?.requestAccessToAccountsWithType(accountType, options: nil, completion: { (granted, error) -> Void in
      if granted {
        let accounts = self.store?.accountsWithAccountType(accountType)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          block(error: nil, accounts: accounts as? [ACAccount])
        })
      }
      else {
        let error = NSError(
          domain: "TwitterAuthHelper",
          code: AuthHelperError.AuthHelperErrorAccountAccessDenied.rawValue,
          userInfo: [NSLocalizedDescriptionKey: "Access to twitter accounts denied."]
        )
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          block(error: error, accounts: nil)
        })
      }
    })
  }

  func authenticateAccount(account: ACAccount, completion block: AuthUserCallback) {
    self.account = account
    self.callback = block
    self.makeReverseRequest()
  }

  // MARK: Private methods

  private func callbackIfExistsWithError(error: NSError?, authData: FAuthData?) {
    if let cb = callback {
      cb(error: error, authData: authData)
    }
  }

  private func makeReverseRequest() {
    fbase.makeReverseOAuthRequestTo("twitter") { (error, json: [NSObject: AnyObject]!) -> Void in
      if error != nil {
        self.callbackIfExistsWithError(error, authData: nil)
      }
      else {
        self.request = self.createCredentialsRequestWithReverseAuthPayload(json)
        self.requestTwitterCredentials()
      }
    }
  }

  private func createCredentialsRequestWithReverseAuthPayload(json: [NSObject: AnyObject]) -> SLRequest? {
    var params: [String: String] = [:]

    if let token = json["oauth"] as? String {
      params.updateValue(token, forKey: "x_reverse_auth_parameters")
      params.updateValue(appId, forKey: "x_reverse_auth_target")

      var url = NSURL(string: "https://api.twitter.com/oauth/access_token")
      var req = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, URL: url, parameters: params)
      req.account = account

      return req
    }

    return nil
  }

  private func requestTwitterCredentials() {
    request?.performRequestWithHandler({ (data, response, error) -> Void in
      if error != nil {
        self.callbackIfExistsWithError(error, authData: nil)
      }
      else {
        self.authenticateWithTwitterCredentials(data)
      }
    })
  }

  private func authenticateWithTwitterCredentials(data: NSData) {
    var params = parseTwitterCredentials(data)
    fbase.authWithOAuthProvider("twitter", parameters: params, withCompletionBlock: callback)
  }

  private func parseTwitterCredentials(data: NSData) -> [String: String] {
    var accountData = NSString(data: data, encoding: NSUTF8StringEncoding) as String
    var params = [String: String]()

    var creds = split(accountData) { $0 == "&" }
    for param in creds {
      var parts = split(param) { $0 == "=" }
      params.updateValue(parts[1], forKey: parts[0])
    }

    return params
  }
}
