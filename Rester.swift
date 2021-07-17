//
//  Rester.swift
//  MemoReminder
//
//  Created by Seyyed Parsa Neshaei on 7/10/21.
//

import Foundation

class Rester {
    static let session = URLSession.shared
    static var server = ""
    static var token = "3386fb2b1433447606917b3b70c837d834d6f505"
    
    enum RestError: Error {
        case wrongURLFormat
        case cantParseResult
        case networkError
        case errorCode(code: Int)
    }
    
    enum RestMethod: String {
        case get = "GET", post = "POST", put = "PUT", delete = "DELETE", patch = "PATCH"
    }
    
    enum MimeType: String {
        case imageJPG = "image/jpg"
    }
    
    fileprivate static func upload(endPoint: String, token: String, body: String, data: Data, method: RestMethod = .post) async throws {
        guard let url = URL(string: server.isEmpty ? endPoint : "\(server)/\(endPoint)") else {
            throw RestError.wrongURLFormat
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = Data(body.utf8)
        if !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (dataReceived, response) = try await session.upload(for: request, from: data)
            print("Data received from upload: \(String(data: dataReceived, encoding: .utf8) ?? "nil data")")
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP upload request \(endPoint) - Return code \(httpResponse.statusCode)")
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    throw RestError.errorCode(code: httpResponse.statusCode)
                }
            }
        } catch {
            throw RestError.networkError
        }
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let body = NSMutableData()
//        let boundaryPrefix = " — \(boundary)\r\n"
//        for (key, value) in params {
//            body.appendString(boundaryPrefix)
//            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//            body.appendString("\(value)\r\n")
//        }
    }
    
    fileprivate static func rest(endPoint: String, token: String, body: String = "", method: RestMethod = .get) async throws -> String {
        guard let url = URL(string: server.isEmpty ? endPoint : "\(server)/\(endPoint)") else {
            throw RestError.wrongURLFormat
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = Data(body.utf8)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !token.isEmpty {
            request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        }
        do {
            let (data, response) = try await session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP request \(endPoint) - Return code \(httpResponse.statusCode)")
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    throw RestError.errorCode(code: httpResponse.statusCode)
                }
            }
            guard let result = String(data: data, encoding: .utf8) else {
                throw RestError.cantParseResult
            }
            return result
        } catch {
            throw RestError.networkError
        }
    }
    
    @discardableResult static func rest(endPoint: String, body: String = "", method: RestMethod = .get) async throws -> String {
        return try await rest(endPoint: endPoint, token: token, body: body, method: method)
    }
    
    static func upload(endPoint: String, body: String, data: Data, method: RestMethod = .post) async throws {
        return try await upload(endPoint: endPoint, token: token, body: body, data: data, method: method)
    }
}
