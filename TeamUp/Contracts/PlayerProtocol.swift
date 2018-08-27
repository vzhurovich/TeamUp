//
//  PlayerProtocol.swift
//  TeamUp
//
//  Created by Vladimir on 5/24/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

public let xKeep = 60
public let xDef = 200
public let xForward = 400
public let yLeft = 200
public let yCenter = 340
public let yRight = 476
public let yForwardOffset = 50

public enum FieldPosition: Int {
    case Keeper
    case RightDef
    case LeftDef
    case MiddleDef
    case RightForward
    case LeftForward
    case CenterForward

    public func origin() -> CGPoint {
        switch self {
        case .Keeper:
            return CGPoint(x: xKeep, y: yCenter)
        case .RightDef:
            return CGPoint(x: xDef, y: yRight)
        case .LeftDef:
            return CGPoint(x: xDef, y: yLeft)
        case .MiddleDef:
            return CGPoint(x: xDef, y: yCenter)
        case .RightForward:
            return CGPoint(x: xForward, y: yRight + yForwardOffset)
        case .LeftForward:
            return CGPoint(x: xForward, y: yLeft - yForwardOffset)
        case .CenterForward:
            return CGPoint(x: xForward + 150, y: yCenter)
        }
    }
}

public protocol PlayerProtocol {
    var firstName: String { get }
    var secondName: String { get }
    var nickName: String { get }
}

public protocol SeasonPlayerProtocol: PlayerProtocol {
    var isFullTimer: Bool { get }
}

public protocol LivePlayerProtocol: SeasonPlayerProtocol {
    var postition: FieldPosition { get }
    var isOnBench: Bool { get set }
    var totalTimeOnField: TimeInterval { get set }
    var prefferedSubs: [String] { get set }
}
