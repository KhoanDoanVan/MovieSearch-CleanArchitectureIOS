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
                    .background(.gray)
                
                Button(action: {
                    viewModel.didSearch()
                }) {
                    Text("Search")
                        .padding(8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                if viewModel.items.isEmpty {
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
            .alert(isPresented: $viewModel.isError) {
                Alert(title: Text("Error"), message: Text(viewModel.error ?? "Error"))
            }
        }
    }
}
