//
//  DishData.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/2/25.
//

import Foundation

/// A model representing dish information retrieved from the backend API.
///
/// This struct contains all the metadata for a dish that has an associated AR model,
/// including basic information like name, description, and price, as well as
/// AR-specific fields like model_id and model_rating.
struct DishData: Codable {
    /// The unique identifier for the dish.
    let dish_id: Int
    
    /// The name of the dish.
    let dish_name: String
    
    /// A detailed description of the dish.
    let description: String
    
    /// A comma-separated list of ingredients in the dish.
    let ingredients: String
    
    /// The price of the dish, stored as a string to handle various formats.
    let price: String
    
    /// Nutritional information for the dish.
    let nutritional_info: String
    
    /// A comma-separated list of allergens present in the dish.
    let allergens: String
    
    /// The unique identifier for the AR model associated with this dish.
    let model_id: String
    
    /// A rating score for the AR model, used for sorting and quality indication.
    let model_rating: Double

    /// Coding keys to map between JSON property names and struct property names.
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

/// A container model representing a restaurant with its collection of dishes and AR models.
///
/// This struct is used to decode the API response that contains the restaurant information
/// and all its associated dish models.
struct DishDataResponse: Codable {
    /// The unique identifier for the restaurant.
    let restaurant_id: String
    
    /// The name of the restaurant.
    let name: String
    
    /// The timestamp when the restaurant data was created.
    let created_at: String
    
    /// The collection of dish models associated with this restaurant.
    let models: [DishData]
}
