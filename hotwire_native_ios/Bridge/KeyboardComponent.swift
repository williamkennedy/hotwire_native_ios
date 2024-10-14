//
//  KeyboardComponent.swift
//  hotwire_native_ios
//
//  Created by William Kennedy on 12/10/2024.
//

import Foundation
import HotwireNative
import UIKit
import WebKit

/// Bridge component to display a submit button in the native toolbar,
/// which will submit the form on the page when tapped.
final class KeyboardComponent: BridgeComponent {
    override class var name: String { "keyboard" }

    private var viewController: UIViewController? {
        delegate.destination as? UIViewController
    }

    private var webView: WKWebView? {
        delegate.webView as? CustomWebView
    }

    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else {
            return
        }

        if let webView = delegate.webView as? CustomWebView {
            switch event {
            case .focus:
                webView.toggleCustomToolbar()
            case .heading1:
                webView.heading1 = {
                    self.reply(to: Event.heading1.rawValue)
                }
            case .bold:
                webView.bold = {
                    self.reply(to: Event.bold.rawValue)
                }
            case .italic:
                webView.italic = {
                    self.reply(to: Event.italic.rawValue)
                }
            case .undo:
                webView.undo = {
                    self.reply(to: Event.undo.rawValue)
                }
            case .redo:
                webView.redo = {
                    self.reply(to: Event.redo.rawValue)
                }
            }
        }
    }
}

extension KeyboardComponent {
    enum Event: String {
        case focus
        case heading1
        case bold
        case italic
        case undo
        case redo
    }
}
