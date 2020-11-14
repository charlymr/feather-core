//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 11. 14..
//

import Vapor

public extension Application {

    var isDebug: Bool { !environment.isRelease && environment != .production }
}
