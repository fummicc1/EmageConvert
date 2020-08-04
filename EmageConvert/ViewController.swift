//
//  ViewController.swift
//  EmageConvert
//
//  Created by Fumiya Tanaka on 2020/07/30.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit

struct EmojiImage: Codable {
    let name: String
    let data: Data
    let lineHeight: CGFloat
    
    func convertDataToText() -> NSAttributedString {
        let attachment = NSTextAttachment()
        let image = UIImage(data: data)!
        attachment.image = image
        
        let k = image.size.height / lineHeight

        attachment.bounds = CGRect(x: 0, y: -5, width: image.size.width / k, height: lineHeight)

        let text = NSAttributedString(attachment: attachment)
        return text
    }
    
    init?(name: String, image: UIImage?, lineHeight: CGFloat = 16) {
        guard let imageData = image?.pngData() else {
            return nil
        }
        self.name = name
        self.data = imageData
        self.lineHeight = lineHeight
    }
    
    init(name: String, data: Data, lineHeight: CGFloat = 16) {
        self.name = name
        self.data = data
        self.lineHeight = lineHeight
    }
}

class ViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    
    var myEmojis: [EmojiImage] = {
        var emojis: [EmojiImage] = []
        if let data = UIImage(named: "me")?.pngData() {
            let meImage = EmojiImage(name: ":me:", data: data, lineHeight: 20)
            emojis.append(meImage)
        }
        if let swiftImage = EmojiImage(name: ":me:", image: UIImage(named: "swift"), lineHeight: 20) {
            emojis.append(swiftImage)
        }
        return emojis
    }()
    
    var token: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handle(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
}

extension ViewController {
    @objc
    func handle(_ notification: Notification) {
        guard let textView = notification.object as? UITextView, let text = textView.text, let textFieldAttributedString = textView.attributedText else {
            return
        }
        for emoji in myEmojis {
            guard let expression = try? NSRegularExpression(pattern: ":\(emoji.name):") else {
                continue
            }
            let currentAttributedString = NSMutableAttributedString(string: text)
            let matches = expression.matches(in: text, range: NSRange(location: 0, length: text.count))
            if matches.isEmpty {
                continue
            }
            for match in matches.reversed() {
                guard let image = UIImage(data: emoji.data) else {
                    continue
                }
                let attachment = NSTextAttachment()
                attachment.image = image
                attachment.bounds = CGRect(x: 0, y: -5, width: image.size.width / image.size.height * emoji.lineHeight, height: emoji.lineHeight)
                let imageAttributeString = NSAttributedString(attachment: attachment)
                currentAttributedString.replaceCharacters(in: match.range, with: imageAttributeString)
                currentAttributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: emoji.lineHeight), range: NSRange(location: 0, length: currentAttributedString.length))
                textView.attributedText = currentAttributedString
            }
        }
        if let emoji = myEmojis.first(where: { text.contains($0.name) }), let range = text.range(of: emoji.name) {
            let nsRange = NSRange(range, in: text)
            let attributedString = NSMutableAttributedString(attributedString: textFieldAttributedString)
            let mutableString = NSMutableAttributedString()
            mutableString.append(emoji.convertDataToText())
            attributedString.replaceCharacters(in: nsRange, with: mutableString)
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 20), range: NSRange(location: 0, length: attributedString.length))
            textView.attributedText = attributedString
        }
    }
}
