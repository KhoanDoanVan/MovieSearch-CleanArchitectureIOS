//
//  MovieListView.swift
//  Networking-CleanArchitectureIOS
//
//  Created by Đoàn Văn Khoan on 1/11/24.
//

import SwiftUI

struct MovieListView: View {
    
    @ObservedObject var viewModel: MoviesListViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                TextField("", text: $viewModel.query, prompt: Text(viewModel.searchBarTitle))
                
                if viewModel.isEmpty {
                    Text(viewModel.emptyDataTitle)
                } else {
                    List(viewModel.items) { item in
                        VStack {
                            Text(item.title)
                            Text(item.overview)
                        }
                    }
                }
                
                if viewModel.loading == .nextPage {
                    ProgressView()
                }
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
