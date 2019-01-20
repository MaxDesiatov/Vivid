@testable import VividKit
import XCTest

private let input = """
  public func test() -> Int {
    return 42
  }
"""

private let result = """
  <span class="cm-keyword">public</span> <span class="cm-keyword">func</span> \
<span class="cm-def">test</span><span class="cm-punctuation">()</span> \
<span class="cm-operator">-&gt;</span> <span class="cm-variable-2">Int</span> \
<span class="cm-punctuation">{</span>
    <span class="cm-keyword">return</span> <span class="cm-number">42</span>
  <span class="cm-punctuation">}</span>
"""

private let spanInput = """
public func test(style: String) -> String {
  return "<span class=\\"cm-\\(style)\\">"
}
"""

private let spanInputResult = """
<span class="cm-keyword">public</span> <span class="cm-keyword">func</span> \
<span class="cm-def">test</span><span class="cm-punctuation">(</span>\
<span class="cm-variable">style</span><span class="cm-punctuation">:</span> \
<span class="cm-variable-2">String</span><span class="cm-punctuation">)</span> \
<span class="cm-operator">-&gt;</span> <span class="cm-variable-2">String\
</span> <span class="cm-punctuation">{</span>
  <span class="cm-keyword">return</span> <span class="cm-string">&quot;&lt;\
span class=\\&quot;</span><span class="cm-variable">cm</span>\
<span class="cm-operator">-</span>\\<span class="cm-punctuation">(</span>\
<span class="cm-variable">style</span><span class="cm-punctuation">)</span>\\\
<span class="cm-string">&quot;&gt;&quot;</span>
<span class="cm-punctuation">}</span>
"""

final class VividTests: XCTestCase {
  func testSimple() throws {
    let vivid = try Vivid<HTMLHighlighter>()
    XCTAssertEqual(try vivid.highlight(language: "swift", input: input), result)
  }

  func testSpan() throws {
    let vivid = try Vivid<HTMLHighlighter>()
    XCTAssertEqual(
      try vivid.highlight(language: "swift", input: spanInput),
      spanInputResult
    )
  }

  static var allTests = [
    ("testSimple", testSimple),
    ("testSpan", testSpan),
  ]
}
