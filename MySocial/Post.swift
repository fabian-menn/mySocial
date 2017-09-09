//
//  Post.swift
//  MySocial
//
//  Created by Fabian Menn on 8/27/17.
//  Copyright © 2017 Fabian Menn. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _caption: String!
    private var _userId: String!
    private var _userImgUrl: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postId: String!
    private var _postRef: DatabaseReference!
    
    var caption: String {
        return _caption
    }
    
    var userId: String {
        return _userId
    }
    
    var userImgUrl: String {
        return _userImgUrl
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postId: String {
        return _postId
    }
    
    // creating new post
    init(caption: String, userid: String, userImgUrl: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._userId = userid
        self._userImgUrl = userImgUrl
    }
    
    // getting old post
    init(postId: String, postData: Dictionary<String, Any>) {
        self._postId = postId
        
        if let caption = postData["caption"] as? String{
            self._caption = caption
        }
        
        if let userId = postData["userId"] as? String {
            self._userId = userId
        }
        
        if let userImgUrl = postData["userImgUrl"] as? String {
            self._userImgUrl = userImgUrl
        }
        
        if let imageUrl = postData["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int{
            self._likes = likes
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postId)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
        
    }
}
