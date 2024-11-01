//
//  MoviesListViewModel.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import Foundation

enum MoviesListViewModelLoading {
    case fullScreen
    case nextPage
}

// MARK: - Movies List View Model
final class MoviesListViewModel: ObservableObject {
    
    private let searchMoviesUseCase: SearchMoviesUseCase
    
    // MARK: - Properties
    @Published var items: [MoviesListItemViewModel] = []
    @Published var loading: MoviesListViewModelLoading? = nil
    @Published var query: String = ""
    @Published var error: String? = nil
    
    private var currentPage: Int = 0
    private var totalPageCount: Int = 1
    private var pages: [MoviesPage] = []
    private var moviesLoadTask: Cancellable?
    
    var hasMorePages: Bool { return currentPage < totalPageCount }
    var nextPage: Int { return hasMorePages ? currentPage + 1 : currentPage }
    
    var isEmpty: Bool { return items.isEmpty }
    var screenTitle: String { return "Movie Search" }
    var emptyDataTitle: String { return "No results found" }
    var searchBarTitle: String { return "Search Movie" }
    
    // MARK: - Init
    
    init(
        searchMoviesUseCase: SearchMoviesUseCase
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
    }
    
    // MARK: - Actions
    
    // Append Page
    private func appendPage(_ moviesPage: MoviesPage) {
        currentPage = moviesPage.page
        totalPageCount = moviesPage.totalPages
        
        pages = pages.filter {
            $0.page != moviesPage.page
        } + [moviesPage]
        
        items = pages.flatMap {
            $0.movies.map(MoviesListItemViewModel.init)
        }
    }
    
    // Load List Movie
    private func load(movieQuery: MovieQuery, loadingType: MoviesListViewModelLoading) {
        self.loading = loadingType
        self.query = movieQuery.query
        
        self.moviesLoadTask = searchMoviesUseCase.execute(
            requestValue: .init(query: movieQuery, page: nextPage)
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let page):
                    self?.appendPage(page)
                case .failure(let error):
                    self?.handle(error: error)
                }
                
                self?.loading = nil
            }
        }
    }
    
    // Handle Error
    private func handle(error: Error) {
        self.error = error.isInternetConnectionError ? "No internet connection" : "Failed loading movies"
    }
    
    // Update Movies list
    private func update(movieQuery: MovieQuery) {
        resetPages()
        load(movieQuery: movieQuery, loadingType: .fullScreen)
    }
    
    // Reset
    private func resetPages() {
        currentPage = 0
        totalPageCount = 1
        pages.removeAll()
        items.removeAll()
    }
}
