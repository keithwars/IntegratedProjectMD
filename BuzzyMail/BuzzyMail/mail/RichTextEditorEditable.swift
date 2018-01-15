//
//  RichTextEditorEditable.swift
//  BuzzyMail
//
//  Created by Jérémy Keusters on 8/12/17.
//  Copyright © 2017 Jérémy Keusters. All rights reserved.
//

import Foundation
import WebKit

public protocol RichTextEditorEditableDelegate: class {
    func textDidChange(text: String)
    func heightDidChange()
}

fileprivate class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

public class RichTextEditorEditable: UIView, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {
    
    private static let textDidChange = "textDidChange"
    private static let heightDidChange = "heightDidChange"
    private static let defaultHeight: CGFloat = 60
    
    public weak var delegate: RichTextEditorEditableDelegate?
    public var height: CGFloat = RichTextEditorEditable.defaultHeight
    
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    private var textToLoad: String?
    public var text: String? {
        didSet {
            guard let text = text else { return }
            updatedText = text
            if editorView.isLoading {
                textToLoad = text
            } else {
                editorView.evaluateJavaScript("richeditor.insertText(\"\(text.htmlEscapeQuotes)\");", completionHandler: nil)
                placeholderLabel.isHidden = !text.htmlToPlainText.isEmpty
            }
        }
    }
    public var updatedText: String?
    
    private var editorView: WKWebView!
    private let placeholderLabel = UILabel()


    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        placeholderLabel.textColor = UIColor.lightGray.withAlphaComponent(0.65)
        
        guard let bundlePath = Bundle(for: type(of: self)).path(forResource: "Resources", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath),
            let scriptPath = bundle.path(forResource: "RichTextEditor", ofType: "js"),
            let scriptContent = try? String(contentsOfFile: scriptPath, encoding: String.Encoding.utf8),
            let htmlPath = bundle.path(forResource: "RichTextEditorEditable", ofType: "html"),
            let html = try? String(contentsOfFile: htmlPath, encoding: String.Encoding.utf8)
            else { fatalError("Unable to find javscript/html for text editor") }
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addUserScript(
            WKUserScript(source: scriptContent,
                         injectionTime: .atDocumentEnd,
                         forMainFrameOnly: true
            )
        )
        
        editorView = WKWebView(frame: .zero, configuration: configuration)
        
        
        //super.init(frame: frame)
        
        [RichTextEditorEditable.textDidChange, RichTextEditorEditable.heightDidChange].forEach {
            configuration.userContentController.add(WeakScriptMessageHandler(delegate: self), name: $0)
        }
        
        editorView.navigationDelegate = self
        editorView.isOpaque = false
        editorView.backgroundColor = .clear
        editorView.scrollView.isScrollEnabled = true
        editorView.scrollView.showsHorizontalScrollIndicator = false
        editorView.scrollView.showsVerticalScrollIndicator = true
        editorView.scrollView.bounces = false
        editorView.scrollView.delegate = self
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        addSubview(editorView)
        editorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            editorView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            editorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            editorView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        editorView.loadHTMLString(html, baseURL: nil)
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case RichTextEditorEditable.textDidChange:
            guard let body = message.body as? String else { return }
            placeholderLabel.isHidden = !body.htmlToPlainText.isEmpty
            delegate?.textDidChange(text: body)
            updatedText = body
        case RichTextEditorEditable.heightDidChange:
            guard let height = message.body as? CGFloat else { return }
            self.height = height > RichTextEditorEditable.defaultHeight ? height + 30 : RichTextEditorEditable.defaultHeight
            delegate?.heightDidChange()
        default:
            break
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let textToLoad = textToLoad {
            self.textToLoad = nil
            text = textToLoad
        }
    }
    
    public func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }
}

fileprivate extension String {
    
    var htmlToPlainText: String {
        return [
            ("(<[^>]*>)|(&\\w+;)", " "),
            ("[ ]+", " ")
            ].reduce(self) {
                try! $0.replacing(pattern: $1.0, with: $1.1)
            }.resolvedHTMLEntities
    }
    
    var resolvedHTMLEntities: String {
        return self
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
    }
    
    func replacing(pattern: String, with template: String) throws -> String {
        let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSRange(0..<self.utf16.count), withTemplate: template)
    }
    
    var htmlEscapeQuotes: String {
        return [
            ("\"", "\\\""),
            ("“", "&quot;"),
            ("\r", "\\r"),
            ("\n", "\\n")
            ].reduce(self) {
                return $0.replacingOccurrences(of: $1.0, with: $1.1)
        }
    }
}
