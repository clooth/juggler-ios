//
//  Juggler.swift
//  juggler
//
//  Created by Nico Hämäläinen on 29/01/15.
//  Copyright (c) 2015 Nico Hämäläinen. All rights reserved.
//

import UIKit



class Juggler {
  var markovChain: [String: [String]]

  init() {
    markovChain = [:]

    markovChain.updateValue([], forKey: "_start")
    markovChain.updateValue([], forKey: "_end")
  }

  func learnSentence(sentence: String) {
    // Put each word into an array
    let words = split(sentence) { $0 == " " }

    for var index = 0; index < words.count; index++ {
      let word = words[index].lowercaseString

      // Add the start and end words to their own vector
      if index == 0 {
        markovChain["_start"]?.append(word)

        if words.count > 1 {
          var suffix = markovChain[word]
          if suffix == nil {
            suffix = []
            suffix?.append(words[index + 1])
            markovChain.updateValue(suffix!, forKey: word)
          }
        }
      }
      else if index == words.count - 1 {
        markovChain["_end"]?.append(word)
      }
      else {
        var suffix = markovChain[word]
        if suffix == nil {
          suffix = []
          suffix?.append(words[index + 1])
          markovChain.updateValue(suffix!, forKey: word)
        }
        else {
          suffix?.append(words[index + 1])
          markovChain.updateValue(suffix!, forKey: words[index])
        }
      }
    }
  }

  func generateSentence() -> String {
    var sentence = [String]()

    // String for the next word
    var nextWord = ""

    // Select first word
    let startWords: [String]! = markovChain["_start"]
    nextWord = startWords[Int(arc4random_uniform(UInt32(startWords.count)))]
    sentence.append(nextWord)

    // Keep looping until the end
    while (Array(nextWord).last? != ".") {
      if let selection = markovChain[nextWord] {
        nextWord = selection[randMax(selection.count)]
        sentence.append(nextWord)
      }
      else {
        break
      }
    }

    return join(" ", sentence)
  }

  func randMax(max: Int) -> Int {
    return Int(arc4random_uniform(UInt32(max)))
  }

  // MARK: Learnding

  func learnFromFile(fileName: String, type: String) {
    let path = NSBundle.mainBundle().pathForResource(fileName, ofType: type)
    var possibleContent = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)

    if let content = possibleContent {
      var array = content.componentsSeparatedByString("\n")
      for sentence in array {
        self.learnSentence(sentence)
      }
    }
  }
}


