//
//  File.swift
//  
//
//  Created by Thiago Henrique on 04/12/23.
//

import Foundation
import ClioEntities

public struct GameFlowParameters {
    public var currenPlayer: User?
    public var players: [User] = []
    public var didPlay: [User] = []
    public var sessionTheme: String = String()
    public var firstRoundPrompt: String = String()
    public var emojisIndexReaction: [Int] = []
}
