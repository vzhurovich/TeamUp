//
//  FirstViewController.swift
//  TeamUp
//
//  Created by Vladimir on 4/19/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import UIKit

class LiveGameViewController: UIViewController, WatchProtocol, ScoreProtocol {

    @IBOutlet weak var fieldUIImageView: UIImageView!
    @IBOutlet weak var ballImageView: BallView!
    
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var scoreButton: UIButton!
    
    @IBOutlet weak var totalButton: UIButton!
    @IBOutlet weak var benchView: UIView!
    var panGeaasureRecognizers: [UIPanGestureRecognizer: LivePlayerProtocol] = [:]
    
    var showTotalOnFieldTime: Bool = false

    @IBAction func swipeWas(_ sender: Any) {
        print("***** Swipe ****")
    }
    @IBAction func totalButtonPressed(_ sender: Any) {
        showTotalOnFieldTime = !showTotalOnFieldTime
        let titleText = showTotalOnFieldTime ? "Total On Field" : "Current"
        totalButton.setTitle(titleText, for: .normal)
        panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.forEach{ $0.showTotalTimeOnField = showTotalOnFieldTime
            $0.updateTime()
        }
    }
    
    // Constats
    private var xBenchPosition = -60
    private let yBenchPosition = 690
    private let fieldCenter = CGPoint(x: 511, y: 400)
    private let theirGoalCenter = CGPoint(x: 975.5, y: 400)
    private let ourGoalCenter = CGPoint(x: 47, y: 400)
    private let ourGoalZone = CGRect(x: 66, y: 240, width: 134, height: 320)
    private let benchZone = CGRect(x: 30, y: 698, width: 481, height: 66)
    
    // WatchProtocol
    var startTime = TimeInterval()
    var timeFromStart: TimeInterval?
    var periodTimeInterval: TimeInterval? = 22*60 + 30
    var triggerTimeIntervals: [UInt16] = [0]
    var doActionOnTime: ((UInt16)->())?
    
    // ScoreProtocol
    var ourGoals: UInt8 = 0
    var theirGoals: UInt8 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(LiveGameViewController.draggedView(_:)))
        
        // Ball view
        setupBallView(panGesture: panGesture)
        
        // Players Views
        addPlayersView(livePlayers: getTestLivePlayers())
        
        // Bench View
        benchView.frame = benchZone
        benchView.layer.cornerRadius = 5.0
        
        timeButton.setTitle(timeIntervalToString(time: periodTimeInterval!), for: .normal)
        updateScore()
        
        // Period finished
        doActionOnTime = { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.pauseWatchTimer()
        }
    }

    // Mark: Period & Time buttons
    var watchTimer: Timer?
    @IBAction func periodButtonPressed(_ sender: Any) {
        if let periodLabel = periodButton.titleLabel, periodLabel.text == "1", let timeButtonLabel = timeButton.titleLabel, timeButtonLabel.text == "00:00", watchTimer == nil {
            periodButton.setTitle("2", for: .normal)
            startTime = NSDate.timeIntervalSinceReferenceDate
            timeFromStart = 0
            timeButton.setTitle(timeIntervalToString(time: periodTimeInterval!), for: .normal)
        }
    }
    
    @IBAction func timeButtonPressed(_ sender: Any) {
        if (watchTimer == nil) {
            if (timeFromStart == nil) {
                startWatchTimer()
            } else {
                resumeWatchTimer()
            }
        } else {
            pauseWatchTimer()
        }
    }
    
    //Mark: Drag
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        guard let draggedView = sender.view else { return }
        guard let draggableView = draggedView as? DraggableViewProtocol else { return }
     
        switch sender.state {
        case .possible,.began:
            self.view.bringSubview(toFront: draggedView)
        case .ended:
            if let underLivePlayerView = getPlayerUnderView(draggedView) {
                draggableView.dragEndedOnPlayer(player: underLivePlayerView, onCompletion: { [weak self] status in
                    guard let strongSelf = self else { return }
                    strongSelf.dragEndedCompletion(draggableView: draggableView, status: status, ourGoal: true)
                })
            } else {
                draggableView.dragEndedOnSpecialZone(onCompletion:{ [weak self] status in
                    guard let strongSelf = self else { return }
                    strongSelf.dragEndedCompletion(draggableView: draggableView, status: status, ourGoal: false)
                })
            }
            
        default:
            let translation = sender.translation(in: self.view)
            let newCenterPoint = CGPoint(x: draggedView.center.x + translation.x, y: draggedView.center.y + translation.y)
            if draggableView.isAllowedMovementTo(newCenterPoint: newCenterPoint) {
                draggedView.center = newCenterPoint
//                print ("*** newCenterPoint = \(newCenterPoint)")
                sender.setTranslation(CGPoint.zero, in: self.view)
            }
        }
    }

    // MARK: Helpers
    private func dragEndedCompletion(draggableView: DraggableViewProtocol, status: CompletionStatus, ourGoal: Bool) {
        switch status {
        case .failed:
            draggableView.cancelMovement()
            return
        case .succeededBall: // Scored
            self.goal(our: ourGoal)
            self.updateScore()
        case .succeededLivePlayer: // Bench change
            self.sortBench()
        default:
            break
        }
        draggableView.movementFinishedSuccessfully()
    }
    
    private func getPlayerUnderView(_ draggableView: UIView) -> LivePlayerView? {
        return panGeaasureRecognizers.keys.filter{ $0.view != draggableView}.flatMap{ $0.view as? LivePlayerView}.first(where: {$0.frame.contains(draggableView.center)})
    }
    
    private func setupBallView(panGesture: UIPanGestureRecognizer) {
        
        ballImageView.isUserInteractionEnabled = true
        ballImageView.addGestureRecognizer(panGesture)
        let size = CGSize(width: self.view.frame.width - 31 - 31, height: self.view.frame.height - 100 - 74)
        ballImageView.allowedAreaFrame = CGRect(origin: fieldUIImageView.frame.origin, size: size)
        ballImageView.center = fieldCenter
        ballImageView.updateLastCenterPoint()
        ballImageView.fieldCenter = fieldCenter
        ballImageView.ourGoalCenter = ourGoalCenter
        ballImageView.theirGoalCenter = theirGoalCenter
    }
//    private func getPlayerAtPosition(centerPoint: CGPoint) -> LivePlayerView? {
//        return panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.first(where: {$0.frame.contains(centerPoint)})
//    }
    
    private func sortBench() {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
                guard let strongSelf = self else { return }
            let sortedLivePlayersOnBench = strongSelf.panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView }.filter{ $0.livePlayer.isOnBench}.sorted(by: { $0.currentETime < $1.currentETime })
            var xPos = 60
            for  livePlayerView in sortedLivePlayersOnBench {
                livePlayerView.center = CGPoint(x: xPos, y: 728)
                livePlayerView.updateLastCenterPoint()
                xPos += 80
            }
        })

    }
    
    // MARK: Score
    private func updateScore() {
        let scoreString = String(ourGoals) + " : " + String(theirGoals)
        scoreButton.setTitle(scoreString, for: .normal)
    }
    
    // MARK: Timer
    func startWatchTimer() {
        panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.forEach{ $0.resetTimer()}
        watchTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    func pauseWatchTimer() {
        pauseTimer()
        panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.forEach{ $0.pauseTimer() }
        stopTimer()
    }
    
    func resumeWatchTimer() {
        resumeTimer()
        panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.forEach{ $0.resumeTimer() }
        
        watchTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        watchTimer?.invalidate()
        watchTimer = nil
    }
    
    @objc func updateTime() {
        panGeaasureRecognizers.keys.flatMap{ $0.view as? LivePlayerView}.forEach{ $0.updateElapsedTime()
            $0.updateTime()}
        timeButton.setTitle(timeText(),for: .normal)
    }
    
    // MARK: Test Data
    private func addPlayersView(livePlayers: [LivePlayerProtocol]) {
        for player in livePlayers {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(LiveGameViewController.draggedView(_:)))
            let playerView = LivePlayerView(livePlayer: player)
            
            playerView.frame = frameFor(livePlayer: player)
            //CGRect(origin: CGPoint(x: xPosition, y: 690), size: CGSize(width: 76, height: 76))
            playerView.isUserInteractionEnabled = true
            
            let size = CGSize(width: self.view.frame.width - 31 - 31, height: self.view.frame.height - 100 - 35)
            playerView.allowedAreaFrame = CGRect(origin: fieldUIImageView.frame.origin, size: size)
            let fieldSize = CGSize(width: self.view.frame.width - 31 - 31, height: self.view.frame.height - 100 - 74)
            playerView.fieldZone = CGRect(origin: fieldUIImageView.frame.origin, size: fieldSize)
            playerView.updateLastCenterPoint()
            playerView.addGestureRecognizer(panGesture)
            self.view.addSubview(playerView)
            panGeaasureRecognizers[panGesture] = player
        }
    }
    
    private func frameFor(livePlayer: LivePlayerProtocol) -> CGRect {
        let origin = livePlayer.isOnBench ? nextBenchOrigin() : livePlayer.postition.origin()
        return CGRect(origin: origin, size: CGSize(width: 76, height: 76))
    }
    
    private func nextBenchOrigin() -> CGPoint {
        xBenchPosition  += 80
        return CGPoint(x: xBenchPosition, y: yBenchPosition)
    }
    private func getTestLivePlayers() -> [LivePlayerProtocol] {
        var livePlayers: [LivePlayer] = []
        livePlayers.append(LivePlayer(firstName: "Dima", secondName: "Dima", nickName: "Dimas", isFullTimer: true, postition: .Keeper, isOnBench: false, totalTimeOnField: 0))
        // Right Deff
        livePlayers.append(LivePlayer(firstName: "Vitaliy", secondName: "Fedonkin", nickName: "Vitaliy", isFullTimer: true, postition: .RightDef, isOnBench: false, totalTimeOnField: 0))
        livePlayers.append(LivePlayer(firstName: "Dima", secondName: "Kabish", nickName: "Dima", isFullTimer: true, postition: .RightDef, isOnBench: true, totalTimeOnField: 0))
        
        // Left Deff
        livePlayers.append(LivePlayer(firstName: "Yura", secondName: "Burkanov", nickName: "Yura", isFullTimer: true, postition: .LeftDef, isOnBench: false, totalTimeOnField: 0))
        livePlayers.append(LivePlayer(firstName: "Evgeny", secondName: "Melikhov", nickName: "ZhenyaM", isFullTimer: true, postition: .LeftDef, isOnBench: true, totalTimeOnField: 0))
        
        // Center
        livePlayers.append(LivePlayer(firstName: "Serega", secondName: "Petrov", nickName: "SeregaP", isFullTimer: true, postition: .CenterForward, isOnBench: false, totalTimeOnField: 0))
        livePlayers.append(LivePlayer(firstName: "Oleg", secondName: "Pauchkov", nickName: "Oleg", isFullTimer: true, postition: .CenterForward, isOnBench: true, totalTimeOnField: 0))
        
        // Right Forward
        livePlayers.append(LivePlayer(firstName: "Vladimir", secondName: "Zhurovich", nickName: "Volodya", isFullTimer: true, postition: .RightForward, isOnBench: false, totalTimeOnField: 0))
        livePlayers.append(LivePlayer(firstName: "Serega", secondName: "Balabanov", nickName: "SeregaB", isFullTimer: true, postition: .RightForward, isOnBench: true, totalTimeOnField: 0))
        
        // Left Forward
        livePlayers.append(LivePlayer(firstName: "Leonid", secondName: "Konyaev", nickName: "Lenya", isFullTimer: true, postition: .LeftForward, isOnBench: false, totalTimeOnField: 0))
        livePlayers.append(LivePlayer(firstName: "Genghis", secondName: "Karimov", nickName: "Genghis", isFullTimer: true, postition: .LeftForward, isOnBench: true, totalTimeOnField: 0))
        
        //        livePlayers.append(LivePlayer(firstName: "Yevgenie", secondName: "Goldenberg", nickName: "Zhenya", isFullTimer: true, postition: .CenterForward, isOnBench: false))
        
        return livePlayers
    }
}

