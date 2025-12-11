//
//  PinAnimation.swift
//  RemotEye
//
//  Created by AFP PAR 29 on 09/12/25.
//

import UIKit
import MapKit

final class PinAnimation {

    static func playUnlockAnimation(on view: MKAnnotationView) {
        
        // Glow ring
        let ring = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        ring.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
        ring.layer.cornerRadius = 5
        ring.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.4)
        view.addSubview(ring)
        view.bringSubviewToFront(ring)

        UIView.animate(withDuration: 0.3, animations: {
            ring.transform = CGAffineTransform(scaleX: 6, y: 6)
            ring.alpha = 0
        }) { _ in
            ring.removeFromSuperview()
        }

        // Pop animation
        UIView.animate(withDuration: 0.15, animations: {
            view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                view.transform = CGAffineTransform.identity
            }
        }
    }
}
