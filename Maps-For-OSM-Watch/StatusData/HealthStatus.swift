//
//  HeartbeatMonitor.swift
//  Maps For OSM Watch
//
//  Created by Michael Rönnau on 13.10.24.
//

import Foundation
import HealthKit

@Observable class HealthStatus: NSObject {
    
    var heartRate: Double = 0.0
    
    private var healthStore: HKHealthStore?
    private let heartRateQuantityType = HKObjectType.quantityType(forIdentifier: .heartRate)
    private let appStartTime: Date
    
    override init() {
        self.appStartTime = Date()
        super.init()
        
        if HKHealthStore.isHealthDataAvailable() {
            self.healthStore = HKHealthStore()
            self.requestAuthorization()
        }
    }
    
    private func requestAuthorization() {
        guard let heartRateQuantityType = self.heartRateQuantityType else { return }
        
        healthStore?.requestAuthorization(toShare: nil, read: [heartRateQuantityType]) { success, error in
            if success {
                self.startMonitoring()
            }
        }
    }
    
    func startMonitoring() {
        guard let heartRateQuantityType = self.heartRateQuantityType else { return }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateQuantityType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, newAnchor, error) in
                guard let samples = samples as? [HKQuantitySample] else { return }
                self.process(samples: samples)
            }
        
        query.updateHandler = { (query, samples, deletedObjects, newAnchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.process(samples: samples)
        }
        
        healthStore?.execute(query)
    }
    
    private func process(samples: [HKQuantitySample]) {
        for sample in samples {
            if sample.endDate > appStartTime {
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                
                DispatchQueue.main.async {
                    self.heartRate = heartRate
                }
            }
        }
    }
}
