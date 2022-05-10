//
//  CarryEvents.swift
//  Carrifree
//
//  Created by orca on 2020/10/08.
//  Copyright © 2020 plattics. All rights reserved.
//

import Foundation
import UIKit

@objc protocol CarryDelegate {
    @objc optional func userDataChanged()
    @objc optional func currentAddress(address: String)
    @objc optional func selectAddress(address: String, postalCode: String, lat: Double, lng: Double)
    
    @objc optional func hideActionPicker(value: String, index: Int)
    
    @objc optional func selectWeekday(weekday: Weekday)
    @objc optional func deselectWeekday(weekday: Weekday)
    @objc optional func sceneDisappeared(sceneName: String)
}

var _events: CarryEvents = {
    return CarryEvents.shared
}()

class CarryEvents {
    static let shared = CarryEvents()

    var delegates: [CarryDelegate] = []
    
    private init() {}
    
    func appendDelegate(delegate: CarryDelegate) {
        guard delegates.filter({ $0 === delegate }).isEmpty else {
            _log.log("Delegate is alreay exist..")
            return
        }
        delegates.append(delegate)
    }
    
    func callCurrentLocation(address: String) {
        for delegate in _events.delegates
        {
            delegate.currentAddress?(address: address)
        }
    }
    
    func callHideActionPicker(value: String, index: Int) {
        for delegate in _events.delegates
        {
            delegate.hideActionPicker?(value: value, index: index)
        }
    }
    
    func callSelectAddress(address: String, postalCode: String, lat: Double, lng: Double) {
        for delegate in _events.delegates
        {
            delegate.selectAddress?(address: address, postalCode: postalCode, lat: lat, lng: lng)
        }
    }
    
    func callSelectWeekday(weekday: Weekday) {
        for delegate in _events.delegates
        {
            delegate.selectWeekday?(weekday: weekday)
        }
    }
    
    func callDeselectWeekday(weekday: Weekday) {
        for delegate in _events.delegates
        {
            delegate.deselectWeekday?(weekday: weekday)
        }
    }
    
    func callSceneDisappeared(sceneName: String) {
        for delegate in _events.delegates {
            delegate.sceneDisappeared?(sceneName: sceneName)
        }
    }
    
    func callUserDataChanged() {
        for delegate in _events.delegates {
            delegate.userDataChanged?()
        }
    }
}
