import VividKit

let dir = #file.split(separator: "/").dropLast().joined(separator: "/")
let v: Vivid
do {
  v = try Vivid(nodePath: "\(dir)/../../node_modules")
} catch {
  fatalError(String(describing: error))
}

print(v.highlight(input: """
  public static func test() { print("blah")}
"""))
