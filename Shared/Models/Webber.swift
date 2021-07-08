//
//  Webber.swift
//  Webber
//
//  Created by Seyyed Parsa Neshaei on 3/12/17.
//  Copyright © 2017 Seyyed Parsa Neshaei. All rights reserved.
//

// Webber 2.0 - Cache with Parameters

import Foundation
import SystemConfiguration
import UIKit
//import Alamofire

public class Webber {
    
    /**
     Set this property to be used as server address once.
     */
    public static var server = ""
    
    
    /**
     Checks the connection to the Internet.
     
     - Returns: `true` if a valid connection to the Internet is found, otherwise `false`.
     */
    public static func isInternetAvailable() -> Bool{
//        return NetworkReachabilityManager()!.isReachable
//                        let reachability: Reachability = Reachability.reachabilityForInternetConnection()
//                        let networkStatus: Int = reachability.currentReachabilityStatus().rawValue
//                        return networkStatus != 0
        
                        var zeroAddress = sockaddr_in()
                        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
                        zeroAddress.sin_family = sa_family_t(AF_INET)
        
                        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                                SCNetworkReachabilityCreateWithAddress(nil, $0)
                            }
                        }) else {
                            return false
                        }
        
                        var flags: SCNetworkReachabilityFlags = []
                        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                            return false
                        }
        
                        let isReachable = flags.contains(.reachable)
                        let needsConnection = flags.contains(.connectionRequired)
        
                        return (isReachable && !needsConnection)
    }
    
    /**
     Connects to an API using GET.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     - cache: Specifies where should content be loaded or saved in cache when offline.
     
     - Returns: A string containing the server result which may be `nil` if you are offline and `cache` is `false` or if the cache is cleared.
     */
    public static func getFromAPI(url: String, ignoreServer: Bool = false, cache: Bool = true) -> String?{
        let defaults=UserDefaults.standard
        var text:String?
        if isInternetAvailable(){
            do{
                let url=URL(string: ignoreServer ? "\(url)" : "\(server)/\(url)")
                text=try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue) as String
            }catch{
                print("Webber Error: \(error.localizedDescription)")
                return nil
            }
            if cache{
                defaults.set(text, forKey: "__WEBBER_OFFLINE_getFromAPI_\(server)/\(url)")
            }
        }else{
            if cache{
                text=defaults.string(forKey: "__WEBBER_OFFLINE_getFromAPI_\(server)/\(url)")
            }
        }
        return text
    }
    
    /**
     Connects to an API using GET asynchronous.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     - cache: Specifies where should content be loaded or saved in cache when offline.
     - offline: If `true`, `completion` is called twice, first after loading cache and then after downloading data, else it is called only once after downloading data.
     - completion: Things to do when data is received, for example updating a `UITableView`. The closure receives an optional parameter containing the result.
     - atLast: Things to do at last, for example stopping a `UIActivityIndicatorView`.
     
     */
    public static func asyncGetFromAPI(url: String, ignoreServer: Bool = false, cache: Bool = true, offline: Bool = true, completion: @escaping (String?) -> Void, atLast: (() -> Void)? = nil){
        var text:String?
        if offline{
            text=cacheGetFromAPI(url: url)
            completion(text)
        }
        let queue=DispatchQueue(label: "WebberAsyncGetFromAPI")
        queue.async {
            text=getFromAPI(url: url, cache: cache)
            DispatchQueue.main.async {
                if isInternetAvailable(){
                    completion(text)
                }
                if let atLastUnwrapped = atLast{
                    atLastUnwrapped()
                }
            }
        }
    }
    
    /**
     Returns the saved cache for a URL.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     
     - Returns: A string containing the cached server result which may be `nil` if no cache is saved or if the cache is cleared.
     
     */
    public static func cacheGetFromAPI(url: String) -> String?{
        let defaults=UserDefaults.standard
        return defaults.string(forKey: "__WEBBER_OFFLINE_getFromAPI_\(server)/\(url)")
    }
    
    /**
     Connects to an API using GET and parses the result in JSON.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     - cache: Specifies where should content be loaded or saved in cache when offline.
     
     - Returns: An array containing the server result parsed to JSON which may be `nil` if you are offline and `cache` is `false` or if the cache is cleared.
     */
    public static func getJSONArrayFromAPI(url: String, cache: Bool = true) -> [Any]?{
        let defaults=UserDefaults.standard
        var text:String?
        var arr:[Any]?
        if isInternetAvailable(){
            do{
                let url=URL(string: "\(server)/\(url)")
                text=try NSString(contentsOf: url!, encoding: String.Encoding.utf8.rawValue) as String
            }catch{
                print("Webber Error: \(error.localizedDescription)")
                return nil
            }
            if cache{
                defaults.set(text, forKey: "__WEBBER_OFFLINE_getJSONArrayFromAPI_\(server)/\(url)")
            }
        }else{
            if cache{
                text=defaults.string(forKey: "__WEBBER_OFFLINE_getJSONArrayFromAPI_\(server)/\(url)")
            }
        }
        do{
            if let t=text{
                let json = try JSONSerialization.jsonObject(with: t.data(using: String.Encoding.utf8)!, options: [])
                if let array=json as? [Any]{
                    arr=array
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            print("Webber Error: \(error.localizedDescription)")
            return nil
        }
        return arr
    }
    
    /**
     Returns the saved cache parsed to JSON for a URL.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     
     - Returns: An array containing the cached server parsed to JSON result which may be `nil` if no cache is saved or if the cache is cleared.
     
     */
    public static func cacheGetJSONArrayFromAPI(url: String) -> [Any]?{
        let defaults=UserDefaults.standard
        let text=defaults.string(forKey: "__WEBBER_OFFLINE_getJSONArrayFromAPI_\(server)/\(url)")
        var arr:[Any]?
        do{
            if let t=text{
                let json = try JSONSerialization.jsonObject(with: t.data(using: String.Encoding.utf8)!, options: [])
                if let array=json as? [Any]{
                    arr=array
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            print("Webber Error: \(error.localizedDescription)")
            return nil
        }
        return arr
    }
    
    public static func cachePostJSONArrayToAPI(url: String, parameters: String) -> [Any]?{
        let defaults=UserDefaults.standard
        let text=defaults.string(forKey: "__WEBBER_OFFLINE_postJSONArrayToAPI_\(server)/\(url)/\(parameters)")
        var arr:[Any]?
        do{
            if let t=text{
                let json = try JSONSerialization.jsonObject(with: t.data(using: String.Encoding.utf8)!, options: [])
                if let array=json as? [Any]{
                    arr=array
                }else{
                    return nil
                }
            }else{
                return nil
            }
        }catch{
            print("Webber Error: \(error.localizedDescription)")
            return nil
        }
        return arr
    }
    
    /**
     Connects to an API using GET asynchronous and parses the result to JSON.
     
     - Parameters:
     - url: The relative URL to the specified server without slash at the beginning.
     - cache: Specifies where should content be loaded or saved in cache when offline.
     - offline: If `true`, `completion` is called twice, first after loading cache and then after downloading data, else it is called only once after downloading data.
     - completion: Things to do when data is received, for example updating a `UITableView`. The closure receives an optional parameter containing the result parsed to JSON.
     - atLast: Things to do at last, for example stopping a `UIActivityIndicatorView`.
     
     */
    public static func asyncGetJSONArrayFromAPI(url: String, cache: Bool = true, offline: Bool = true, completion: @escaping ([Any]?) -> Void, atLast: (() -> Void)? = nil){
        var arr:[Any]?
        if offline{
            arr=cacheGetJSONArrayFromAPI(url: url)
            completion(arr)
        }
        let queue=DispatchQueue(label: "WebberAsyncGetFromAPI")
        queue.async {
            arr=getJSONArrayFromAPI(url: url, cache: cache)
            DispatchQueue.main.async {
                if isInternetAvailable(){
                    completion(arr)
                }
                if let atLastUnwrapped = atLast{
                    atLastUnwrapped()
                }
            }
        }
    }
    
    public static func asyncPostToAPI(url: String, ignoreServer: Bool = false, reallyPost: Bool = true, parameters: String = "", cache: Bool = true, offline: Bool = true, completion: @escaping (String?) -> Void, atLast: (() -> Void)? = nil){
        let defaults = UserDefaults.standard
        var text:String?
        if offline{
            text=cachePostToAPI(url: url, parameters: parameters)
            completion(text)
        }
        guard isInternetAvailable() else{
            if let atLastUnwrapped = atLast{
                atLastUnwrapped()
            }
            return
        }
        let request = NSMutableURLRequest(url: URL(string: ignoreServer ? "\(url)" : "\(server)/\(url)")!)
        if !reallyPost {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
        }
        request.httpBody = parameters.data(using: .utf8)
        let task=URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("\(url) Webber Error: \(error?.localizedDescription ?? "")")
//                let aC = UIAlertController(title: "خطا", message: "به دلیل اختلال در شبکه خطایی برای اجرای درخواست شما پیش آمده است.", preferredStyle: .alert)
//                aC.addAction(UIAlertAction(title: "بازگشت", style: .cancel, handler: nil))
//                aC.show(aC, sender: aC)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200{
                print("\(url) Webber Error: Status code is \(httpStatus.statusCode)")
//                let aC = UIAlertController(title: "خطا", message: "به دلیل اختلال در شبکه خطایی برای اجرای درخواست شما پیش آمده است.", preferredStyle: .alert)
//                aC.addAction(UIAlertAction(title: "بازگشت", style: .cancel, handler: nil))
//                aC.show(aC, sender: aC)
            }
            
            // TODO: COMMENT NEXT LINE
            DispatchQueue.main.async {
            if cache{
                if let t = String(data: data, encoding: .utf8){
                    defaults.set(t, forKey: "__WEBBER_OFFLINE_postToAPI_\(server)/\(url)/\(parameters)")
                }
            }
            completion(String(data: data, encoding: .utf8))
            if let unwrappedAtLast = atLast{
                unwrappedAtLast()
            }
            }
        })
        
        task.resume()
    }
    
    public static func asyncPostJSONArrayToAPI(url: String, parameters: String = "", cache: Bool = true, offline: Bool = true, completion: @escaping ([Any]?) -> Void, atLast: (() -> Void)? = nil){
        var arr:[Any]?
        if offline{
            arr=cachePostJSONArrayToAPI(url: url, parameters: parameters)
            completion(arr)
        }
        guard isInternetAvailable() else{
            if let atLastUnwrapped = atLast{
                atLastUnwrapped()
            }
            return
        }
        Webber.asyncPostToAPI(url: url, parameters: parameters, cache: cache, offline: offline, completion: { r in
            if let result = r{
                do{
                    let json = try JSONSerialization.jsonObject(with: result.data(using: String.Encoding.utf8)!, options: [])
                    if let array=json as? [Any]{
                        arr=array
                    }else{
                        arr=nil
                    }
                }catch{
                    print("Webber Error: \(error.localizedDescription)")
                    arr=nil
                }
            }
        }, atLast: {
            completion(arr)
            if let unwrappedAtLast = atLast{
                unwrappedAtLast()
            }
        })
    }
    
    public static func cachePostToAPI(url: String, parameters: String) -> String?{
        let defaults=UserDefaults.standard
        return defaults.string(forKey: "__WEBBER_OFFLINE_postToAPI_\(server)/\(url)/\(parameters)")
    }
}


