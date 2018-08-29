//
//  CustomView.swift
//  TeamUp
//
//  Created by Vladimir on 5/10/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

class LivePlayerView: UIView, WatchProtocol, DraggableViewProtocol {

    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    var livePlayer: LivePlayerProtocol
    let fieldPlayerFaces = ["smileFace","hungryFace","crazyFace"]
    let benchPlayerFaces = ["greenSmily","shockFace","angryRed"]

    var showTotalTimeOnField: Bool = false
    var currentETime: TimeInterval = 0
    var benchZone = CGRect(x: 30, y: 698, width: 681, height: 66)
    var fieldZone = CGRect()
    
    var onOneTap:((LivePlayerView) -> ())?
    
    @IBAction func tapGesture(_ sender: Any) {
        print("---TapGesture")
        onOneTap?(self)
    }
    // MARK: WatchProtocol
    var startTime = TimeInterval()
    var timeFromStart: TimeInterval?
    var periodTimeInterval: TimeInterval?
    var triggerTimeIntervals: [UInt16] = [0,3*60 + 45,6*60]//[180]
    var doActionOnTime: ((UInt16)->())?
    
    // MARK: DraggableViewProtocol
    var allowedAreaFrame: CGRect?
    var lastCenterPoint: CGPoint?
    
    init(livePlayer: LivePlayerProtocol) {
        self.livePlayer = livePlayer
        super.init(frame: CGRect.zero)
        fromNib()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.livePlayer = LivePlayer(firstName: "", secondName: "", nickName: "", isFullTimer: true, postition: .CenterForward, isOnBench: false, totalTimeOnField: 0, prefferedSubs: [])
        super.init(coder: aDecoder)

        fromNib()
        setupAppearance()
    }
    
    public func updateElapsedTime() {
        currentETime = currentElapsedTime()
    }
    
    //WatchProtocol
    func updateTime() {
        let currentTimeOnField = livePlayer.isOnBench ? 0 : currentETime
        let totalTime = self.timeIntervalToString(time: livePlayer.totalTimeOnField + currentTimeOnField)
        timeLabel.text = showTotalTimeOnField ? totalTime : timeTextOrCurrentETime()
    }
    
    func timeTextOrCurrentETime() -> String {
        if timeFromStart == nil {
            return timeText()
        } else {
            return self.timeIntervalToString(time: currentETime)
        }
    }
    
    // DraggableViewProtocol
    func dragEndedOnPlayer(player: DraggableViewProtocol, onCompletion: @escaping (CompletionStatus) -> ()) {
        guard var otherPlayerView = player as? LivePlayerView else {
            onCompletion(.failed)
            return
        }
        let completionStatus: CompletionStatus = self.exchangeWith(playerView: &otherPlayerView) ? .succeededLivePlayer : .failed
        onCompletion(completionStatus)
    }
    
    func dragEndedOnSpecialZone(onCompletion: @escaping (CompletionStatus)->()) {
        
        if benchZone.contains(self.center) {
            guard moved(toBench: true) else {
                onCompletion(.failed)
                return
            }
        } else if fieldZone.contains(self.center) {
            moved(toBench: false)
        } else {
            onCompletion(.failed)
            return
        }
        onCompletion(.succeededLivePlayer)
    }
    
    //Mark: Bench helpers
    public func exchangeWith(playerView: inout LivePlayerView) -> Bool {
        guard self.livePlayer.isOnBench != playerView.livePlayer.isOnBench else { return false }
        setBenchState(isOnBench: !self.livePlayer.isOnBench)
        playerView.setBenchState(isOnBench: !playerView.livePlayer.isOnBench)
        
        
        UIView.animate(withDuration: 0.5, animations: {[weak self, playerView] in
            guard let strongSelf = self else { return }
            strongSelf.center = playerView.lastCenterPoint!
            playerView.center = strongSelf.lastCenterPoint!
        })
        
        self.lastCenterPoint = playerView.lastCenterPoint
        playerView.updateLastCenterPoint()
        
        resetState()
        playerView.resetState()
        return true
    }
    
    @discardableResult
    public func moved(toBench: Bool) -> Bool {
        guard self.livePlayer.isOnBench != toBench else { return false }
        setBenchState(isOnBench: toBench)
        resetState()
        return true
    }
    
    private func setBenchState(isOnBench: Bool) {
        if isOnBench && !self.livePlayer.isOnBench {
            self.livePlayer.totalTimeOnField += currentETime
        }
        self.livePlayer.isOnBench = isOnBench
    }
    
    private func resetState() {
        resetTimer()
        currentETime = 0
        updateTime()
        updateFaceImage(index: 0)
    }
    
    //Mark: Helpers
    private func setupAppearance() {
        bodyView.layer.cornerRadius = 5.0
        timeLabel.layer.masksToBounds = true
        timeLabel.layer.cornerRadius = 5.0
        nameLabel.text = livePlayer.nickName
        updateFaceImage(index: 0)
        if (livePlayer.postition != .Keeper) {
            doActionOnTime = { [weak self] ( timeInterval ) in
                guard let strongSelf = self, let indx = strongSelf.triggerTimeIntervals.index(of: timeInterval) else { return }
                strongSelf.updateFaceImage(index: indx)
            }
        }
    }
    
    private func updateFaceImage(index: Int) {
        let imageName = self.livePlayer.isOnBench ? self.benchPlayerFaces[index] : self.fieldPlayerFaces[index]
        self.faceImageView.image = UIImage(named:imageName)
    }
    
    public func updateKeepFaceOnScore(difference: Int8)
    {
        guard livePlayer.postition == .Keeper else { return }
        var imageName = "keepInitial"
        switch(difference) {
        case 0 :
            imageName = "keepInitial"
        case -1 :
            imageName = "keepMinus1"
        case -2 :
            imageName = "keepMinus2"
        default:
            imageName = (difference < -2) ? "keepMinus3":"smileFace"
        }
        self.faceImageView.image = UIImage(named:imageName)
    }

}
