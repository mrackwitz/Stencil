import Foundation
import XCTest
import Stencil
import CatchingFire

class TextNodeTests: NodeTests {
  func testTextNodeResolvesText() {
    let node = TextNode(text:"Hello World")
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Hello World")
    }
  }
}
