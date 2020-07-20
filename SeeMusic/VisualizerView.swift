//
//  VisualizerView.swift
//  SeeMusic
//
//  Created by brett ohland on 2020-07-19.
//  Copyright © 2020 brett ohland. All rights reserved.
//

import AudioCaptureKit
import CoreMotion
import SwiftUI

let numberOfSamples: Int = 55

struct VisualizerView: View {
    @ObservedObject private var mic = try! AudioCaptureKit.MicMonitor(numberOfSamples: numberOfSamples, recorder: nil)

    @State private var recordBegin = false
    @State private var recording = false {
        didSet {
            switch self.recording {
            case true:
                self.mic.startMonitoring()
            case false:
                self.mic.stopMonitoring()
            }
        }
    }

    let motionManager = CMMotionManager()
    let queue = OperationQueue()

    private func normalizeSoundLevel(level: Float) -> CGFloat {
        let level = max(0.2, CGFloat(level) + 50) / 2 // between 0.1 and 25
        return CGFloat(level * (400 / 25)) // scaled to max at 400 (our height of our bar)
    }

    private func normalize(min: Double, max: Double, value: Double) -> Double {
        let normalized = (value - min) / (max - min)
        return normalized
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(red: 233/255, green: 235/255, blue: 234/255).edgesIgnoringSafeArea(.all)
                Group {
                    VStack(spacing: 3) {
                        ForEach(
                            mic.soundSamples, id: \.self
                        ) { level in
                            VerticalBarView(
                                value: self.normalizeSoundLevel(level: level),
                                opacity: 1.0,
                                colors: (
                                    Color(red: 57/255, green: 126/255, blue: 168/255),
                                    Color(red: 105/255, green: 133/255, blue: 138/255)
                                )
                            )
                        }
                    }.animation(.default)
                }
            }

            ZStack {
                Color(red: 19/255, green: 24/255, blue: 27/255).edgesIgnoringSafeArea(.bottom)
                RoundedRectangle(cornerRadius: recordBegin ? 30 : 5)
                    .frame(width: recordBegin ? 330 : 350, height: 60)
                    .foregroundColor(recordBegin ? Color(red: 252/255, green: 66/255, blue: 131/255) : .green)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .font(.system(.title))
                            .foregroundColor(.white)
                            .scaleEffect(recording ? 0.8 : 1)
                    )
                RoundedRectangle(cornerRadius: recordBegin ? 35 : 10)
                    .trim(from: 0, to: recordBegin ? 0 : 1)
                    .stroke(lineWidth: 3)
                    .frame(width: recordBegin ? 340 : 360, height: 70)
                    .foregroundColor(.green)
            }
            .frame(width: UIScreen.main.bounds.width, height: 100, alignment: .center)
            .onTapGesture {
                withAnimation(Animation.spring()) {
                    self.recordBegin.toggle()
                }

                withAnimation(Animation.spring().repeatForever().delay(0.5)) {
                    self.recording.toggle()
                }
            }
        }
    }
}

struct VisualizerView_Previews: PreviewProvider {
    static var previews: some View {
        VisualizerView()
    }
}

struct VerticalBarView: View {
    var value: CGFloat
    var opacity: Double
    var colors: (Color, Color)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [colors.0, colors.1]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(self.opacity)
                .frame(
                    width: value,
                    height: (760 - CGFloat(numberOfSamples) * 4) / CGFloat(numberOfSamples)
                )
        }
    }
}
