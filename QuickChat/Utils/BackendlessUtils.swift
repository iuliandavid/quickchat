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
    
    static func uploadVideo(video: Data, thumbnail: Data, result: @escaping (_ videoLink: String?, _ thumbnailLink: String?) -> ()) {
        let dateString = Date().formatted()
        let videoFileName = "/upload/\(dateString).mov"
        let thumbnailFileName = "/upload/\(dateString).jpg"
        
        ProgressHUD.show("Sending video...")
        
        backendless?.file.uploadFile(thumbnailFileName, content: thumbnail, response: { thumbnailFile in
          backendless?
            .file
            .uploadFile(videoFileName, content: video, response: { videoFile in
                ProgressHUD.dismiss()
                result(videoFile?.fileURL, thumbnailFile?.fileURL)
            }, error: { fault in
                if let fault = fault {
                    ProgressHUD.showError("Error uploading video \(fault.detail ?? "")")
                    result(nil, nil)
                }
            })
            
        }, error: { fault in
            if let fault = fault {
               ProgressHUD.showError("Error uploading thumbnail \(fault.detail ?? "")")
                result(nil, nil)
            }
        })
        
        
    }
    
    static func downloadVideo(videoUrlString: String,
                       result: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        guard let videoUrl = URL(string: videoUrlString),
            let userToken = backendless?.userService.currentUser.getToken(),
        let videoFileName = videoUrl.pathComponents.last  else {
            ProgressHUD.showError("Invalid video URL!")
            result(false, "")
            return
        }
        
        //check if the file was already downloaoded
        if fileExistsAtPath(path: videoFileName) {
            result(true, videoFileName)
        } else {
            //download it
            let downloadQueue = DispatchQueue.init(label: "videoDownloadQueue")
            var urlRequest = URLRequest(url: videoUrl)
            urlRequest.setValue("\(userToken)", forHTTPHeaderField: "user-token")
            let session = URLSession.shared
            let dataTask = session.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                
                guard error == nil else {
                    ProgressHUD.showError("There was an error retrieving video file: \(error!.localizedDescription)")
                    DispatchQueue.main.async {
                        result(false, "")
                    }
                    return
                }
                
                guard let responseCode = (response as? HTTPURLResponse)?.statusCode,
                    200 ... 299 ~= responseCode else {
                        ProgressHUD.showError("There was an error retrieving video file, status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                        DispatchQueue.main.async {
                            result(false, "")
                        }
                        return
                }
                if let data = data {
                    var docURL = getDocumentsURL()
                    docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                    do {
                        try data.write(to: docURL, options: .atomicWrite)
                        DispatchQueue.main.async {
                            result(true, videoFileName)
                        }
                    } catch {
                        ProgressHUD.showError("There was an error saving video file to disk: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            result(false, "")
                        }
                        return
                    }
                    
                } else {
                    ProgressHUD.showError("No video in database")
                    DispatchQueue.main.async {
                        result(false, "")
                    }
                }
                
                
            })
            downloadQueue.async {
                dataTask.resume()
            }
        }
    }
    
}

private let dateFormat = "yyyyMMddHHmmss"

func dateFormatter() -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    return dateFormatter
}

func getThumbnailImage(for videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    let imageAssetGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
        let thumbnailCGImage =
            try imageAssetGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
        return UIImage(cgImage: thumbnailCGImage)
    } catch let err {
        print(err.localizedDescription)
        return nil
    }
    
}

func getDocumentsURL() -> URL {
    guard let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
        fatalError("No documents directory!")
    }
    return documentURL
}

func fileInDocumentsDirectory(filename: String) -> String {
    let fileURL = getDocumentsURL().appendingPathComponent(filename)
    return fileURL.path
}

func fileExistsAtPath(path: String) -> Bool {
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(filename: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    }
    
    return doesExist
    
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
