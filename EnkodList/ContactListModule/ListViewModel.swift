//
//  ListViewModel.swift
//  EnkodList
//
//  Created by Николай Игнатов on 17.07.2023.
//

import UIKit

// MARK: - ListViewModelProtocol

protocol ListViewModelProtocol {
    var onUpdate: (() -> Void)?  { get set }
    var numberOfItems: Int { get }
    func fetchData()
    func item(at index: Int) -> Item?
    func filterItems(with searchText: String)
}

// MARK: - ListViewModel

final class ListViewModel: ListViewModelProtocol {
    private let networkService: NetworkServiceProtocol
    private var allItems: [Item] = []
    private var filteredItems: [Item] = []

    var onUpdate: (() -> Void)?

    var numberOfItems: Int {
        return filteredItems.count
    }

    init() {
        self.networkService = NetworkService()
    }

    func fetchData() {
        networkService.fetchData { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let results = try decoder.decode(AllResults.self, from: data)

                    guard let fetchedItems = results.result else {
                        print("Ошибка: не удалось получить данные")
                        return
                    }

                    self?.allItems = fetchedItems
                    self?.filteredItems = fetchedItems
                    self?.onUpdate?()
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

    func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter { ($0.email?.lowercased() ?? "").localizedCaseInsensitiveContains(searchText) }
        }
        onUpdate?()
    }
}
