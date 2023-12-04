//
//  File.swift
//  
//
//  Created by Thiago Henrique on 04/12/23.
//

import Foundation

public struct ThemeManager {
    public var themes: [String] = []
    public var themePhrases: [String: [String]] = [:]

    init() {
        readJSONFile(withName: "ThemePhrases")
    }

    mutating public func readJSONFile(withName name: String) {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: "json"), let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    if let localizedData = try?  JSONSerialization.jsonObject(with: jsonData) as? [String:[String]] {
                        themes = Array(localizedData.keys)
                        themePhrases = localizedData
                    } else {
                        /// Temporary check up
                        assertionFailure("Check the JSON file for the localized version for language \(Locale.current.identifier).")
                    }
            }
        } catch {
            themePhrases = ["Test":["No themes available"]]
            print(error)
        }
    }
}
