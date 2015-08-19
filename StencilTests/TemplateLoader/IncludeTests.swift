import Foundation
import XCTest
import Stencil
import PathKit
import CatchingFire

class IncludeTests: NodeTests {

  var loader:TemplateLoader!

  override func setUp() {
    super.setUp()

    let path = (Path(__FILE__) + Path("../..")).absolute()
    loader = TemplateLoader(paths: [path])
  }

  // MARK: Parsing

  func testParseMissingTemplate() {
    let tokens = [ Token.Block(value: "include") ]
    let parser = TokenParser(tokens: tokens)
    
    AssertThrows(ParseError(cause: .InvalidArgumentCount, token: tokens[0], message: "Tag takes one argument, the template file to be included")) {
      try parser.parse()
    }
  }

  func testParse() {
    let tokens = [ Token.Block(value: "include \"test.html\"") ]
    let parser = TokenParser(tokens: tokens)

    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
      let node = nodes.first as! IncludeNode
      XCTAssertEqual(node.templateName, "test.html")
    }
  }
  
  func testParseWithTransformer() {
    let tokens = [ Token.Block(value: "include \"test.html\" | trim") ]
    let parser = TokenParser(tokens: tokens)
    
    AssertNoThrow {
      let nodes = try parser.parse()
      XCTAssertEqual(nodes.count, 1)
      let node = nodes.first as! IncludeNode
      XCTAssertEqual(node.templateName, "test.html")
      XCTAssertEqual(node.transformers.count, 1)
    }
  }

  // MARK: Render

  func testRenderWithoutLoader() {
    let node = IncludeNode(templateName: "test.html")
    AssertThrows(RenderError.TemplateLoaderNotInContext) {
      try node.render(Context())
    }
  }

  func testRenderWithoutTemplateNamed() {
    let node = IncludeNode(templateName: "unknown.html")
    
    AssertThrows(RenderError.TemplateNotFound(name: "Template 'unknown.html' not found", paths: [])) {
      try node.render(Context(dictionary:["loader":loader]))
    }
  }

  func testRender() {
    let node = IncludeNode(templateName: "test.html")
    
    AssertNoThrow {
      let string = try node.render(Context(dictionary:["loader":loader, "target": "World"]))
      XCTAssertEqual(string, "\nHello World!\n")
    }
  }
  
  func testRenderTrimmed() {
    let node = IncludeNode(templateName: "test.html", transformers: [Transformer.trim()])
    
    AssertNoThrow {
      let string = try node.render(Context(dictionary:["loader":loader, "target": "World"]))
      XCTAssertEqual(string, "Hello World!")
    }
  }

}
