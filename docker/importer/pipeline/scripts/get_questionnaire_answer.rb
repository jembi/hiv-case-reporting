def register(params)
  @link_id = params["link_id"]
  @type = params["type"]
  @dest_field = params["dest_field"]
  @map = params["map"]
end

def addError(level, message, stack_trace = nil)
  return {:level => level, :message => message, :stackTrace => stack_trace}  
end

def filter(event)
  begin
    errors = event.get("[@metadata][errors]") || []

    rootItems = event.get("[resource][item]")
    steps = @link_id.split(".")
    currItems = rootItems
    
    for i in 0..steps.length()-1
      currStep = steps.take(i + 1).join(".")
      currItem = currItems.find { |x| x["linkId"] == currStep }
      if !currItem
        errors << addError("warning", "Could not set field: " + @dest_field + " => linkID not found: " + @link_id)
        break
      end
      currAnswer = currItem&.dig("answer", 0)
      if currItem["item"]&.any?
        currItems = currItem["item"]
      elsif currAnswer&.dig("item")&.any?
        currItems = currAnswer["item"]
      else
        break
      end
    end
    
    answer = currAnswer&.dig(@type)
    mapped = @map&.dig(answer.to_s) || answer
    event.set(@dest_field, mapped)
  rescue => e
    addError("critical", e.message, e.full_message)
  end
  event.set("[@metadata][errors]", errors)
  return [event]
end