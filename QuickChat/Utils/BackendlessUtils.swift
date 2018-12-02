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
        
        guard let url = URL(string: url), let userToken = backendless?.userService.currentUser.getToken() else {
            return
        }
        
        let downloadQueue = DispatchQueue.init(label: "imageDownloadQueue")
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("\(userToken)", forHTTPHeaderField: "user-token")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            
            guard error == nil else {
                ProgressHUD.showError("There was an error retrieving avatar: \(error!.localizedDescription)")
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            
            guard let responseCode = (response as? HTTPURLResponse)?.statusCode,
            200 ... 299 ~= responseCode else {
                ProgressHUD.showError("There was an error retrieving avatar, status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                DispatchQueue.main.async {
                    result(nil)
                }
                return
            }
            if let data = data,
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    result(image)
                }
            }
            
            
        })
        downloadQueue.async {
            dataTask.resume()
        }
        
    }
    
    /// A helper function to retrieve the image from Backendless server
    /// - parameter uploadDirectory: the directory in which the image should be stored
    /// - parameter image: the image to upload
    /// - parameter result: callback containing a link or nil
    static func uploadAvatar(uploadDirectory: String = "/upload/",
                             image: UIImage,
                             result: @escaping(_ imageLink: String?, _ fault: Fault?) -> Void) {
        
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
