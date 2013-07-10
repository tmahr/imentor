require "rspec/core/formatters/base_text_formatter"

class TestCount < RSpec::Core::Formatters::BaseTextFormatter

  def example_started proxy
  end
  
  def example_pending example
  end
  
  def example_failed example
  end
  
  def dump_summary duration, example_count, failure_count, pending_count
    p example_count
  end
  
end

RSpec.configure do |config|
  config.before(:all) do
    raise 'Fail each test immediately'
  end
end