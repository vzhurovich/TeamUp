//
//  ScoreProtocol.swift
//  TeamUp
//
//  Created by Vladimir on 8/14/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

public protocol ScoreProtocol: class {
    var ourGoals: UInt8 { get set }
    var theirGoals: UInt8 { get set }
}

extension ScoreProtocol {
    public func goal(our: Bool) {
        if our {
            ourGoals += 1
        } else {
            theirGoals += 1
        }
    }
}
