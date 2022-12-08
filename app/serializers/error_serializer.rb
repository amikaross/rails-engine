class ErrorSerializer
  def self.not_found(message)
    {
      "message": "No record found",
      "errors": [message]
    }
  end

  def self.missing_attributes(messages)
    {
      "message": "Record is missing one or more attributes",
      "errors": messages
    }
  end

  def self.no_matching_object
    {
      "data": {}
    }
  end

  def self.invalid_query_params(error)
    {
      "message": "Invalid query params",
      "errors": error
    }
  end
end