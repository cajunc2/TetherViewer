//
//  ContentView.swift
//  TetherViewer
//
//  Created by Matthew Martin on 3/16/21.
//

import SwiftUI

struct MainImageView: View {
	@ObservedObject var pw : PhotoWatcher
	
	@State var currentScale: CGFloat = 1.0
	@State var previousScale: CGFloat = 1.0
	
	@State var currentOffset = CGSize.zero
	@State var previousOffset = CGSize.zero
	
	@State var frameSize = CGSize.zero
	
	@State var animationDuration = 0.0
	
	@State var clickPosition = CGPoint.zero
	@State var didDrag = false
	
	@State private var nsImage = NSImage()
			
	var body: some View {
		GeometryReader { (geometry) in
			ZStack {
				VStack {
					ProgressView()
					Text("Waiting for photos...").font(.largeTitle).foregroundColor(.gray).padding()
				}
				self.makeView(geometry)
			}
		}
	}
	
	func toggleZoom() {
		self.animationDuration = 0.15
		if self.currentScale == 1.0 {
			guard let img = pw.latest else {
				return
			}
			let imgWidth = CGFloat(img.fullImage.representations[0].pixelsWide)
			let imgHeight = CGFloat(img.fullImage.representations[0].pixelsHigh)
			let imageAspect = imgWidth / imgHeight
			let frameHeight = frameSize.width / imageAspect
			
			let scaleFactor = (imgHeight > imgWidth) ? imgHeight / frameHeight : imgWidth / frameSize.width
			
			let normClickX = clickPosition.x / frameSize.width
			let normClickY = clickPosition.y / frameHeight
			let offsetX =  (frameSize.width * (0.5 - normClickX))
			let offsetY = (frameHeight * (0.5 - normClickY))
			
			self.currentScale = scaleFactor / (NSScreen.main?.backingScaleFactor ?? 1.0)
//			self.currentOffset.width = offsetX
//			self.currentOffset.height = offsetY
		} else {
			self.currentScale = 1.0
			self.currentOffset = CGSize.zero
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
			self.animationDuration = 0.0
		}
	}
	
	func makeView(_ geometry: GeometryProxy) -> some View {
		DispatchQueue.main.async { self.frameSize = geometry.size }
		return Image(nsImage: pw.showHighlightClipping ? (pw.latest?.clippedImage ?? NSImage()) : (pw.latest?.fullImage ?? NSImage()))
			.resizable()
			.offset(x: self.currentOffset.width, y: self.currentOffset.height)
			.scaleEffect(self.currentScale)
			.animation(.easeIn(duration: animationDuration))
			.gesture(
				DragGesture(minimumDistance: 0)
					.onChanged { value in
						self.clickPosition = value.location
						let deltaX = value.translation.width - self.previousOffset.width
						let deltaY = value.translation.height - self.previousOffset.height
						self.previousOffset.width = value.translation.width
						self.previousOffset.height = value.translation.height
						if(abs(previousOffset.width) > 2 || abs(previousOffset.height) > 2) {
							didDrag = true
							if(currentScale != 1.0) {
								self.currentOffset.width = self.currentOffset.width + deltaX / self.currentScale
								self.currentOffset.height = self.currentOffset.height + deltaY / self.currentScale
							}
						}
					}
					.onEnded { _ in
						if(!didDrag) {
							toggleZoom()
						}
						self.clickPosition = .zero
						self.previousOffset = CGSize.zero
						self.didDrag = false
					}
			
		)
		.aspectRatio(contentMode: .fit)
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}
	
	init(pw: PhotoWatcher) {
		self.pw = pw
	}
}

struct MainImageView_Previews: PreviewProvider {
	static var previews: some View {
		// MainImageView()
		Text("Broken!")
	}
}
