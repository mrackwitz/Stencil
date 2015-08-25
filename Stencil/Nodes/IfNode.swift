public class IfNode : Node {
  public let variable:Variable
  public let trueNodes:[Node]
  public let falseNodes:[Node]
  
  class func parse(parser:TokenParser, token:Token) throws -> (variable: String, ifNodes: [Node], elseNodes: [Node]) {
    let variable = token.components()[1]
    
    let ifNodes = try parser.parse(until(["endif", "else"]))
    var elseNodes = [Node]()
    
    if let token = parser.nextToken() {
      if token.contents == "else" {
        elseNodes = try parser.parse(until(["endif"]))
        parser.nextToken()
      }
    } else {
      throw ParseError(cause: .MissingEnd, token: token, message: "`endif` was not found.")
    }
    
    return (variable, ifNodes, elseNodes)
  }
  
  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    let (variable, ifNodes, elseNodes) = try parse(parser, token: token)
    return IfNode(variable: variable, trueNodes: ifNodes, falseNodes: elseNodes)
  }
  
  public class func parseIfNot(parser:TokenParser, token:Token) throws -> Node {
    let (variable, ifNodes, elseNodes) = try parse(parser, token: token)
    return IfNode(variable: variable, trueNodes: elseNodes, falseNodes: ifNodes)
  }
  
  public init(variable:String, trueNodes:[Node], falseNodes:[Node]) {
    self.variable = Variable(variable)
    self.trueNodes = trueNodes
    self.falseNodes = falseNodes
  }
  
  public func render(context: Context) throws -> String {
    let result: AnyObject? = variable.resolve(context)
    var truthy = false
    
    if let result = result as? [AnyObject] where result.count > 0 {
      truthy = true
    } else if let _: AnyObject = result {
      truthy = true
    }
    
    context.push()
    let output = try renderNodes(truthy ? trueNodes : falseNodes, context: context)
    context.pop()
    
    return output
  }
}
