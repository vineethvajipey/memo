import Foundation

struct VoiceMemo: Identifiable, Codable {
    let id: UUID
    let title: String
    let transcript: String
    let audioURL: URL
    let createdAt: Date
    
    init(id: UUID = UUID(), title: String, transcript: String, audioURL: URL, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.transcript = transcript
        self.audioURL = audioURL
        self.createdAt = createdAt
    }
} 