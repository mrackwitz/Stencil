public class NowNode : Node {
  public let format:Variable
  
  public class func parse(parser:TokenParser, token:Token) throws -> Node {
    var format:Variable?
    
    let components = token.components()
    if components.count == 2 {
      format = Variable(components[1])
    }
    
    return NowNode(format:format)
  }
  
  public init(format:Variable?) {
    if let format = format {
      self.format = format
    } else {
      self.format = Variable("\"yyyy-MM-dd 'at' HH:mm\"")
    }
  }
  
  public func render(context: Context) throws -> String {
    let date = NSDate()
    let format: AnyObject? = self.format.resolve(context)
    var formatter:NSDateFormatter?
    
    if let format = format as? NSDateFormatter {
      formatter = format
    } else if let format = format as? String {
      formatter = NSDateFormatter()
      formatter!.dateFormat = format
    } else {
      return ""
    }
    
    return formatter!.stringFromDate(date)
  }
}
