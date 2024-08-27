import SwiftUI
import UserNotifications

// Reminder data model
struct Reminder: Identifiable {
    let id = UUID()
    let text: String
    let time: Date
}

struct ContentView: View {
    @State private var reminderText: String = ""
    @State private var reminders: [Reminder] = []
    @State private var timer: Timer?
    @State private var currentTime: Date = Date() // This triggers the countdown update

    var body: some View {
        VStack {
            // Text entry field for new reminders
            TextField("Remind me about x at y", text: $reminderText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(width: 280, height: 40)
                .onSubmit {
                    addReminder(reminderText)
                    // Clear the input after adding the reminder
                    reminderText = ""
                }

            // Show the list only if there are reminders
            if !reminders.isEmpty {
                List(reminders) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.text)
                            .font(.headline)
                        Text("Due in \(countdown(to: reminder.time))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(height: 150) // Adjust height as needed
            }
        }
        .padding()
        .onAppear {
            // Start a timer to update the countdowns
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                currentTime = Date() // Update current time every second to refresh the view
                removeExpiredReminders()
            }
        }
        .onDisappear {
            // Invalidate the timer when the view is closed
            timer?.invalidate()
        }
    }

    func addReminder(_ input: String) {
        let components = input.lowercased().split(separator: " at ")
        guard components.count == 2, let time = parseTime(from: String(components[1])) else {
            print("Could not parse reminder input.")
            return
        }

        let reminder = Reminder(text: String(components[0]), time: time)
        reminders.append(reminder)
        scheduleNotification(reminderText: reminder.text, at: reminder.time)
    }

    func countdown(to date: Date) -> String {
        let timeInterval = date.timeIntervalSinceNow
        if timeInterval <= 0 {
            return "Now"
        } else {
            let hours = Int(timeInterval) / 3600
            let minutes = (Int(timeInterval) % 3600) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    func parseTime(from timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"
        formatter.timeZone = TimeZone.current

        guard let parsedTime = formatter.date(from: timeString.replacingOccurrences(of: " ", with: "").uppercased()) else {
            return nil
        }

        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current

        var components = calendar.dateComponents([.year, .month, .day], from: Date()) // Today's date
        let timeComponents = calendar.dateComponents([.hour, .minute], from: parsedTime)

        components.hour = timeComponents.hour
        components.minute = timeComponents.minute

        return calendar.date(from: components)
    }

    func scheduleNotification(reminderText: String, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = reminderText
        content.sound = UNNotificationSound(named: UNNotificationSoundName("Breeze.aiff"))

        // Add the logo to the notification
        if let logoURL = Bundle.main.url(forResource: "logo", withExtension: "png") {
            let attachment = try? UNNotificationAttachment(identifier: "logo", url: logoURL, options: nil)
            if let attachment = attachment {
                content.attachments = [attachment]
            }
        }

        let calendar = Calendar.current
        let trigger = UNCalendarNotificationTrigger(dateMatching: calendar.dateComponents([.hour, .minute], from: date), repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for: \(reminderText) at \(date)")
            }
        }
    }


    func removeExpiredReminders() {
        reminders.removeAll { $0.time <= Date() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
