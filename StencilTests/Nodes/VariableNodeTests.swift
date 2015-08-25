import Foundation
import XCTest
import Stencil
import CatchingFire

class VariableNodeTests: NodeTests {
  func testVariableNodeResolvesVariable() {
    let node = VariableNode(variable:Variable("name"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "Kyle")
    }
  }

  func testVariableNodeResolvesNonStringVariable() {
    let node = VariableNode(variable:Variable("age"))
    AssertNoThrow {
      let string = try node.render(context)
      XCTAssertEqual(string, "27")
    }
  }
}
