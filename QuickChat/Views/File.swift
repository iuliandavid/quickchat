//
//  File.swift
//  QuickChat
//
//  Created by iulian david on 12/22/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

class VideoMessage: JSQMediaItem {
    
    var image: UIImage?
    var videoImageView: UIImageView?
    var status: Int?
    var fileURL: URL?
    
    init(withFileURL: URL, maskOutgoing: Bool) {
        super.init(maskAsOutgoing: maskOutgoing)
        
        fileURL = withFileURL
        videoImageView = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mediaView() -> UIView! {
        if let status = status{
            if status == 1 {
                print("downloading")
                return nil
            }
            
            if status == 2 && videoImageView == nil {
                print("success")
                
                let size = mediaViewDisplaySize()
                let outgoing = self.appliesMediaViewMaskAsOutgoing
                
                let icon = UIImage.jsq_defaultPlay()?.jsq_imageMasked(with: .white)
                
                let iconView = UIImageView(image: icon)
                iconView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                iconView.contentMode = .center
                
                let imageView = UIImageView(image: self.image!)
                imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.addSubview(iconView)
                JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMask(toMediaView: imageView, isOutgoing: outgoing)
                self.videoImageView = imageView
            }
        }
        return self.videoImageView
    }
}
