//
//  DishMapping.swift
//  MenuVision
//
//  Created by Ethan Nguyen on 4/3/25.
//

import Foundation

/// A class responsible for managing dish model data and state tracking in the application.
///
/// `DishMapping` provides a centralized store for dish model data, organized by dish name,
/// and includes state flags for tracking download and loading processes. It also maintains
/// a counter for model download progress.
class DishMapping: ObservableObject {
    /// A dictionary mapping dish names to their associated model data.
    ///
    /// The key is the dish name, and the value is an array of `DishData` objects that are sorted by model rating.
    @Published var modelsByDishName: [String: [DishData]] = [:]
    
    /// A flag indicating whether model downloading has completed.
    @Published var finishedDownloading: Bool = false;
    
    /// A flag indicating whether model loading has completed.
    @Published var finishedLoading: Bool = false;
    
    /// The ID of a specific model to navigate to in the AR view.
    @Published var goToID: String = "";
    
    /// The number of models that have been downloaded so far.
    @Published var modelCount: Int = 0;
    
    /// The total number of models that need to be downloaded.
    @Published var totalModels: Int = 0;
    
    /// Sets the dish models data and organizes them by dish name.
    ///
    /// This method sorts the models by rating before organizing them into the dictionary.
    ///
    /// - Parameter models: An array of `DishData` objects to be stored and organized.
    func setModels(_ models: [DishData]) {
        var newMapping: [String: [DishData]] = [:]
        
        let modelList = models.sorted(by: { $0.model_rating > $1.model_rating});

        for model in modelList {
            newMapping[model.dish_name, default: []].append(model);
        }

        self.modelsByDishName = newMapping
    }
    
    /// Retrieves the current mapping of dish names to model data.
    ///
    /// - Returns: A dictionary where keys are dish names and values are arrays of `DishData` objects.
    func getModels() -> [String: [DishData]]{
        return modelsByDishName;
    }
    
    /// Sets the downloading state to "in progress".
    func setStartedDownloading(){
        self.finishedDownloading = false;
    }
    
    /// Sets the downloading state to "completed".
    func setFinishedDownloading(){
        self.finishedDownloading = true;
    }
    
    /// Checks if downloading has finished.
    ///
    /// - Returns: A boolean indicating whether the download process has completed.
    func isFinishedDownloading() -> Bool{
        return finishedDownloading;
    }
    
    /// Sets the loading state to "in progress".
    func setStartedLoading(){
        self.finishedLoading = false;
    }
    
    /// Sets the loading state to "completed".
    func setFinishedLoading(){
        self.finishedLoading = true;
    }
    
    /// Checks if loading has finished.
    ///
    /// - Returns: A boolean indicating whether the loading process has completed.
    func isFinishedLoading() -> Bool{
        return finishedLoading;
    }
    
    /// Sets the ID of the model to navigate to in the AR view.
    ///
    /// - Parameter id: The unique identifier of the model to navigate to.
    func setGoTo(id : String){
        self.goToID = id;
    }
    
    /// Retrieves the ID of the model to navigate to.
    ///
    /// - Returns: The ID of the model to navigate to.
    func retrieveGoTo() -> String{
        return self.goToID;
    }
}
