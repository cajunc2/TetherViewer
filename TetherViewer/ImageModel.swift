//
//  ImageContainer.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/17/21.
//

import AppKit
import QuickLookThumbnailing
import CoreImage

class ImageModel: Identifiable, Equatable, ObservableObject {
	static func == (lhs: ImageModel, rhs: ImageModel) -> Bool {
		return lhs.id == rhs.id
	}
	
	let id : Int
	@Published var clippedImage : NSImage
	@Published var fullImage : NSImage
	@Published var thumbnail : NSImage?
	@Published var showClipping = false
	let imageFilename : String
	let exif : ExifData?
	static let colorCubeFilter = ImageModel.colorCubeFilterForHighlights(threshold: 0.98)
	
	
	init(id: Int, imageUrl: URL) {
		self.id = id
		let img = NSImage(byReferencingFile: imageUrl.path)!
		self.fullImage = img
		self.clippedImage = ImageModel.buildClippingImage(input: img)
		self.imageFilename = imageUrl.lastPathComponent
		if let imageSource = CGImageSourceCreateWithURL(imageUrl as CFURL, nil) {
			let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
			if let exif = imageProperties as? [String: Any] {
				if let e = exif["{Exif}"] as? NSMutableDictionary {
					self.exif = ExifData(from: e);
				} else {
					self.exif = nil
				}
			} else {
				self.exif = nil
			}
		} else {
			self.exif = nil
		}
		
		let previewGenerator = QLThumbnailGenerator()
		let thumbnailSize = CGSize(width: 256, height: 256)
		let scale = NSScreen.main?.backingScaleFactor ?? 1.0
		
		let group = DispatchGroup()
		group.enter()
		let request = QLThumbnailGenerator.Request(fileAt: imageUrl, size: thumbnailSize, scale: scale, representationTypes: .thumbnail)
		previewGenerator.generateBestRepresentation(for: request) { (thumbnail, error) in
			if let error = error {
				print(error.localizedDescription)
			} else if let thumb = thumbnail {
				self.thumbnail = thumb.nsImage
			}
			group.leave()
		}
		group.wait()
	}
	
	static func buildClippingImage(input : NSImage) -> NSImage {
		let cgImage = input.cgImage(forProposedRect: nil, context: nil, hints: [:])!
		let inputImage = CIImage(cgImage: cgImage)
		colorCubeFilter.setValue(inputImage, forKey: kCIInputImageKey)
		let outputImage = colorCubeFilter.outputImage!
		let rep = NSBitmapImageRep(ciImage: outputImage)
		let newImage = NSImage()
		newImage.addRepresentation(rep)
		return newImage
	}
	
	static func colorCubeFilterForHighlights(threshold: Float) -> CIFilter {
		let size = 64
		var cubeData = [Float](repeating: 0, count: size * size * size * 4)
		var rgb: [Float] = [0, 0, 0]
		var offset = 0
		
		for z in 0 ..< size {
			rgb[2] = Float(z) / Float(size) // blue value
			for y in 0 ..< size {
				rgb[1] = Float(y) / Float(size) // green value
				for x in 0 ..< size {
					rgb[0] = Float(x) / Float(size) // red value
					if(rgb[0] > threshold || rgb[1] > threshold || rgb[2] > threshold) {
						cubeData[offset] = 1.0
						cubeData[offset + 1] = 0.0
						cubeData[offset + 2] = 0.0
						cubeData[offset + 3] = 1.0
					} else {
						cubeData[offset] = rgb[0]
						cubeData[offset + 1] = rgb[1]
						cubeData[offset + 2] = rgb[2]
						cubeData[offset + 3] = 1.0
					}
					offset += 4
				}
			}
		}
		let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
		let data = b as NSData
		
		let colorCube = CIFilter(name: "CIColorCube", parameters: [
			"inputCubeDimension": size,
			"inputCubeData": data
		])
		return colorCube!
	}
	
}
