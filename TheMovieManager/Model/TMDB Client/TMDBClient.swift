//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "993d0a4e5e2d00d2a8c03746c7014c88"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    //MARK:- Endpoints
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        
        var stringValue: String {
            switch self {
                
            case .getWatchlist:
                return Endpoints.base + "/account/\(Auth.accountId)/watchlist/movies" + Endpoints.apiKeyParam + "&session_id=\(Auth.sessionId)"
            case .getRequestToken:
                return Endpoints.base + "/authentication/token/new" + Endpoints.apiKeyParam
            case .login:
                return Endpoints.base + "/authentication/token/validate_with_login" + Endpoints.apiKeyParam
            case .createSessionId:
                return Endpoints.base + "/authentication/session/new" + Endpoints.apiKeyParam
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    
    //MARK:- GetRequestToken Network call method
    
    class func getRequestToken(completionHandler: @escaping(Bool, Error?)-> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getRequestToken.url) { (data, response, error) in
            guard let data = data else {
                completionHandler(false, error)
                 print("get request token error: \(error!)")
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let tokenResponse = try decoder.decode(RequestTokenresponse.self, from: data)
                Auth.requestToken = tokenResponse.requestToken
                completionHandler(true,nil)
            }
            catch {
                completionHandler(false,error)
            }
        }
        task.resume()
    }
    
    
    //MARK:- Login method
    
    class func login(username: String, password: String, completionHanler: @escaping(Bool, Error?)-> Void) {
        
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = LoginRequest(username: username, password: password, requestToken: Auth.requestToken)
        let encoder  =  JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try! encoder.encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHanler(false,error)
                 print("login error: \(error!)")
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObject = try decoder.decode(RequestTokenresponse.self, from: data)
                Auth.requestToken = responseObject.requestToken
                print("new valid request token: \(Auth.requestToken)")
                completionHanler(true,nil)
            }
            catch {
                completionHanler(false,error)
            }
        }
        task.resume()
    }
    
    
    //MARK:- get session ID method
    
    class func createSessionId(completionHandler: @escaping(Bool,Error?)-> Void) {
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = PostSession(requestToken: Auth.requestToken)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try! encoder.encode(body)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                completionHandler(false,error)
                print("create session id error: \(error!)")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let sessionIdResponse = try decoder.decode(SessionResponse.self, from: data)
                Auth.sessionId = sessionIdResponse.sessionId
                completionHandler(true,nil)
            }
            catch {
                completionHandler(false,error)
            }
        }
        task.resume()
    }
    
    
    //MARK:- GetWatchList Network call method
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
}
