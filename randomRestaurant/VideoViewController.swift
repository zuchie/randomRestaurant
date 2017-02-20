//
//  VideoViewController.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 2/14/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import AVKit
import AVFoundation

class VideoViewController: AVPlayerViewController {
    
    //var playerVC: AVPlayerViewController!
    var name: String
    fileprivate var myUrl: URL!
    //fileprivate var player: AVPlayer!

    init(fileName: String, fileExt: String, directory: String) {
        name = fileName
        myUrl = Bundle.main.url(forResource: fileName.lowercased(), withExtension: fileExt, subdirectory: directory)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("==video view did load==")
        player = AVPlayer(url: myUrl)
        player?.volume = 0
        player?.actionAtItemEnd = .none

        videoGravity = AVLayerVideoGravityResizeAspectFill
        showsPlaybackControls = false

        /*
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { _ in
            DispatchQueue.main.async {
                self.player?.seek(to: kCMTimeZero)
                self.player?.play()
            }
        }
        */
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    func playerItemDidReachEnd(notification: Notification) {
        let item = notification.object as! AVPlayerItem
        item.seek(to: kCMTimeZero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        print("==video view will appear==")
        if player?.rate == 0 || player?.error != nil {
            if #available(iOS 10.0, *) {
                player?.playImmediately(atRate: 1.0)
            } else {
                // Fallback on earlier versions
                player?.rate = 1.0
                player?.play()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        print("==video view will disappear==")
        if player?.rate != 0 && player?.error == nil {
            player?.pause()
        }
    }
    
}