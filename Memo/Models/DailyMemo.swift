import Foundation
import SwiftUI

struct DailyMemo: Identifiable, Codable {
    let id: UUID
    let title: String
    let transcript: String
    let audioURL: URL
    let createdAt: Date
    let mood: Mood // Optional: Add mood tracking
    
    enum Mood: String, Codable, CaseIterable {
        case great = "Great"
        case good = "Good"
        case okay = "Okay"
        case bad = "Bad"
        
        var icon: String {
            switch self {
            case .great: return "star.fill"
            case .good: return "sun.max.fill"
            case .okay: return "cloud.fill"
            case .bad: return "cloud.rain.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .great: return .yellow
            case .good: return .orange
            case .okay: return .blue
            case .bad: return .gray
            }
        }
    }
    
    init(id: UUID = UUID(), title: String, transcript: String, audioURL: URL, createdAt: Date = Date(), mood: Mood = .okay) {
        self.id = id
        self.title = title
        self.transcript = transcript
        self.audioURL = audioURL
        self.createdAt = createdAt
        self.mood = mood
    }
} 