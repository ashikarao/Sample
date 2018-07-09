//
//  ViewController.swift
//  AudioApp
//
//  Created by Ashika Rao on 02/07/18.
//  Copyright © 2018 Umesh Tallam. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
class ViewController: UIViewController, AVAudioPlayerDelegate, MPPlayableContentDataSource, MPPlayableContentDelegate {
    func numberOfChildItems(at indexPath: IndexPath) -> Int {
        return 0
    }
    
    func contentItem(at indexPath: IndexPath) -> MPContentItem? {
        return MPContentItem()
    }
    
    
    var contentItems = [MPContentItem]()
    var audioPlayer : AVAudioPlayer!
    var hasBeenPaused = false
    var songsURLsArray = ["http://www.hubharp.com/web_sound/WalloonLilliShort.mp3", "http://www.hubharp.com/web_sound/BachGavotteShort.mp3"]
    var currentPlayingSongIndex = 0
    var playbackPositionAfterInteruptionEnded : Double?
    override func viewDidLoad() {
        super.viewDidLoad()
        audioPlayer = AVAudioPlayer()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        prepareSongAndSession()
         setupCommandCenter()
        
        let content = MPContentItem()
        content.title = "title"
        content.subtitle = "subtitle"
        
        contentItems.append(content)
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        UIApplication.shared.endReceivingRemoteControlEvents()
        self.resignFirstResponder()
    }
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        if event?.type == UIEventType.remoteControl {
//            if let subtype = event?.subtype {
//            switch(subtype) {
//
//            case UIEventSubtype.remoteControlTogglePlayPause :
//                print("play/pause")
//            case UIEventSubtype.remoteControlPlay :
//                print("play")
//            case UIEventSubtype.remoteControlPause :
//                print("pause")
//            default :
//                print("none")
//            }
//        }
//        }
//    }
    private func setUpControlCenterProperties(currentTime : Double?){
        
        var playingInfo:[String: Any] = [:]
        
//        if let title = song.title {
            playingInfo[MPMediaItemPropertyTitle] = "title"
        //}
        
//        if let songID = song.id {
//            playingInfo[MPMediaItemPropertyPersistentID] = songID
//        }
//        if let artist = song.artist, let artistName = artist.name {
            playingInfo[MPMediaItemPropertyArtist] = "artistName"
//        }
        
//        if let album = song.album, let albumTitle = album.title {
//            var artwork:MPMediaItemArtwork? = nil
//            if let album = song.album, let artworkData = album.artwork {
//                artwork = MPMediaItemArtwork(boundsSize: Constants.Library.Albums.thumbSize, requestHandler: { (size) -> UIImage in
//                    return UIImage(data: artworkData as Data)!
//                })
//            }
//            if artwork != nil {
        playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: CGSize(width: 25, height: 25), requestHandler: { (size) -> UIImage in
            return UIImage(named: "iu")!
        })
//            }
//            playingInfo[MPMediaItemPropertyAlbumTitle] = albumTitle
//        }
//
        var rate:Double = 0.0
        if let time = currentTime {
            playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
            playingInfo[MPMediaItemPropertyPlaybackDuration] = 14.0
            rate = 1.0
        }
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: rate)
        playingInfo[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
        playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        playingInfo[MPMediaItemPropertyPlaybackDuration] = 14.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
        
    }
    private func setupCommandCenter() {

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.audioPlayer.play()
            self?.setUpControlCenterProperties(currentTime: self?.audioPlayer.currentTime)
            return .success
        }
        commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if (self?.audioPlayer.isPlaying)! {
                self?.audioPlayer.pause()
                self?.setUpControlCenterProperties(currentTime: nil)
                self?.hasBeenPaused = true
            } else {
                self?.hasBeenPaused = false
                //self?.setUpControlCenterProperties()
            }
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if (self?.currentPlayingSongIndex)! < (self?.songsURLsArray.count)! - 1 {
                
                self?.currentPlayingSongIndex += 1
            } else {
                
                self?.currentPlayingSongIndex = 0
            }
            self?.audioPlayer.stop()
            self?.prepareSongAndSession()
            self?.audioPlayer.play()
            self?.setUpControlCenterProperties(currentTime: self?.audioPlayer.currentTime)
            return .success
        }
        commandCenter.previousTrackCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            if (self?.currentPlayingSongIndex)! > 0 {
                
                self?.currentPlayingSongIndex -= 1
            } else {
                
                self?.currentPlayingSongIndex = (self?.songsURLsArray.count)! - 1
            }
            self?.audioPlayer.stop()
            self?.prepareSongAndSession()
            self?.audioPlayer.play()
            self?.setUpControlCenterProperties(currentTime: self?.audioPlayer.currentTime)
            return .success
        }
    }
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBAction func playButton(_ sender: Any) {
        
        print("playing")
        audioPlayer.play()
        //audioPlayer.delegate = self
        setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
    }
    
    
    @IBAction func pauseButton(_ sender: Any) {
        
        print("paused")
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            setUpControlCenterProperties(currentTime: nil)
            hasBeenPaused = true
        } else {
            hasBeenPaused = false
            //setUpControlCenterProperties()
        }
    }
    
    @IBAction func prevButton(_ sender: Any) {
        
        if currentPlayingSongIndex > 0 {
            
            currentPlayingSongIndex -= 1
        } else {
            
            currentPlayingSongIndex = songsURLsArray.count - 1
        }
        audioPlayer.stop()
        prepareSongAndSession()
        audioPlayer.play()
        setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        
        if currentPlayingSongIndex < songsURLsArray.count - 1 {
            
            currentPlayingSongIndex += 1
        } else {
            
            currentPlayingSongIndex = 0
        }
        audioPlayer.stop()
        prepareSongAndSession()
        audioPlayer.play()
        setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
    }
    
    
    @IBAction func replayButton(_ sender: Any) {
        
        print("replayed")
        
        if audioPlayer.isPlaying || hasBeenPaused {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
            audioPlayer.play()
            setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
        } else {
            audioPlayer.play()
            setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
        }
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                              successfully flag: Bool) {
        
//        //setUpControlCenterProperties(currentTime: 0.0)
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyPlaybackDuration : 14.0, MPNowPlayingInfoPropertyPlaybackRate : 0.0, MPNowPlayingInfoPropertyElapsedPlaybackTime : 0.0]
    
        if currentPlayingSongIndex < songsURLsArray.count - 1 {
            
            currentPlayingSongIndex += 1
        } else {
            
            currentPlayingSongIndex = 0
        }
        prepareSongAndSession()
        audioPlayer.play()
        setUpControlCenterProperties(currentTime: audioPlayer.currentTime)
    }
    func addObserver() {
        
        //For Audio interuptions like phone call etc.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: .AVAudioSessionInterruption,
                                               object: AVAudioSession.sharedInstance())
    }


    @objc func handleInterruption(_ notification: Notification) {
        // Handle interruption
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSessionInterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
            playbackPositionAfterInteruptionEnded = audioPlayer.currentTime
        }
        else if type == .ended {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else {
                    return
            }
            let options = AVAudioSessionInterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
                if playbackPositionAfterInteruptionEnded != nil{
                   // audioPlayer.play(atTime: playbackPositionAfterInteruptionEnded!)
                }
            }
        }
    }
    
    func prepareSongAndSession(){
        
        do {
            let audioUrl = downloadAudio()
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
           
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            }
            catch let sessionError {
                print(sessionError)
            }
        }
        catch let songPlayerError {
            print(songPlayerError)
        }
    }
    
    func downloadAudio() -> URL{
        
        let audioUrl = NSURL.init(string: songsURLsArray[currentPlayingSongIndex])
            
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


}

