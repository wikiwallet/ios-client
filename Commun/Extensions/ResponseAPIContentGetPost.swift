//
//  ResponseAPIContentGetPost.swift
//  Commun
//
//  Created by Chung Tran on 20/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

public typealias PostSection = AnimatableSectionModel<String, ResponseAPIContentGetPost>

extension ResponseAPIContentGetPost: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetPost, rhs: ResponseAPIContentGetPost) -> Bool {
        return lhs.identity == rhs.identity &&
            lhs.contentId.permlink == rhs.contentId.permlink &&
            lhs.content.title == rhs.content.title &&
            lhs.content.tags == rhs.content.tags &&
            lhs.content.body.preview == rhs.content.body.preview &&
            lhs.content.body.full == rhs.content.body.full &&
            lhs.votes.upCount == rhs.votes.upCount &&
            lhs.votes.downCount == rhs.votes.downCount &&
            lhs.votes.hasUpVote == rhs.votes.hasUpVote &&
            lhs.votes.hasDownVote == rhs.votes.hasDownVote
    }
    
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
    
    public static var dataSource: RxTableViewSectionedAnimatedDataSource<PostSection> {
        return .init(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCardCell", for: indexPath) as! PostCardCell
                cell.setUp(with: item)
                return cell
            }
        )
    }
}
