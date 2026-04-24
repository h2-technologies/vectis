//
//  SystemVolumeSlider.swift
//  vectis
//
//  Created by Samuel Valencia on 4/23/26.
//

import SwiftUI
import MediaPlayer

struct SystemVolumeSlider: UIViewRepresentable {
	func makeUIView(context: Context) -> MPVolumeView {
		let volumeView = MPVolumeView(frame: .zero)
		volumeView.showsRouteButton = false
		
		if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
			slider.setThumbImage(UIImage(), for: .normal)
			slider.setThumbImage(UIImage(), for: .highlighted)
			
			let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDrag(_:)))
			slider.addGestureRecognizer(panGesture)
			
		}
		
		return volumeView
	}
	
	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
	
	class Coordinator: NSObject {
		@objc func handleDrag(_ gesture: UIPanGestureRecognizer) {
			guard let slider = gesture.view as? UISlider else { return }
			let location = gesture.location(in: slider)
			let percentage = Float(max(0, min(location.x / slider.bounds.width, 1.0)))
			
			slider.setValue(percentage, animated: false)
			slider.sendActions(for: .valueChanged) // Updates hardware volume
		}
	}
	
	func updateUIView(_ uiView: MPVolumeView, context: Context) {}
	
}
