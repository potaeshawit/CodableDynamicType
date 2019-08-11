import Foundation

let dataJSON = """
{
    "sections": [
        {
            "type": 1,
            "items": [
                {
                    "title": "type-1-title-1",
                    "subtitle": "type-1-subtitle-1"
                }
            ]
        },
        {
            "type": 2,
            "items": [
                {
                    "title": "type-2-title-1",
                    "photo_url": "type-2-photoUrl-1"
                },
                {
                    "title": "type-2-title-2",
                    "photo_url": "type-2-photoUrl-2"
                }
            ]
        }
    ]
}
"""

// Entity
struct ArticleText: Codable {
    let title: String?
    let subtitle: String?
}

struct ArticlePhoto: Codable {
    let title: String?
    let photoUrl: String?
}

enum ArticleSection {
    case text([ArticleText])
    case photo([ArticlePhoto])
    
    enum type: Int, Codable {
        case text = 1, photo
    }
}

extension ArticleSection: Codable {
    // 1
    private enum CodingKeys: String, CodingKey {
        case type, items
    }
    
    // 2
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ArticleSection.type.self, forKey: .type)
        switch type {
        case .text:
            let items = try container.decode([ArticleText].self, forKey: .items)
            self = .text(items)
        case .photo:
            let items = try container.decode([ArticlePhoto].self, forKey: .items)
            self = .photo(items)
        }
    }
    
    // 3
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .text(let attachment):
            try container.encode(ArticleSection.type.text.rawValue, forKey: .type)
            try container.encode(attachment, forKey: .items)
        case .photo(let attachment):
            try container.encode(ArticleSection.type.photo.rawValue, forKey: .type)
            try container.encode(attachment, forKey: .items)
        }
    }
}

// Response
struct ArticleResponse: Codable {
    let sections: [ArticleSection]
}

// Decoding
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let data = dataJSON.data(using: .utf8)!
let article = try decoder.decode(ArticleResponse.self, from: data)

// Results
article.sections.forEach {
    switch $0 {
    case .text(let items):
        items.forEach {
            print("text: \($0.title ?? ""), \($0.subtitle ?? "")")
        }
    case .photo(let items):
        items.forEach {
            print("photo: \($0.title ?? ""), \($0.photoUrl ?? "")")
        }
    }
}
