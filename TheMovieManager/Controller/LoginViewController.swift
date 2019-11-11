//
//  LoginViewController.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginViaWebsiteButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginViaWebsiteTapped() {
        performSegue(withIdentifier: "completeLogin", sender: nil)
    }
   
    @IBAction func loginTapped(_ sender: UIButton) {
           TMDBClient.getRequestToken(completionHandler: handleRequestTokenResponse(success:error:))
       }
    
    func handleRequestTokenResponse(success: Bool, error: Error?) {
        if success {
           print("request token:" + TMDBClient.Auth.requestToken)
            
            DispatchQueue.main.async {
                TMDBClient.login(username: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "", completionHanler: self.handleLoginResponse(success:error:))
            }
        }
    }
    
    func handleLoginResponse(success: Bool, error: Error?) {
        if success {
            print("valid token:" + TMDBClient.Auth.requestToken)
            TMDBClient.createSessionId(completionHandler: self.handleSessionIdResponse(success:error:))
        }
        else {
            print("no valid token")
        }
    }
    
    func handleSessionIdResponse(success: Bool, error: Error?) {
        if success {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "completeLogin", sender: nil)
            }
        }
    }
}

