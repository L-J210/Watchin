//
//  SearchResult.swift
//  Watchin
//
//  Created by Archeron on 10/02/2022.
//

import Foundation

// MARK: - Data Mapping From API JSON Response

struct SearchResult: Decodable {
    var tv_shows: [TvShowsSearchDetail]
}

struct TvShowsSearchDetail: Decodable {
    var id: Int
    var name: String
    var apiFormatedName: String
    var imageStringUrl: String

    // setting coding keys to custom property names :
    private enum CodingKeys: String, CodingKey {
        case id, name, apiFormatedName = "permalink", imageStringUrl = "image_thumbnail_path"
    }

}

extension TvShowsSearchDetail: TvShowPreview {
    var imageUrl: URL? {
        return URL(string: imageStringUrl)
    }

    var watchedEpisodes: String {
        return "Watched episodes: \nClic to start tracking!"
    }

    var platformAssociated: String {
        return "On: add platform"
    }


}
