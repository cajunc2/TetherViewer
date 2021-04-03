//
//  PhotoWatcher.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/17/21.
//

import AppKit
import ImageCaptureCore

class PhotoWatcher : ObservableObject {
	let watchDir: URL
	var dirObserver: DirectoryObserver?
	@Published var imageModels = [ImageModel]()
	@Published var latest : ImageModel?
	@Published var showHighlightClipping = false

	init(watchDir: URL) {
		self.watchDir = watchDir
		showLatestImage()
		self.dirObserver = DirectoryObserver(URL: watchDir, block: showLatestImage)
	}
	
	func toggleHighlightClipping() -> Void {
		self.showHighlightClipping.toggle()
	}
	
	func selectImage(_ image:ImageModel) -> Void {
		self.latest = image
	}
	
	func showLatestImage() -> Void {
		let files = PhotoWatcher.filesSortedList(atPath: watchDir)
		files.forEach { url in
			if url.absoluteString.uppercased().hasSuffix("JPG") {
				if imageModels.contains(where: { (im) -> Bool in
					return im.imageFilename == url.lastPathComponent
				}) { return }
				DispatchQueue.main.async {
					let newImageModel = ImageModel(id: self.imageModels.count, imageUrl: url)
					self.imageModels.append(newImageModel)
					self.latest = newImageModel
				}
			}
		}
	}

	static func filesSortedList(atPath: URL) -> [URL] {
		let keys = [URLResourceKey.contentModificationDateKey]
		
		guard let fullPaths = try? FileManager.default.contentsOfDirectory(at: atPath, includingPropertiesForKeys:keys, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) else {
			return []
		}
		
		let orderedFullPaths = fullPaths.sorted(by: { (url1: URL, url2: URL) -> Bool in
			do {
				let values1 = try url1.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
				let values2 = try url2.resourceValues(forKeys: [.creationDateKey, .contentModificationDateKey])
				
				if let date1 = values1.creationDate, let date2 = values2.creationDate {
					return date1.compare(date2) == ComparisonResult.orderedAscending
				}
			} catch _{
				
			}
			return true
		})
		return orderedFullPaths
	}

}
