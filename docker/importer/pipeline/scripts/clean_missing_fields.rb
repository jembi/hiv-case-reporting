def register(params)
  @root = params["root"]
end

def addError(level, message, stack_trace = nil)
  error = {:level => level, :message => message, :stackTrace => stack_trace}
  $errors << error
end

def cleanField(path)
  field = $event.get(path)
  if field.is_a?(String) && field&.include?("%{")
    $event.remove(path)
    addError("warning", "Missing field: " + path)    
  end
end

def iterateHash(currHash, path)
  currHash&.each{|key, value|
    currPath = "#{path}[#{key}]"
    value.is_a?(Hash) ? iterateHash(value, currPath) : cleanField(currPath)
  }
end

def filter(event)
  begin
    $errors = event.get("[@metadata][errors]") || []
    $event = event

    root = event.get(@root)
    iterateHash(root, @root)
  rescue => e
    addError("critical", e.message, e.full_message)
  end
  $event.set("[@metadata][errors]", $errors)
  return [event]
end