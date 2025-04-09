//
//  DishMapping.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/3/25.
//

import Foundation

class DishMapping: ObservableObject {
    @Published var modelsByDishName: [String: [DishData]] = [:]

    func setModels(_ models: [DishData]) {
        var newMapping: [String: [DishData]] = [:]

        for model in models {
            newMapping[model.dish_name, default: []].append(model)
        }

        self.modelsByDishName = newMapping

        print("DishMapping updated:")
        for (dish, models) in modelsByDishName {
            print("\(dish): \(models.count) model(s)")
            for model in models {
                print("- model_id: \(model.model_id), dish_id: \(model.dish_id)")
            }
        }
        print(modelsByDishName)
    }
}
