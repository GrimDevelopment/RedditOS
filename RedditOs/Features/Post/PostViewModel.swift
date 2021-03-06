//
//  PostDetailViewModel.swift
//  RedditOs
//
//  Created by Thomas Ricouard on 10/07/2020.
//

import Foundation
import SwiftUI
import Combine
import Backend

class PostViewModel: ObservableObject {
    @Published var post: SubredditPost
    @Published var comments: [Comment]?
    
    private var cancellableStore: [AnyCancellable] = []
    
    init(post: SubredditPost) {
        self.post = post
    }
    
    func postVisit() {
        let oldValue = post.visited
        let cancellable = post.visit()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if response.error != nil {
                    self?.post.visited = oldValue
                }
            }
        cancellableStore.append(cancellable)
    }
    
    func postVote(vote: SubredditPost.Vote) {
        let oldValue = post.likes
        let cancellable = post.vote(vote: vote)
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] response in
                if response.error != nil {
                    self?.post.likes = oldValue
                }
            }
        cancellableStore.append(cancellable)
    }
    
    func toggleSave() {
        let oldValue = post.saved
        let cancellable = (post.saved ? post.unsave() : post.save())
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] response in
                if response.error != nil {
                    self?.post.saved = oldValue
                }
            }
        cancellableStore.append(cancellable)
    }
    
    func fechComments() {
        let cancellable = Comment.fetch(subreddit: post.subreddit, id: post.id)
            .receive(on: DispatchQueue.main)
            .map{ $0.last?.comments }
            .sink{ [weak self] comments in
                self?.comments = comments
            }
        cancellableStore.append(cancellable)
    }
}
