//
//  FeedVCViewController.swift
//  MySocial
//
//  Created by Fabian Menn on 8/25/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("FABIAN: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "toSignInVC", sender: nil)
    }

}
