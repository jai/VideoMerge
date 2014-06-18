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
    
    func mergeButtonTapped() {
        
        var selectedCount = 0
        for video in videos {
            if video.selected {
                ++selectedCount
            }
        }
        
        if selectedCount > 1 {
            //Merge videos
        } else {
            var alertView = UIAlertController(title: NSLocalizedString("Not Enough Videos!", comment:"Alert Title"), message: NSLocalizedString("You must select at least 2 videos to merge", comment:"Alert Message"), preferredStyle: .Alert)
            var defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment:"OK"), style: .Default, handler: nil)
            alertView.addAction(defaultAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buildVideo() {
        
    }
    
    func setupCollectionView() {
        var layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 100, height: 100)
        collectionView.registerClass(VideoCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.layer.borderWidth = 5.0
        
    }
    
    func loadVideos() {
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos),
            usingBlock:{ group, stop in
                
                if group == nil {
                    self.collectionView.reloadData()
                } else {
                    group .enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                        result, index, stop in

                        if result {
                             if (result?.valueForProperty(ALAssetPropertyType) as String == ALAssetTypeVideo) {
//                                var assetToAdd = ALAsset(
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
        
        collectionView.reloadData()

    }

}

