//
//  DraggableViewProtocol.swift
//  TeamUp
//
//  Created by Vladimir on 8/13/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

public enum CompletionStatus: UInt8 {
    case failed = 0
    case succeededLivePlayer
    case succeededBall
    case outOfSpecialZone
}
    
public protocol DraggableViewProtocol: class {
    var allowedAreaFrame: CGRect? { get set }
    var lastCenterPoint: CGPoint? { get set }
    
    func dragEndedOnPlayer(player: DraggableViewProtocol, onCompletion: @escaping (CompletionStatus)->())
    func dragEndedOnSpecialZone(onCompletion: @escaping (CompletionStatus)->())
}

extension DraggableViewProtocol {
    public func isAllowedMovementTo(newCenterPoint: CGPoint) -> Bool {
        guard let allowedAreaFrame = allowedAreaFrame else { return false }
        return allowedAreaFrame.contains(newCenterPoint)
    }
}

extension DraggableViewProtocol {
    public func cancelMovement() {
        guard let lastCenterPoint = lastCenterPoint, let view = self as? UIView else { return }
        view.center = lastCenterPoint
    }
    
    public func updateLastCenterPoint() {
        guard let view = self as? UIView else { return }
        self.lastCenterPoint = view.center
    }
    
    public func movementFinishedSuccessfully() {
        updateLastCenterPoint()
    }
}

