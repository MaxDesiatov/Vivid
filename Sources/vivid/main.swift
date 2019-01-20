import VividKit

let v = try! Vivid()

print(try! v.highlight(language: "swift", input: """
public static func test() { print("\\(1 + 3) test")}
"""))
