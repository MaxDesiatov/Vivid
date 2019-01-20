import VividKit

let input: String?
if CommandLine.arguments.count > 1 {
  input = CommandLine.arguments[1]
} else {
  var result = ""

  while let line = readLine(strippingNewline: false) {
    result.append(line)
  }

  input = String(result.dropLast())
}

guard let input = input else {
  fatalError(
    "supply code to be highlighted as a first argument or pass it to stdin"
  )
}

guard let result = try? Vivid<HTMLHighlighter>().highlight(
  language: "swift", input: input
) else {
  fatalError("failed to parse given input")
}

print(result)
