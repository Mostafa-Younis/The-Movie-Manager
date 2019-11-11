//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct RequestTokenresponse: Codable {
    let success: Bool
    let expiresAt: String
    let requestToken: String
    
    enum codingKeys: String, CodingKey {
        case success = "success"
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
} 
