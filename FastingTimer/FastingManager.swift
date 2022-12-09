import Foundation

enum FastingState {
		case notStarted
		case fasting
		case feeding
}

enum FastingPlan:String {
		case beginner = "12:12"
		case intermediate = "16:8"
		case advance = "20:4"
		
		var fastingPeriod: Double {
				switch self {
				case .beginner:
						return 12
				case .intermediate:
						return 16
				case .advance:
						return 20
				}
		}
}

class FastingManager: ObservableObject {
		@Published private(set) var fastingState: FastingState = .notStarted
		@Published private(set) var fastingPlan: FastingPlan = .intermediate
		@Published private(set) var startTime: Date {
				didSet {
						print("start time: ", startTime.formatted(.dateTime.month().day().hour().minute().second()))
						if fastingState == .fasting {
								endTime = startTime.addingTimeInterval(fastingTime)
						} else {
								endTime = startTime.addingTimeInterval(feedingTime)
						}
				}
		}
		@Published private(set) var endTime: Date {
				didSet {
						print("end time: ", endTime.formatted(.dateTime.month().day().hour().minute().second()))
				}
		}
		@Published private(set) var elapsed = false
		@Published private(set) var elapsedTime: Double = 0.0
		@Published private(set) var progress: Double = 0.0
		
		var fastingTime: Double {
				return fastingPlan.fastingPeriod * 60 * 60
		}
		
		var feedingTime: Double {
				return (24 - fastingPlan.fastingPeriod) * 60 * 60
		}
		
		init() {
				let calendar = Calendar.current
				//				var components = calendar.dateComponents([.year, .month, .day, .hour], from: Date())
				//				components.hour = 20
				//				print(components)
				//
				//				let scheduleTime = calendar.date(from: components) ?? Date.now
				//				print("schedule time: ", scheduleTime.formatted(.dateTime.month().day().hour().minute().second()))
				
				let components = DateComponents(hour: 20)
				let scheduleTime = calendar.nextDate(after: .now, matching: components, matchingPolicy: .nextTime) ?? .now
				
				print("schedule time: ", scheduleTime.formatted(.dateTime.month().day().hour().minute().second()))
				
				startTime = scheduleTime
				endTime = scheduleTime.addingTimeInterval(FastingPlan.intermediate.fastingPeriod * 60 * 60)
		}
		
		func toggleFastingState() {
				fastingState = fastingState == .fasting ? .feeding : .fasting
				startTime = Date()
				elapsedTime = 0.0
		}
		
		func track() {
				guard fastingState != .notStarted else {return}
				if endTime >= Date() {
						elapsed = false
				} else {
						elapsed = true
				}
				elapsedTime += 1
				print("Elapsed Time: ", elapsedTime)
				let totalTime = fastingState == .fasting ? fastingTime : feedingTime
				progress = (elapsedTime / totalTime * 100).rounded() / 100
				print("Progress Time: ", progress)
		}
}
