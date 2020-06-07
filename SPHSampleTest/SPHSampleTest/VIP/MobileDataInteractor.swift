//
//  MobileDataInteractor.swift
//  SPHSampleTest
//
//  Created by Chandresh on 7/6/20.
//  Copyright © 2020 Chandresh. All rights reserved.
//

import Foundation
protocol MobileDataDetailsBusinessLogic {
  func fetchMobileData(request: MobileDataModel.Data.Request)
}

protocol MobileDetailsDataStore {
  var posts: [MobileDataViewModel] { get set }
}

class MobileDataInteractor: MobileDataDetailsBusinessLogic, MobileDetailsDataStore {
  var posts: [MobileDataViewModel] = []
  var presenter: MobileDataPresenterLogic?
var worker: MobileDataWorker? = MobileDataWorker()

    // MARK: Do something
  
  func fetchMobileData(request: MobileDataModel.Data.Request) {
    worker?.fetchMobileData(completion: { (response , error) in
        if response != nil{
            self.addDataYearly(record: (response?.result?.records)!)
        }else{
            print("error")
        }
    })
  }
    
  func addDataYearly(record :  [MobileDataModel.Data.Records]) {
    var lastYear = 0
    var year = 0
    self.posts = []
    var lastQData = 0.00
    var isValueDataDesc = false
    var yearlyMobileData = 0.00
        for value in (record) {
         let quarterData = value.quarter?.components(separatedBy: "-")
            year  = Int(quarterData?[0] ?? "") ?? 0
            if year >= 2008 && year <= 2019 {
                let mobileData = Double(Float(value.volume_of_mobile_data ?? "") ?? 0)
                if lastYear == year || lastYear == 0 {
                    yearlyMobileData += mobileData
                    isValueDataDesc = decInDataYearly(lastQData:lastQData, currentQData:mobileData, isValueDataDesc:isValueDataDesc)
                }else if lastYear != 0 {
                    let model = MobileDataViewModel(volume: String(yearlyMobileData) , quarter: String(lastYear) , id: value._id ?? 0, volumeDataDecrease: isValueDataDesc)
                    posts.append(model)
                    yearlyMobileData = mobileData
                    isValueDataDesc = false
                }
                lastQData = mobileData
                lastYear = year
            }
        }
    self.presenter?.presentMobileData(response: posts)
    }
    
    func decInDataYearly(lastQData: Double, currentQData: Double, isValueDataDesc: Bool) -> Bool {
        if !isValueDataDesc && currentQData > lastQData {
            return false
        }
        return true
    }
}
