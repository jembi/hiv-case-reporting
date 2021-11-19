def register(params)
  @map = params["map"]
  @source_field = params["source_field"]
  @dest_field = params["dest_field"]
end

def addError(level, message, stack_trace = nil)
  return {:level => level, :message => message, :stackTrace => stack_trace}  
end

def get_value(field, event)
  codeable_concept = event.get(field)
  concept = codeable_concept&.dig("coding")&.find { |x| @map[x["code"]] != nil }
  return @map[concept&.dig("code")]
end

def filter(event)
  begin
    errors = event.get("[@metadata][errors]") || []

    value = @source_field.split(",").map{|field| get_value(field, event)}
                  .find{|x|!x.nil?}

    if !value
      errors << addError("warning", "Matching codeable concept not found for fields: " + @source_field)
    end
    
    event.set(@dest_field,  value)
  rescue => e
    errors << addError("critical", e.message, e.full_message)
  end
  event.set("[@metadata][errors]", errors)
  return [event]
end