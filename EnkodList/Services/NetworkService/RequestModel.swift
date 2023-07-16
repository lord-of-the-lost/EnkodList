//
//  RequestModel.swift
//  EnkodList
//
//  Created by Николай Игнатов on 14.07.2023.
//

import Foundation

struct AllResults: Codable {
    let total: Int?
    let result: [Item]?
}

struct Item: Codable {
    let id: Int?
    let email: String?
    let firstName: String?
    let lastName: String?
    let dateUpdate: Int?
}
