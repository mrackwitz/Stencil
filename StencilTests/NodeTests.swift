import Foundation
import XCTest
import Stencil
import CatchingFire

enum ErrorNodeError : ErrorType {
  case ExpectedError
}

class ErrorNode : Node {
  func render(context: Context) throws -> String {
    throw ErrorNodeError.ExpectedError
  }
}

class NodeTests: XCTestCase {
  var context:Context!

  override func setUp() {
    context = Context(dictionary: [
      "name": "Kyle",
      "age": 27,
      "items": [1,2,3],
      ])
  }
}

class RenderNodeTests: NodeTests {
  func testRenderingNodes() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name")] as [Node]
    AssertNoThrow {
      let result = try renderNodes(nodes, context: context)
      XCTAssertEqual(result, "Hello Kyle")
    }
  }
  
  func testRenderingNodesWithFailure() {
    let nodes = [TextNode(text:"Hello "), VariableNode(variable: "name"), ErrorNode()] as [Node]
    AssertThrows(ErrorNodeError.ExpectedError) {
      try renderNodes(nodes, context: context)
    }
  }
}
