import Foundation
import XCTest
import Stencil
import CatchingFire

class SimpleNodeTests: NodeTests {
  func testSimpleNodeResolvesText() {
    let node = SimpleNode { (_) in
      return "Hello World"
    }
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Hello World")
    }
  }
}
