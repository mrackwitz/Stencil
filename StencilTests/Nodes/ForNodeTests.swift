import Foundation
import XCTest
import Stencil
import CatchingFire

class ForNodeTests: NodeTests {
  func testForNodeRender() {
    let node = ForNode(variable: "items", loopVariable: "item", nodes: [VariableNode(variable: "item")], emptyNodes:[])
    AssertNoThrow {
      let result = try node.render(context)
      XCTAssertEqual(result, "123")
    }
  }
}
