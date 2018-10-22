//
//  ViewController.swift
//  1_StopWatch
//
//  Created by Nguyen Van  Quoc on 10/17/18.
//  Copyright © 2018 Nguyen Van  Quoc. All rights reserved.
//

import UIKit
enum PlayState: String{
    case play = "Play"
    case pause = "Pause"
    var description : String {
        get {
            return self.rawValue
        }
    }
}
class ViewController: UIViewController {

    var counter = 0.0
    var timer = Timer()
    var isPlaying = false

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        timeLabel.text = String(counter)
        self.playButton.titleLabel?.text = PlayState.play.description
    }

    @IBAction func playButtonClick(_ sender: Any) {
        isPlaying = !isPlaying
        let state = isPlaying ? PlayState.pause : PlayState.play
        
        if isPlaying {
            timer.invalidate()
        }else{
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.UpdateTimer), userInfo: nil, repeats: true)
        }
        DispatchQueue.main.async {
//            self.playButton.titleLabel?.text = state.description
            self.playButton.titleLabel?.text = self.isPlaying ? "Pause" : "Play"
            print(self.playButton.titleLabel?.text)
        }
    }
    
    @IBAction func resetValue(_ sender: Any) {
        timer.invalidate()
        isPlaying = false
        counter = 0
        timeLabel.text = String(counter)
        let state = PlayState.play
        playButton.titleLabel?.text = state.description
    }
    @objc func UpdateTimer() {
        counter = counter + 0.1
        timeLabel.text = String(format: "%.1f", counter)
        
    }
}

