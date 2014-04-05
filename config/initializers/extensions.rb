class String
  def capitalize_words
    self.gsub(/\b\w/){$&.upcase}
  end

  def clean(config = {})
    Sanitize.clean(self, config)
  end
end

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
  :display => "%b %d %Y %H:%M:%S %Z" # => Jun 15 2009 17:00:48 PDT
)
