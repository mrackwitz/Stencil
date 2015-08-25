public class ForNode : Node {
  let variable:Variable
  let loopVariable:String
  let nodes:[Node]
  
  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let components = token.components()
    
    guard components.count == 4 && components[2] == "in" else {
      throw ParseError(cause: .InvalidForSyntax, token: token, message: "Invalid syntax. Expected `for x in y`.")
    }
    
    let loopVariable = components[1]
    let variable = components[3]
    
    let forNodes = try parser.parse(until(["endfor", "empty"]))
    
    var emptyNodes: [Node] = [Node]()
    if let token = parser.nextToken() {
      if token.contents == "empty" {
        emptyNodes = try parser.parse(until(["endfor"]))
        parser.nextToken()
      }
    } else {
      throw ParseError(cause: .MissingEnd, token: token, message: "`endfor` was not found.")
    }
    
    return ForNode(variable: variable, loopVariable: loopVariable, nodes: forNodes, emptyNodes:emptyNodes)
  }
  
  public init(variable:String, loopVariable:String, nodes:[Node], emptyNodes:[Node]) {
    self.variable = Variable(variable)
    self.loopVariable = loopVariable
    self.nodes = nodes
  }
  
  public func render(context: Context) throws -> String {
    let values = variable.resolve(context) as? [AnyObject]
    var output = ""
    
    if let values = values {
      for item in values {
        context.push()
        context[loopVariable] = item
        output += try renderNodes(nodes, context: context)
        context.pop()
      }
    }
    
    return output
  }
}
