//
//  ParseXML.swift
//  learnit
//
//  Created by Matthew McGuire on 8/24/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class ParseXML: NSObject, XMLParserDelegate {
    
    var aNewCard = CardObject()
    var currentElement = ""

    // MARK: - XML Import -
    func addCardsViaXML(fileName : String) -> Void
    {
        if let myResource = Bundle.main.url(forResource: fileName, withExtension: "xml")
        {
            if let simpleParser = XMLParser.init(contentsOf: myResource)
            {
                simpleParser.delegate = self
                simpleParser.parse()
            }
        }
    }
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XML Parsing has begun.")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "card":
            aNewCard = CardObject()
        case "faceOne":
            aNewCard.cardInfo.faceOne = ""
            currentElement = ""
        case "faceOneText":
            if currentElement.characters.count > 0
            {
                currentElement += ", "
            }
        case "faceTwo":
            aNewCard.cardInfo.faceTwo = ""
            currentElement = ""
        case "faceTwoText":
            if currentElement.characters.count > 0
            {
                currentElement += ", "
            }
        case "tags":
            aNewCard.cardInfo.tags = ""
            currentElement = ""
        case "tag":
            if currentElement.characters.count > 0
            {
                currentElement += ", "
            }
        default:
            print("Unknown XML tag. This is not anticipated or handled.")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let elimTrashChars = CharacterSet.whitespacesAndNewlines
        let materialToAdd = string.trimmingCharacters(in: elimTrashChars).replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: ",", with: "##")
        currentElement += materialToAdd
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "card":
            let newCrd = aNewCard
            if newCrd.hasFacesAndTags()
            {
                negozioGrande!.addNewObj(card: newCrd)
            }
        case "faceOne":
            aNewCard.cardInfo.faceOne = currentElement
        case "faceOneText":
            print("\tClosing the 'faceOneText' tag.")
        case "faceTwo":
            aNewCard.cardInfo.faceTwo = currentElement
        case "faceTwoText":
            print("\tClosing the 'faceTwoText' tag.")
        case "tags":
            aNewCard.cardInfo.tags = currentElement
        case "tag":
            print("\tClosing the 'tag' tag.")
        default:
            print("Unknown XML tag. This is not anticipated or handled.")
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        if parser.parserError != nil
        {
            print("XML processing is completed.")
        }
        else
        {
            print("An error occurred during XML processing.")
        }
    }
}
