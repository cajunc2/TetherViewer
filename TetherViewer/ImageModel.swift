//
//  ImageContainer.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/17/21.
//

import AppKit

class ImageModel: ObservableObject, Identifiable {
	var id: String
	@Published var displayImage = NSImage()
	@Published var imageFilename = ""
	@Published var exif = ExifData()
	
	init(imageUrl: URL) {
		self.id = imageUrl.absoluteString
		self.displayImage = NSImage(byReferencingFile: imageUrl.path)!
		self.imageFilename = imageUrl.lastPathComponent
		if let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) {
			let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
			if let exif = imageProperties as? [String: Any] {
				let e = exif["{Exif}"] as! NSMutableDictionary
				self.exif = ExifData(from: e);
			}
		}
	}
}
