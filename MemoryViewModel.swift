//
//  MemoryViewModel.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/16/21.
//

import SwiftUI
import Alamofire

class MemoryViewModel: ObservableObject {
    var isSample = false
    
    @Published var uploadAmount = 0.0
    
    func deleteMemory(memory: Memory, globalData: GlobalData) async throws {
        guard !isSample else { return }
        try await Rester.rest(endPoint: "post/\(memory.id)/?token=\(globalData.token)", body: "", method: .delete)
    }
    
    func likeMemory(memory: Memory, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "post": memory.id
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post-like/?token=\(globalData.token)", body: bodyString, method: .post)
    }
    
    // https://stackoverflow.com/questions/54268856/upload-image-to-my-server-via-php-using-swift
    func upload(memory: Memory, image: UIImage, globalData: GlobalData, completion: @escaping (String?) -> Void) {
        guard !isSample else {
            completion(nil)
            return
        }
        let imgData = image.jpegData(compressionQuality: 1)!
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file", fileName: "\(UUID().uuidString).jpg", mimeType: "image/jpg")
//            multipartFormData.append(Data("token \(Rester.token)".utf8), withName: "Authorization")
        }, to: "\(Rester.server)/post-file/?token=\(globalData.token)&post=\(memory.id)", headers: ["Authorization": "token \(Rester.token)"])
            .uploadProgress { [weak self] progress in
                self?.uploadAmount = progress.fractionCompleted * 100
            }
            .responseString { response in
                print("Upload response status code: \(String(describing: response.response?.statusCode)) - Result: \(String(describing: response.value))")
                completion(response.value)
            }
        
        //        guard !isSample else { return "" }
        //        let resultString = try await Rester.upload(endPoint: "post-file/?token=\(globalData.token)&post=\(memory.id)", body: "", data: image.pngData() ?? Data(), method: .post)
        //        return JSON(parseJSON: resultString)["file"].stringValue
    }
    
    func upload(memory: Memory, fileURL: URL, globalData: GlobalData, completion: @escaping (String?) -> Void) {
        guard !isSample else {
            completion(nil)
            return
        }
        guard let imgData = try? Data(contentsOf: fileURL) else {
            completion(nil)
            return
        }
        AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "file", fileName: "\(UUID().uuidString).pdf", mimeType: "application/pdf")
//            multipartFormData.append(Data("token \(Rester.token)".utf8), withName: "Authorization")
        }, to: "\(Rester.server)/post-file/?token=\(globalData.token)&post=\(memory.id)", headers: ["Authorization": "token \(Rester.token)"])
            .uploadProgress { [weak self] progress in
                self?.uploadAmount = progress.fractionCompleted * 100
            }
            .responseString { response in
                print("Upload response status code: \(String(describing: response.response?.statusCode)) - Result: \(String(describing: response.value))")
                completion(response.value)
            }
        
        //        guard !isSample else { return "" }
        //        let resultString = try await Rester.upload(endPoint: "post-file/?token=\(globalData.token)&post=\(memory.id)", body: "", data: image.pngData() ?? Data(), method: .post)
        //        return JSON(parseJSON: resultString)["file"].stringValue
    }
    
    func editMemoryDetails(id: Int, contents: String, latitude: Double, longitude: Double, privacyStatus: Memory.PrivacyStatus, globalData: GlobalData) async throws {
        guard !isSample else { return }
        let body: JSON = [
            "text": contents,
            "lat": latitude,
            "lon": longitude,
            "mode": privacyStatus.rawValue
        ]
        guard let bodyString = body.rawString() else { return }
        try await Rester.rest(endPoint: "post/\(id)/?token=\(globalData.token)", body: bodyString, method: .patch)
    }
    
    static var sample: MemoryViewModel {
        let viewModel = MemoryViewModel()
        return viewModel
    }
}
