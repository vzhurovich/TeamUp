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
    var benchZone = CGRect(x: 30, y: 698, width: 481, height: 66)
    var fieldZone = CGRect()
    
    @IBAction func tapGesture(_ sender: Any) {
        print("---TapGesture")
    }
    //WatchProtocol
    var startTime = TimeInterval()
    var timeFromStart: TimeInterval?
    var periodTimeInterval: TimeInterval?
    var triggerTimeIntervals: [UInt16] = [0,3*60 + 45,6*60]//[180]
    var doActionOnTime: ((UInt16)->())?
    
    //DraggableViewProtocol
    var allowedAreaFrame: CGRect?
    var lastCenterPoint: CGPoint?
    
//    func cancelMovement() {
//        guard let lastCenterPoint = lastCenterPoint else { return }
//        self.center = lastCenterPoint
//    }
//    
//    func movementFinishedSuccessfully() {
//        lastCenterPoint = self.center
//    }
    
    init(livePlayer: LivePlayerProtocol) {
        self.livePlayer = livePlayer
        super.init(frame: CGRect.zero)
        fromNib()
        setupAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.livePlayer = LivePlayer(firstName: "", secondName: "", nickName: "", isFullTimer: true, postition: .CenterForward, isOnBench: false, totalTimeOnField: 0)
        super.init(coder: aDecoder)

        fromNib()
        setupAppearance()
    }

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
    
    public func resetState() {
        resetTimer()
        currentETime = 0
        updateTime()
        updateFaceImage(index: 0)
    }
    
    public func updateElapsedTime() {
        currentETime = currentElapsedTime()
    }
    
    private func setBenchState(isOnBench: Bool) {
        if isOnBench && !self.livePlayer.isOnBench {
            self.livePlayer.totalTimeOnField += currentETime
        }
        self.livePlayer.isOnBench = isOnBench
    }
    
    private func setupAppearance() {
        bodyView.layer.cornerRadius = 5.0
        timeLabel.layer.masksToBounds = true
        timeLabel.layer.cornerRadius = 5.0
        nameLabel.text = livePlayer.nickName
        updateFaceImage(index: 0)
        doActionOnTime = { [weak self] ( timeInterval ) in
            guard let strongSelf = self, let indx = strongSelf.triggerTimeIntervals.index(of: timeInterval) else { return }
            strongSelf.updateFaceImage(index: indx)
        }
    }
    
    private func updateFaceImage(index: Int) {
        let imageName = self.livePlayer.isOnBench ? self.benchPlayerFaces[index] : self.fieldPlayerFaces[index]
        self.faceImageView.image = UIImage(named:imageName)
    }
    
    //WatchProtocol
    func updateTime() {
        let currentTimeOnField = livePlayer.isOnBench ? 0 : currentETime
        let totalTime = self.timeIntervalToString(time: livePlayer.totalTimeOnField + currentTimeOnField)
        timeLabel.text = showTotalTimeOnField ? totalTime : timeText()
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
}
