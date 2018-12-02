//
//  BackendlessUtils.swift
//  QuickChat
//
//  Created by iulian david on 12/2/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

//utilities for BackendLess service
//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace

struct BackendlessUtils {
    // MARK: - Avatar
    /// A helper function to retrieve the image from Backendless server
    /// - parameter url: the url on the server
    /// - parameter result: callback containing a image or nil
    static func getAvatarFromURL(url: String, result: @escaping (_ image: UIImage?) -> Void) {
        
        guard let url = URL(string: url) else {
            return
        }
        
        let downloadQueue = DispatchQueue.init(label: "imageDownloadQueue")
        
        downloadQueue.async {
            guard let data = try? Data(contentsOf: url) else {
                return
            }
            
            guard let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                result(image)
            }
        }
    }
    
    /// A helper function to retrieve the image from Backendless server
    /// - parameter user: the url on the server
    /// - parameter result: callback containing a image or nil
    static func uploadAvatar(uploadDirectory: String = "/upload/", image: UIImage, result: @escaping(_ imageLink: String?, _ fault: Fault?) -> Void) {
        
        let data = image.jpegData(compressionQuality: 1)
        let filePathName = "\(uploadDirectory)\(Date().formatted()).jpg"
        backendless?.file.uploadFile(filePathName, content: data, overwriteIfExist: true, response: { uploadFile in
            result(uploadFile?.fileURL, nil)
        }, error: { fault in
            result(nil, fault)
        })
    }
    
}

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

extension Date {
    var millisecondsSince1970: Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
    
    func formatted() -> String {
        return dateFormatter().string(from: self)
    }
    
    
}
