public class TextNode : Node {
  public let text:String
  
  public init(text:String) {
    self.text = text
  }
  
  public func render(context:Context) throws -> String {
    return self.text
  }
}
