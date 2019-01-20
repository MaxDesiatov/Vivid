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
      "cache": [:] as NSDictionary,
      "resolve": JSValue(object: resolve, in: self)
    ] as [NSString: AnyHashable], forKeyedSubscript: "require" as NSString)
  }
}

public struct Vivid {
  let context = JSContext()!
  let highlighter: JSValue

  public init(nodePath: String) throws {
    context.setupCommonJS()
    let scriptPath = "\(nodePath)/codemirror/addon/runmode/runmode.node.js"
    let root = URL(string: "file:///")!
    let scriptURL = URL(
      fileURLWithPath: scriptPath,
      isDirectory: false,
      relativeTo: root
    )
    context.evaluateScript(try String(contentsOf: scriptURL))
    context.evaluateScript(highlighterSource)
    highlighter = context.evaluateScript("highlightCode")
  }

  public func highlight(input: String) -> String? {
    let result = highlighter.call(withArguments: ["swift", input])?.toString()
    print(context.exception)
    return result
  }
}
