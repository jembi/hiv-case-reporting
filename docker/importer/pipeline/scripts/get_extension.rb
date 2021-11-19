def register(params)
  @url = params["url"]
  @type = params["type"]
  @dest_field = params["dest_field"]
  @source_field = params["source_field"]
  @fallback = params["fallback"]
end

def addError(level, message, stack_trace = nil)
  return {:level => level, :message => message, :stackTrace => stack_trace}  
end

def filter(event)
  begin
    errors = event.get("[@metadata][errors]") || []

    source = event.get(@source_field)
    extension = source.find { |x| x["url"] == @url }
    
    if !extension
      errors << addError("warning", "Extension not found: " + @url)
    end

    if !@fallback.nil?
      event.set(@dest_field, extension&.dig(@type) || @fallback)
    elsif !extension&.dig(@type).nil?
      event.set(@dest_field, extension&.dig(@type))
    end
  rescue => e
    errors << addError("critical", e.message, e.full_message)
  end
  event.set("[@metadata][errors]", errors)
  return [event]
end