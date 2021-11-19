def register(params)
  @system = params["system"]
  @source_field = params["source_field"]
  @dest_field = params["dest_field"]
  @map = params["map"]
end

def addError(level, message, stack_trace = nil)
  return {:level => level, :message => message, :stackTrace => stack_trace}
end

def filter(event)
  begin
    errors = event.get("[@metadata][errors]") || []

    codeable_concept = event.get(@source_field)
    if !codeable_concept
      errors << addError("warning", "Could not set field: " + @dest_field + " => Source field not found: " + @source_field)
    else
      concept = codeable_concept["coding"].find { |x| x["system"] == @system }
      if !concept
        errors << addError("warning", "Could not set field: " + @dest_field + " => Codeable concept not found for system: " + @system)
      else
        code = concept["code"]
        mapped = @map&.dig(code.to_s) || code
        event.set(@dest_field, mapped)
      end
    end
  rescue => e
    errors << addError("critical", e.message, e.full_message)
  end
  event.set("[@metadata][errors]", errors)
  return [event]
end