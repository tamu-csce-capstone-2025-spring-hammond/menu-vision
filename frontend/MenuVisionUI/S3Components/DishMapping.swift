//
//  DishMapping.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/3/25.
//

import Foundation

class DishMapping: ObservableObject {
    @Published var modelsByDishName: [String: [DishData]] = [:]
    
    @Published var finishedDownloading: Bool = false;
    
    @Published var finishedLoading: Bool = false;
    
    @Published var goToID: String = "";
    
    func setModels(_ models: [DishData]) {
        var newMapping: [String: [DishData]] = [:]
        
        let modelList = models.sorted(by: { $0.model_rating > $1.model_rating});

        for model in modelList {
            newMapping[model.dish_name, default: []].append(model);
        }

        self.modelsByDishName = newMapping

    }
    
    func getModels() -> [String: [DishData]]{
        return modelsByDishName;
    }
    
    func setStartedDownloading(){
        self.finishedDownloading = false;
    }
    
    func setFinishedDownloading(){
        self.finishedDownloading = true;
    }
    
    func isFinishedDownloading() -> Bool{
        return finishedDownloading;
    }
    
    func setStartedLoading(){
        self.finishedLoading = false;
    }
    
    func setFinishedLoading(){
        self.finishedLoading = true;
    }
    
    func isFinishedLoading() -> Bool{
        return finishedLoading;
    }
    
    func setGoTo(id : String){
        self.goToID = id;
    }
    
    func retrieveGoTo() -> String{
        return self.goToID;
    }
}
