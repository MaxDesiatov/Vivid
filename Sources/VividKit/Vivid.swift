import Foundation
import JavaScriptCore

extension JSContext {
  func setupCommonJS() {
    setObject([:], forKeyedSubscript: "exports" as NSString)
    let resolve: @convention(block) (String) -> () = { _ in }
    setObject([
      "cache": NSDictionary(),
      "resolve": JSValue(object: resolve, in: self),
    ] as NSDictionary, forKeyedSubscript: "require" as NSString)
  }
}

public protocol Highlighter {
  associatedtype Result

  init()

  mutating func consume(token: String, style: String?)
  mutating func finalize()

  var result: Result { get }
}

public struct HTMLHighlighter: Highlighter {
  private var tokenBuffer = ""
  private var lastStyle: String?

  public var result = ""

  public init() {}

  public mutating func finalize() {
    if let styleString = lastStyle.flatMap({ " class=\"cm-\($0)\"" }) {
      result.append("<span\(styleString)>\(tokenBuffer)</span>")
    } else {
      result.append(tokenBuffer)
    }
  }

  public mutating func consume(token: String, style: String?) {
    let token = CFXMLCreateStringByEscapingEntities(
      nil, token as CFString, nil
    ) as String
    if lastStyle == style {
      tokenBuffer.append(token)
    } else {
      if !tokenBuffer.isEmpty {
        finalize()
      }
      tokenBuffer = token
      lastStyle = style
    }
  }
}

public final class Vivid<T: Highlighter> {
  enum Error: Swift.Error {
    case resultUnavailable
  }

  private let nodeURL: URL
  private let context = JSContext()!
  private let runMode: JSValue
  private var modes = Set<String>()

  public convenience init() throws {
    let dir = #file.split(separator: "/").dropLast().joined(separator: "/")

    try self.init(nodePath: "\(dir)/../../node_modules")
  }

  public init(nodePath: String) throws {
    let root = URL(string: "file:///")!
    nodeURL = URL(
      fileURLWithPath: nodePath,
      isDirectory: false,
      relativeTo: root
    )

    context.setupCommonJS()
    let scriptPath = "/codemirror/addon/runmode/runmode.node.js"
    let scriptURL = nodeURL.appendingPathComponent(scriptPath)
    context.evaluateScript(try String(contentsOf: scriptURL))
    context.evaluateScript("const CodeMirror = exports")
    runMode = context.evaluateScript("CodeMirror.runMode")
  }

  public func highlight(language: String, input: String) throws -> T.Result {
    if !modes.contains(language) {
      let modePath = "/codemirror/mode/\(language)/\(language).js"
      let modeURL = nodeURL.appendingPathComponent(modePath)
      context.evaluateScript(try String(contentsOf: modeURL))
      modes.insert(language)
    }

    var highlighter = T()

    let bridgedConsume: @convention(block) (String, String) -> () = {
      let style = ["null", "undefined"].contains($1) ? nil : $1
      highlighter.consume(token: $0, style: style)
    }

    runMode.call(withArguments: [
      input, language, JSValue(object: bridgedConsume, in: context),
    ])
    highlighter.finalize()

    return highlighter.result
  }
}
