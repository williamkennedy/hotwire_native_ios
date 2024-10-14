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
                    self.heading1()
                }

            case .bold:
                webView.bold = {
                    self.bold()
                }
            case .italic:
                webView.italic = {
                    self.italic()
                }
            case .undo:
                webView.undo = {
                    self.undo()
                }
            case .redo:
                webView.redo = {
                    self.redo()
                }
            }
        }
    }

    func heading1() {
        reply(to: Event.heading1.rawValue)
    }

    func bold() {
        reply(to: Event.bold.rawValue)
    }

    func italic() {
        reply(to: Event.italic.rawValue)
    }

    func undo() {
        reply(to: Event.undo.rawValue)
    }

    func redo() {
        reply(to: Event.redo.rawValue)
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

private extension KeyboardComponent {
    struct MessageData: Codable {
        let title: String
    }
}
