//
//  Player.swift
//  TeamUp
//
//  Created by Vladimir on 5/24/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import Foundation

public struct Player: PlayerProtocol {
    public let firstName: String
    public let secondName: String
    public let nickName: String?
}

public struct LivePlayer: LivePlayerProtocol {    
    public let firstName: String
    public let secondName: String
    public let nickName: String?
    public let isFullTimer: Bool
    public let postition: FieldPosition
    public var isOnBench: Bool
    public var totalTimeOnField: TimeInterval = 0
}
