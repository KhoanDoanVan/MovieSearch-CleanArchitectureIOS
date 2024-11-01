//
//  MoviesListItemViewModel.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import Foundation

struct MoviesListItemViewModel: Identifiable {
    let id: String
    let title: String
    let overview: String
    let releaseDate: String
    let posterImagePath: String?
}

extension MoviesListItemViewModel {
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title ?? ""
        self.posterImagePath = movie.posterPath
        self.overview = movie.overview ?? ""
        
        if let releaseDate = movie.releaseDate {
            self.releaseDate = "\(NSLocalizedString("Release Date", comment: "")):\(dateFormatter.string(from: releaseDate))"
        } else {
            self.releaseDate = NSLocalizedString("To be announced", comment: "")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
