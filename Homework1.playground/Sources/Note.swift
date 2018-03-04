import Foundation
import UIKit


struct Note {
    let title: String
    let content: String
    let importance: Importance
    let uid: String
    let color: UIColor
    
    init(title: String,
         content: String,
         importance: Importance,
         uid: String = UUID().uuidString,
         color: UIColor = UIColor.white) {
        self.title = title
        self.content = content
        self.importance = importance
        self.uid = uid
        self.color = color
    }
}

extension Note {
    var json: [String: Any] {
        get {
            return ["title": self.title, "content": self.title, "importance": self.importance.rawValue, "uid": self.uid, "color": UIColorToHex(self.color)]
        }
    }
    
    func parse(json: [String: Any]) -> Note? {
        return Note(json["title"], json["content"], importance(rawValue: json["importance"]), json["uid"], HexToUIColor(json["color"]))
    }
    
    func UIColorToHex() -> String {
        let components = self.color.components
        
        let r = Float((components?[0])!)
        let g = Float((components?[1])!)
        let b = Float((components?[2])!)
        
        return String(format: "#%02lX%02lX%021lX", lround(r * 255), lround(g * 255), lround(b * 255))
    }
    
    func HexToUIColor(rgb: Int) -> UIColor {
        return UIColor(red: (rgb >> 16) & 0xFF, green: (rgb >> 8) & 0xFF, blue: rgb & 0xFF)
    }
}
