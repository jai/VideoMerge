//
//  ViewController.swift
//  VideoMerge
//
//  Created by Jai Govindani on 6/17/14.
//  Copyright (c) 2014 Jai Govindani. All rights reserved.
//

import UIKit
import AssetsLibrary

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
                            
    @IBOutlet var collectionView : UICollectionView
    var videos = ALAsset[]()
    let cellIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    }
    
    func loadVideos() {
        var assetsLibrary = ALAssetsLibrary()
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos),
            usingBlock:{ group, stop in
                
                if group == nil {
                    self.collectionView.reloadData()
                } else {
                    group .enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock: {
                        result, index, stop in
                        
                        if result.valueForProperty(ALAssetPropertyType) as String == ALAssetTypeVideo {
                            self.videos.append(result)
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
        var cellToReturn = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as VideoCollectionViewCell
        var currentVideo = videos[indexPath.row]
        if let cellImageView = cellToReturn.imageView {
            var imageData: CGImageRef = CGImageRef(im
            var imageToSet = UIImage(CGImage: imageData)
            cellImageView.image = imageToSet
        }
    }

}

