//
//  ViewController.swift
//  MySocial
//
//  Created by Fabian Menn on 8/25/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func facebookBtnPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self, handler: { (result, error) in
            if error != nil {
                print("FABIAN: UHHH...............: Unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("FABIAN: Ohhhh..........: User cancelled authentication")
            } else {
                print("FABIAN: Yeah, Successfully authenticate with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        })
        
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("FABIAN: ..... Unable to authenticate with Firebase - \(error)")
            } else {
                print("FABIAN: .... Successfully authenticated with Firebase")
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("FABIAN: Email User authenticated with Firebase")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("FABIAN: Unable to authenticate with Firebase using email")
                        } else {
                            print("FABIAN: Successfully authenticated with Firebase using email")
                        }
                    })
                }
            })
        }
    }

}

