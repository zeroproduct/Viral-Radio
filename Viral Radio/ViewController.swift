//
//  ViewController.swift
//  Viral Radio
//
//  Created by Daniel Rica & Albert Guillermo on 1/20/16.
//  Copyright © 2016 Viral. All rights reserved.
//

import UIKit
import WebKit
import ImageIO
import MediaPlayer
import Foundation
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var nowPlaying: UILabel!
    @IBOutlet var playButton: UIButton!
    
    var soundTagTimer: NSTimer = NSTimer()
    var soundTag = AVAudioPlayer()
    var playerItem:AVPlayerItem?
    var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
        fontAwesome()
        radioTag()
        initialPlayerState()
        backgroundGIF()
        scheduledUpdater()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    ///---------------SONG TITLE UPDATE FUNCTION---------------\\\
    func updateNowPlaying() {
        var wasSuccessful = false
        let attemptedUrl = NSURL(string: "http://192.241.229.82:8000/stats?sid=1")
        if let url = attemptedUrl {
            let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, ErrorType) -> Void in
                if let urlContent = data {
                    let webContent = NSString(data: urlContent, encoding: NSUTF8StringEncoding)
                    let websiteArray = webContent!.componentsSeparatedByString("<SONGTITLE>")
                    if websiteArray.count > 1 {
                        let songArray = websiteArray[1].componentsSeparatedByString("</SONGTITLE>")
                        if songArray.count > 1 {
                            wasSuccessful = true
                            let songSummary = songArray[0].stringByReplacingOccurrencesOfString("&amp;", withString: "&")
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.nowPlaying.text = songSummary.uppercaseString // Uppercase String Modifcation //
                            })
                        }
                    }
                }
                if wasSuccessful == false {
                    self.nowPlaying.text = "LIVESTREAM - OFFLINE"
                }
            }
            task.resume()
        } else {
            self.nowPlaying.text = "LIVESTREAM - OFFLINE"
        }
    }
    
    ///---------------MAIN PLAYER FUNCTIONS---------------\\\
    func initialPlayerState(){
        playButton.setTitle("Stop", forState:UIControlState.Normal)
        playButton.addTarget(self,action: "playButtonTapped:", forControlEvents: .TouchUpInside)
        initiatePlayer()
        
        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError
        {
            print(error)
        }
        
    }
    
    func playButtonTapped(sender: AnyObject) {
        
        
        if(playButton.titleLabel?.text == "Play") {
            initiatePlayer()
            playButton.setTitle("Stop", forState:UIControlState.Normal)
            playButton.setImage(UIImage(named:"stop_button_white.png"), forState: UIControlState.Normal)
            
        } else {
            stopPlayer()
            playButton.setTitle("Play", forState: UIControlState.Normal)
            playButton.setImage(UIImage(named:"play_button_white.png"), forState: UIControlState.Normal)
            
        }
        
    }
    
    func initiatePlayer() {
        
        var url = NSURL(string: "http://192.241.229.82:8000/;stream.mp3")
        playerItem = AVPlayerItem (URL: url!)
        player = AVPlayer (playerItem: playerItem!)
        player!.play()
        
    }
    
    func stopPlayer() {
        self.player!.pause()
        self.player = nil
        
    }
    
    ///---------------LOOP VIRAL RADIO TAG---------------\\\
    func radioTag() {
        
        let path = NSBundle.mainBundle().pathForResource("Tag.mp3", ofType:nil)!
        let tag = NSURL(fileURLWithPath: path)
        do {
            let sound = try AVAudioPlayer(contentsOfURL: tag)
            soundTag = sound //INITIATE SOUND
            soundTag.play() //AUTOLOAD SOUND ON APP FIRST INSTANCE
            soundTag.volume = 0.5 //VOLUME IN INTEGERS
        } catch {
            print("Error Processing Audio File")
        }
        
    }
    
    func soundTagAudio() {
        soundTag.play() // PLAY-LOOP
    }
    
    ///---------------GIF BACKGROUND---------------\\\
    func backgroundGIF(){
        
        let centerGIF = UIImage.gifWithName("static") // Locate File Path
        let imageView = UIImageView(image: centerGIF) // Create ImageView
        imageView.frame = UIScreen.mainScreen().bounds // Full Screen
        imageView.contentMode = .ScaleAspectFill // Aspect Fill
        view.addSubview(imageView) // Add/Create Image Subview
        imageView.center = view.center // Center Image
        self.view.sendSubviewToBack(imageView) // Send Image to Background
    }
    
    ///---------------UPDATER---------------\\\
    func scheduledUpdater(){
        
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "updateNowPlaying", userInfo: nil, repeats: true)
        NSTimer.scheduledTimerWithTimeInterval(90.0, target: self, selector: "soundTagAudio", userInfo: nil, repeats: true) //90 SECONDS
    }
    
    ///---------------FONT AWESOME---------------\\\
    func fontAwesome(){
        var faicon = [String:UniChar]()
        faicon["faglobe"] = 0xf0ac // GLO
        let y = 612 //Y-AXIS
        
        let globeLabel = UILabel(frame: CGRectMake(340, CGFloat(y), 120,40))
        globeLabel.font = UIFont(name: "FontAwesome", size: 20)
        globeLabel.text = String(format: "%C", faicon["faglobe"]!)
        globeLabel.textColor = UIColor.whiteColor()
        //MAKE ICON RESPONSIVE
        self.view.userInteractionEnabled = true
        self.view.addSubview(globeLabel)
        self.view.layer.zPosition = 1;
        
    }
    
    
}

