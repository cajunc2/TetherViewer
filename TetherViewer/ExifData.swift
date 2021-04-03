//
//  ExifData.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/17/21.
//

import Foundation

struct ExifData {
	let fNumber : String
	let shutterSpeed : String
	let iso : String
	let focalLength : String
	
	init() {
		self.fNumber = ""
		self.shutterSpeed = ""
		self.iso = ""
		self.focalLength = ""
	}
	
	init?(from: NSMutableDictionary) {
		if let fNumber = from["FNumber"] as? NSNumber {
			self.fNumber = fNumber.stringValue
		} else {
			return nil
		}
		let ssValue = from["ExposureTime"] as? Double ?? 0.0
		self.shutterSpeed = "1/" + String(Int(1.0 / ssValue))
		self.iso = "ISO " + ((from["ISOSpeedRatings"] as! NSArray).lastObject as! NSNumber).stringValue
		self.focalLength = (from["FocalLength"] as! NSNumber).stringValue
	}
}
