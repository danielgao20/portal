//  TimerModalView.swift
//  Portal
//
//  Created by Daniel Gao on 5/6/25.

import SwiftUI

struct TimerModalView: View {
    @Binding var isPresented: Bool
    @State private var selectedTime = 5
    @State private var timeRemaining = 0
    @State private var timerActive = false
    let times = [5, 10, 15]
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Focus Timer")
                .font(.title2)
                .bold()
            Picker("Minutes", selection: $selectedTime) {
                ForEach(times, id: \.self) { t in
                    Text("\(t) min")
                }
            }
            .pickerStyle(.segmented)
            if timerActive {
                Text("Time Left: \(timeRemaining) s")
                    .font(.title)
            }
            HStack(spacing: 24) {
                Button(timerActive ? "Stop" : "Start") {
                    if timerActive {
                        timerActive = false
                        timeRemaining = 0
                    } else {
                        timerActive = true
                        timeRemaining = selectedTime * 60
                        startTimer()
                    }
                }
                .padding()
                .background(timerActive ? Color.red : Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                Button("Close") {
                    isPresented = false
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300)
    }
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timerActive && timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
                timerActive = false
            }
        }
    }
}

//#Preview {
//    TimerModalView(isPresented: .constant(true))
//}
