import Foundation
import JavaScriptCore

let highlighterSource = """
const CodeMirror = exports;
function highlightCode(language, value) {
  const elements = [];
  let lastStyle = null;
  let tokenBuf = "";
  const pushElement = (token, style) => {
    elements.push(
      `<span${style ? ` class="cm-${style}"` : ""}>${token}</span>`
    );
  };
  CodeMirror.runMode(value, language, (token, style) => {
    if (lastStyle === style) {
      tokenBuf += token;
      lastStyle = style;
    } else {
      if (tokenBuf) {
        pushElement(tokenBuf, lastStyle);
      }
      tokenBuf = token;
      lastStyle = style;
    }
  });
  pushElement(tokenBuf, lastStyle);

  return elements.join("");
};
"""

extension JSContext {
  func setupCommonJS() {
    setObject([:], forKeyedSubscript: "exports" as NSString)
    let resolve: @convention(block) (String) -> () = { _ in }
    setObject([
      "cache": NSDictionary(),
      "resolve": JSValue(object: resolve, in: self),
    ] as [NSString: AnyHashable], forKeyedSubscript: "require" as NSString)
  }
}

public final class Vivid {
  enum Error: Swift.Error {
    case resultUnavailable
  }

  private let nodeURL: URL
  private let context = JSContext()!
  private let highlighter: JSValue
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
    context.evaluateScript(highlighterSource)
    highlighter = context.evaluateScript("highlightCode")
  }

  public func highlight(language: String, input: String) throws -> String {
    if !modes.contains(language) {
      let modePath = "/codemirror/mode/\(language)/\(language).js"
      let modeURL = nodeURL.appendingPathComponent(modePath)
      context.evaluateScript(try String(contentsOf: modeURL))
      modes.insert(language)
    }

    guard let result = highlighter.call(
      withArguments: [language, input]
    )?.toString() else { throw Error.resultUnavailable }

    return result
  }
}
