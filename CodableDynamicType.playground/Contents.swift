import Foundation

let data = """
{
    "sections": [
        {
            "type": 1,
            "items": [
                {
                    "title": "type-one-title-1",
                    "photo_url": "type-one-photoUrl-1"
                },
                {
                    "title": "type-one-title-2",
                    "photo_url": "type-one-photoUrl-2"
                },
            ]
        },
        {
            "type": 2,
            "items": [
                {
                    "title": "type-one-title-1",
                    "subtitle": "type-one-subtitle-1"
                },
                {
                    "title": "type-one-title-2",
                    "subtitle": "type-one-subtitle-2"
                },
            ]
        },
    ]
}
"""

// ----------------------------------------------------------
// Entity

struct ArticleSimplePhoto: Codable {
    let title: String?
    let photoUrl: String?
}

struct ArticleSimpleText: Codable {
    let title: String?
    let subtitle: String?
}

// ----------------------------------------------------------
// ArticleSection
enum ArticleSection {
    case simplePhoto([ArticleSimplePhoto])
    case simpleText([ArticleSimpleText])
    
    enum type: Int, Codable {
        case simplePhoto = 1, simpleText
    }
}

extension ArticleSection: Codable {
    private enum CodingKeys: String, CodingKey {
        case type, items
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ArticleSection.type.self, forKey: .type)
        
        switch type {
        case .simpleText:
            let items = try container.decode([ArticleSimpleText].self, forKey: .items)
            self = .simpleText(items)
        case .simplePhoto:
            let items = try container.decode([ArticleSimplePhoto].self, forKey: .items)
            self = .simplePhoto(items)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .simpleText(let attachment):
            try container.encode(ArticleSection.type.simpleText.rawValue, forKey: .type)
            try container.encode(attachment, forKey: .items)
        case .simplePhoto(let attachment):
            try container.encode(ArticleSection.type.simplePhoto.rawValue, forKey: .type)
            try container.encode(attachment, forKey: .items)
        }
    }
}

// ----------------------------------------------------------
// Response

struct ArticleResponse: Codable {
    let sections: [ArticleSection]
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let article = try decoder.decode(ArticleResponse.self, from: data.data(using: .utf8)!)

article.sections.forEach {
    switch $0 {
    case .simpleText(let items):
        items.forEach { print($0) }
    case .simplePhoto(let items):
        items.forEach { print($0) }
    }
}
