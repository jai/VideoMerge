//
//  VideoCollectionViewCell.swift
//  VideoMerge
//
//  Created by Jai Govindani on 6/17/14.
//  Copyright (c) 2014 Jai Govindani. All rights reserved.
//

import UIKit

class VideoCollectionViewCell : UICollectionViewCell {
    
    var imageView: UIImageView?
    
    init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView(frame:contentView.frame)
        imageView!.contentMode = .ScaleAspectFit
        contentView.addSubview(imageView)
        var image = UIImage(named:"hello")
        if imageView {
            imageView!.image = image
        }
    }
}
