//
//  ContentView.swift
//  BetterRest
//
//  Created by Maxim P on 28/02/2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("When do you want to wake up?")) {
                    DatePicker("PLease enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                }
                
                Section(header: Text("Desired amount of sleep")) {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                VStack(alignment: .leading, content: {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                })
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Ok"){}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
            do {
                let config = MLModelConfiguration()
                let model = try BetterRest(configuration: config)
                
                let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
                let hour = (components.hour ?? 0) * 60 * 60
                let minute = (components.minute ?? 0) * 60
                
                let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                
                alertTitle = "Your ideal bedtime is..."
                alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
                
            } catch {
                alertTitle = "Error"
                alertMessage = "Sorry, there was a problem caclculating your bedtime"
            }
        showingAlert = true
        }
}

#Preview {
    ContentView()
}
