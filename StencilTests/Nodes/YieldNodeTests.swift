import Foundation
import XCTest
@testable import Stencil
import CatchingFire

class YieldNodeTests: NodeTests {
  
  // MARK: Parsing
  
  func testParseBind() {
    let tokens = [
      Token.Block(value: "yield"),
    ]
    
    let parser = TokenParser(tokens: tokens)
    AssertNoThrow {
      let nodes = try parser.parse()
      
      XCTAssertEqual(nodes.count, 1)
      XCTAssertTrue(nodes.first! is YieldNode)
    }
  }
  
  // MARK: Rendering
  
  func testYieldRender() {
    let node = YieldNode()
    let closure = { (context: Context) in
      return String(context["age"] as! Int)
    }
    
    AssertNoThrow {
      context.push([
        "block": Box(closure)
      ])
      let string = try node.render(context)
      XCTAssertEqual(string, "27")
    }
  }
  
  func testYieldRenderWithoutBlock() {
    let node = YieldNode()
    
    AssertThrows(Template.Error.NoBlockInContext) {
      try node.render(context)
    }
  }
  
  // MARK: Template Rendering
  
  func testYieldTemplate() {
    let template = Template(templateString: "{% yield %}")
    AssertNoThrow {
      let result = try template.call(context) { (_) in
        return "Hello World"
      }
      XCTAssertEqual(result, "Hello World")
    }
  }
  
}
