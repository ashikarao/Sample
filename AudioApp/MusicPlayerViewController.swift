//
//  MusicPlayerViewController.swift
//  AudioApp
//
//  Created by Ashika Rao on 06/07/18.
//  Copyright © 2018 Umesh Tallam. All rights reserved.
//

import UIKit
import MediaPlayer

class MusicPlayerViewController: UIViewController {

    let mp = MPMusicPlayerController.systemMusicPlayer
    var timer : Timer = Timer()
    var songsURLsArray = ["http://www.hubharp.com/web_sound/WalloonLilliShort.mp3", "http://www.hubharp.com/web_sound/BachGavotteShort.mp3"]
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
        mp.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        
    let track1 = MPMediaItem()  
        track1.setValue(downloadAudioTrack(index: 0), forKey: MPMediaItemPropertyAssetURL)
        track1.setValue("title", forKey: MPMediaItemPropertyTitle)
        track1.setValue("artist", forKey: MPMediaItemPropertyArtist)
    let track2 = MPMediaItem()
        track2.setValue(downloadAudioTrack(index: 1), forKey: MPMediaItemPropertyAssetURL)
        track2.setValue("title", forKey: MPMediaItemPropertyTitle)
        track2.setValue("artist", forKey: MPMediaItemPropertyArtist)
    let mediaCollection = MPMediaItemCollection(items: [track1,track2])
        mp.setQueue(with: mediaCollection)
        
        mp.prepareToPlay()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func play(_ sender: Any) {
        mp.play()
        
    }
    
    @IBAction func pause(_ sender: Any) {
       mp.pause()
    }
    
    @IBAction func prev(_ sender: Any) {
        mp.skipToPreviousItem()
    }
    
    @IBAction func next(_ sender: Any) {
        mp.skipToNextItem()
    }
    
    @IBAction func begin(_ sender: Any) {
        mp.skipToBeginning()
    }
    @objc func updateNowPlayingInfo() {
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MusicPlayerViewController.timerFired(_:)), userInfo: nil, repeats: true)
        self.timer.tolerance = 0.1
    }
    @objc func timerFired(_:AnyObject) {
        
        if let currentItem = mp.nowPlayingItem {
            
            let trackName = currentItem.title!
            
            let trackArtist = currentItem.artist!
            
            let albumImage = currentItem.artwork?.image(at: CGSize(width: 50, height: 50))
            
            let trackDuration = currentItem.playbackDuration
            
            let trackElapsed = mp.currentPlaybackTime
        }
    }
    func downloadAudioTrack(index : Int) -> URL{
        
        let audioUrl = NSURL.init(string: songsURLsArray[index])
        
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let destinationURL = documentsDir.appendingPathComponent((audioUrl?.lastPathComponent!)!)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            print("file exists")
        } else {
            URLSession.shared.downloadTask(with: audioUrl! as URL) { (url, response, error) in
                
                guard let url = url, error == nil else {
                    return
                }
                do {
                    try FileManager.default.moveItem(at: url, to: destinationURL)
                }
                catch let error as NSError {
                    print(error.localizedDescription)
                }
                }.resume()
            
        }
        return destinationURL
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
