//
//  ListViewModel.swift
//  EnkodList
//
//  Created by Николай Игнатов on 17.07.2023.
//

import UIKit

// MARK: - ListViewModelProtocol

protocol ListViewModelProtocol {
    var onUpdate: (() -> Void)? { get set }
    var numberOfItems: Int { get }
    var pages: [[Item]] { get }
    func fetchData()
    func item(at index: Int) -> Item?
    func filterItems(with searchText: String)
    func item(at index: Int, in page: Int) -> Item?
}

// MARK: - ListViewModel

final class ListViewModel: ListViewModelProtocol {
    private let networkService: NetworkServiceProtocol
    private var allItems: [Item] = []
    private var filteredItems: [Item] = [] {
        didSet {
            guard filteredItems.count > 0 else { return }
            
            let pageCount = filteredItems.count / 10
            let lastCount = filteredItems.count % 10
            
            var pages: [[Item]] = []
            
            for index in 0..<pageCount {
                let page = Array(filteredItems[index * 10..<(index + 1) * 10])
                pages.append(page)
            }
            
            if lastCount > 0 {
                let lastPage = Array(filteredItems[pageCount * 10..<filteredItems.count])
                pages.append(lastPage)
            }
            
            self.pages = pages
        }
    }
    
    var pages: [[Item]] = []
    
    var onUpdate: (() -> Void)?
    
    var numberOfItems: Int {
        return filteredItems.count
    }
    
    init() {
        self.networkService = NetworkService()
    }
    
    func fetchData() {
        networkService.fetchData { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode(AllResults.self, from: data)
                    
                    guard let fetchedItems = results.result else {
                        print("Ошибка: не удалось получить данные")
                        return
                    }
                    
                    self.allItems = fetchedItems
                    self.filteredItems = fetchedItems
                    self.onUpdate?()
                } catch {
                    print("Ошибка при декодировании данных: \(error)")
                }
            case .failure(let error):
                print("Ошибка при выполнении сетевого запроса: \(error)")
            }
        }
    }
    
    func item(at index: Int) -> Item? {
        guard index >= 0, index < filteredItems.count else {
            return nil
        }
        return filteredItems[index]
    }
    
    func item(at index: Int, in page: Int) -> Item? {
        guard page >= 0, page < pages.count else {
            return nil
        }
        
        let pageItems = pages[page]
        
        guard index >= 0, index < pageItems.count else {
            return nil
        }
        
        return pageItems[index]
    }
    
    func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { ($0.email?.lowercased() ?? "").localizedCaseInsensitiveContains(searchText) }
        }
        onUpdate?()
    }
}

