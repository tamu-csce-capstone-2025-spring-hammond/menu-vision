//
//  DishData.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/2/25.
//

import Foundation

struct DishData: Codable {
    let dish_id: Int
    let dish_name: String
    let description: String
    let ingredients: String
    let price: String
    let nutritional_info: String
    let allergens: String
    let model_id: String
    let model_rating: Double

    enum CodingKeys: String, CodingKey {
        case dish_id
        case dish_name
        case description
        case ingredients
        case price
        case nutritional_info
        case allergens
        case model_id
        case model_rating
    }
}

struct DishDataResponse: Codable {
    let restaurant_id: String
    let name: String
    let created_at: String
    let models: [DishData]
}

