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
}

class ViewController: UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    
    var myEmojis: [EmojiImage] = {
        guard let data = UIImage(named: "me")?.pngData() else {
            fatalError()
        }
        let image = EmojiImage(name: ":me:", data: data, lineHeight: 20)
        return [image]
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
