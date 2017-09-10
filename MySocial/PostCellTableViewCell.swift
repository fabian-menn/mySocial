//
//  PostCellTableViewCell.swift
//  MySocial
//
//  Created by Fabian Menn on 8/27/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import UIKit
import Firebase

class PostCellTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    
    var likesRef: DatabaseReference!
    var usernameRef: DatabaseReference!
    var post: Post!
    
    var profileImgUrl: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, postPic: UIImage? = nil, profilePic: UIImage? = nil) {
        profileImg.image = UIImage(named: "blank")
        postImg.image = UIImage(named: "placeholder")
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postId)
        //usernameRef = DataService.ds.REF_USER_CURRENT.child("username")
        self.caption.text = self.post.caption
        self.likesLbl.text = "\(post.likes)"
        print("configure: cap \(post.caption)")
        
        // get post images
        if postPic != nil {
            self.postImg.image = postPic
        } else {
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("FABIAN: Unable to download image from firebase storage")
                } else {
                    print("FABIAN: Image downloaded from storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
            
        }
        
        if profilePic != nil {
            self.profileImg.image = profilePic
        } else {
            let ref = Storage.storage().reference(forURL: post.userImgUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("FABIAN: Unable to download image from firebase storage")
                } else {
                    print("FABIAN: Image downloaded from storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            ProfileConfigVC.imageCache.setObject(img, forKey: post.userImgUrl as NSString)
                        }
                    }
                }
            })
            
        }
        
        
        // whether user already liked it or not
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "like-unfilled")
            } else {
                self.likeImg.image = UIImage(named: "like-filled")
            }
        })
        
        usernameLbl.text = post.username
        
        
        // get username from user id
//        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
//            
//            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
//                for snap in snapshot {
//                    //print("FABIAN snaap: \(snap)")
//                    if let postDict = snap.value as? Dictionary<String, Any> {
//                        //print("FABIAN: value \(snap.key)")
//                        if post.userId == snap.key {
//                            self.usernameLbl.text = postDict["username"] as! String
//                            //print("FABIAN: \(postDict["username"])")
//                            self.profileImgUrl = postDict["imageUrl"] as! String
//                            self.getProfileImg(profilePic: profilePic)
//                        }
//                        
//                    }
//                }
//            }
//        })
    

    }
    
    func getProfileImg(profilePic: UIImage? = nil) {
        // get profile img
        if profilePic != nil {
            self.profileImg.image = profilePic
        } else {
            let ref = Storage.storage().reference(forURL: profileImgUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("FABIAN: Unable to download image from firebase storage")
                } else {
                    print("FABIAN: Image downloaded from storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.profileImg.image = img
                            ProfileConfigVC.imageCache.setObject(img, forKey: self.profileImgUrl as NSString)
                        }
                    }
                }
            })
            
        }
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        //toggle the heart img
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "like-filled")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeImg.image = UIImage(named: "like-unfilled")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
}
