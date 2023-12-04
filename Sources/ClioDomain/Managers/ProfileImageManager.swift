//
//  File.swift
//  
//
//  Created by Thiago Henrique on 04/12/23.
//

import Foundation

public struct ProfileImageManager {
    var profileColors: [String] = ["Brick", "Lilac", "Peach", "SoftGreen", "Sky"]
    var currentIndex: Int = .random(in: 0..<4)

    mutating public func randomizeProfileImage() -> String {
        let color = profileColors[currentIndex]
        currentIndex = (currentIndex + 1) % profileColors.count // Wrap around to the beginning if needed
        return color
    }
}
