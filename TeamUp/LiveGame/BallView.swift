//
//  BallView.swift
//  TeamUp
//
//  Created by Vladimir on 8/13/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

class BallView: UIImageView, DraggableViewProtocol {
    
    var lastCenterPoint: CGPoint?
    var allowedAreaFrame: CGRect?
    
    var fieldCenter = CGPoint(x: 511, y: 400)
    var theirGoalCenter = CGPoint(x: 975.5, y: 400)
    var ourGoalCenter = CGPoint(x: 47, y: 400)
    var ourGoalZone = CGRect(x: 66, y: 240, width: 134, height: 320)
    
    // MARK: DraggableViewProtocol
    func dragEndedOnPlayer(player: DraggableViewProtocol, onCompletion: @escaping (CompletionStatus) -> ()) {
        guard var otherPlayerView = player as? LivePlayerView else {
            onCompletion(.failed)
            return
        }
        animateGoal(weScore: true, onCompletion: onCompletion)
    }
    
    func dragEndedOnSpecialZone(onCompletion: @escaping (CompletionStatus)->()) {
        if ourGoalZone.contains(self.center) {
            animateGoal(weScore: false, onCompletion: onCompletion)
        } else {
            onCompletion(.outOfSpecialZone)
        }
    }
    
    // MARK: Private
    private func animateGoal(weScore: Bool, onCompletion: @escaping (CompletionStatus)->()) {
        let goalCenter = weScore ? theirGoalCenter : ourGoalCenter
        UIView.animate(withDuration: 0.5, animations: { [weak self, goalCenter] in
            guard let strongSelf = self else {
                onCompletion(.failed)
                return
            }
            strongSelf.center = goalCenter}, completion: { [weak self] _ in
                guard let strongSelf = self else {
                    onCompletion(.failed)
                    return
                }
                strongSelf.center = strongSelf.fieldCenter
                strongSelf.lastCenterPoint = strongSelf.fieldCenter
                //TODO: register goal for Player (if our
                onCompletion(.succeededBall)
        })
    }
}
