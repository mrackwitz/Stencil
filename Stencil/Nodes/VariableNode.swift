public class VariableNode : Node {
  public let variable:Variable
  
  public init(variable:Variable) {
    self.variable = variable
  }
  
  public init(variable:String) {
    self.variable = Variable(variable)
  }
  
  public func render(context:Context) throws -> String {
    let result:AnyObject? = variable.resolve(context)
    
    if let result = result as? String {
      return result
    } else if let result = result as? NSObject {
      return result.description
    }
    
    return ""
  }
}
