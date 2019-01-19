import Foundation
import JavaScriptCore

public struct Vivid {
  let context = JSContext()!

  public init(nodePath: String) throws {
    let scriptPath = "\(nodePath)/codemirror/addon/runmode/runmode.node.js"
    context.evaluateScript(try String(contentsOf: URL(fileURLWithPath: scriptPath)))
  }

  func highlight(input: String) {}
}
