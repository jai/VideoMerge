//
//  ViewController.swift
//  VideoMerge
//
//  Created by Jai Govindani on 6/17/14.
//  Copyright (c) 2014 Jai Govindani. All rights reserved.
//

import UIKit
import AssetsLibrary
import QuartzCore
import AVFoundation
import CoreMedia

class Video: Equatable {
    var assetURL: NSURL?
    var selected = false
    
    init(url: NSURL) {
        self.assetURL = url
    }
}

@infix func == (left: Video, right: Video) -> Bool {
    if left.assetURL == nil || left.assetURL == nil {
        return false
    } else {
        if left.assetURL == left.assetURL {
            return true
        }
    }
    return false
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
                            
    @IBOutlet var collectionView : UICollectionView
    var videos = Video[]()
    let cellIdentifier = "Cell"
    var assetsLibrary = ALAssetsLibrary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCollectionView()
        loadVideos()
        self.title = NSLocalizedString("Videos",comment:"Video gallery title")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Merge",comment:"Merge button"), style: UIBarButtonItemStyle.Plain, target: self, action: "mergeButtonTapped")
    }
    
    func setupCollectionView() {
        var layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView.registerClass(VideoCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.layer.borderWidth = 5.0
        collectionView.alwaysBounceVertical = true
        collectionView.bounces = true
    }
    
    func mergeButtonTapped() {
        
        var selectedVideos = Video[]()
        for video in videos {
            if video.selected {
                selectedVideos.append(video)
            }
        }
        
        if selectedVideos.count > 1 {
            //Merge videos
            mergeVideos(selectedVideos)
            
        } else {
            var alertView = UIAlertController(title: NSLocalizedString("Not Enough Videos!", comment:"Alert Title"), message: NSLocalizedString("You must select at least 2 videos to merge", comment:"Alert Message"), preferredStyle: .Alert)
            var defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .Default, handler: nil)
            alertView.addAction(defaultAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
 
    func loadVideos() {
        //Clear out all existing videos (if any)
        videos = Video[]()
        
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos),
            usingBlock:{ group, stop in
                
                if group == nil {
                    self.collectionView.reloadData()
                } else {
                    group .enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                        result, index, stop in

                        if result {
                             if (result?.valueForProperty(ALAssetPropertyType) as String == ALAssetTypeVideo) {
                                self.videos.append(Video(url:result.defaultRepresentation().url()))
                            }
                        }
                    })
                }
                    }, failureBlock: { error in
                        //Failed
                    })
    }
    
    func collectionView(_ : UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }

    func collectionView(_ : UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell {
        let cellToReturn = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as VideoCollectionViewCell
        let currentVideo = videos[indexPath.row]
        if cellToReturn.imageView {
            assetsLibrary.assetForURL(currentVideo.assetURL, resultBlock:{ asset in
                
                if asset {
                    //Note to self: We already checked that imageView wasn't nil in the 'if' clause
                    //So forcing an unwrap here should be ok
                    //Otherwise it just looks weird to optional chain again
                    cellToReturn.imageView!.image = UIImage(CGImage: asset.thumbnail().takeUnretainedValue())
                    cellToReturn.imageView!.alpha = currentVideo.selected ? 0.5 : 1.0
                }
                
                }, failureBlock:{ error in
                
                })
        }
        
        return cellToReturn
    }
    
    func collectionView(_: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        let selectedVideo = videos[indexPath.row]
        if selectedVideo.selected {
                selectedVideo.selected = false
        } else {
            selectedVideo.selected = true
        }
        
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
    
    func mergeVideos(sourceVideos: Video[]) {
        
        var composition = AVMutableComposition()
        var track = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID:Int32(kCMPersistentTrackID_Invalid))
        
        for (index, currentVideoObject) in enumerate(sourceVideos) {
            
            var videoAsset = AVAsset.assetWithURL(currentVideoObject.assetURL) as AVAsset
            if index == 0 {
                track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack, atTime: kCMTimeZero, error: nil)
            } else {
                track.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAsset.duration), ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack, atTime: composition.duration, error: nil)
            }
            
        }
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var documentsDirectory = paths[0] as String
        var videoPathToSave = documentsDirectory.stringByAppendingPathComponent("mergeVideo-\(arc4random()%1000)-d.mov")
        var videoURLToSave = NSURL(fileURLWithPath: videoPathToSave)
        
        var exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter.outputURL = videoURLToSave
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.shouldOptimizeForNetworkUse = true
        
        //Let's use GCD async groups to wait for the videos to be merged
        var group = dispatch_group_create()
        dispatch_group_enter(group)
        
        exporter.exportAsynchronouslyWithCompletionHandler({
            dispatch_group_leave(group)
        })
        
        dispatch_group_notify(group, dispatch_get_main_queue(), {
            self.assetsLibrary.writeVideoAtPathToSavedPhotosAlbum(videoURLToSave, completionBlock: {
                savedVideoURL, error in
                if error == nil {
                    self.loadVideos()
                    self.showAlert(NSLocalizedString("Done!",comment:"Done!"), message: NSLocalizedString("Videos have been merged", comment:"Video merge success message"))
                } else {
                    var alertView = UIAlertController(title: NSLocalizedString("Error", comment:"Error"), message: NSLocalizedString("There was an error: \(error)", comment:"Error message"), preferredStyle: .Alert)
                    var defaultAction = UIAlertAction(title: NSLocalizedString("OK",comment:"OK"), style: .Default, handler: nil)
                    alertView.addAction(defaultAction)
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
                })
            })
    }
    
    func showAlert(title: String, message: String) {
        var alertView = UIAlertController(title:title, message:message, preferredStyle: .Alert)
        var defaultAction = UIAlertAction(title: NSLocalizedString("OK",comment:"OK"), style: .Default, handler: nil)
        alertView.addAction(defaultAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }

}

