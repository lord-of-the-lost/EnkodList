//
//  RequestModel.swift
//  EnkodList
//
//  Created by Николай Игнатов on 14.07.2023.
//

import Foundation

// MARK: - RequestModel

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
    
    // MARK: - Computed Properties
    
    var cleanEmail: String? {
          return email?.replacingOccurrences(of: "devnull+", with: "")
      }
    
    var formattedDateUpdate: String? {
          guard let timestamp = dateUpdate else { return nil }
          let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = .medium
          dateFormatter.timeStyle = .medium
          dateFormatter.timeZone = TimeZone.current
          
          return dateFormatter.string(from: date)
      }
}
