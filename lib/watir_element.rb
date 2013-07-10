require 'watir-webdriver'

class WatirElement

  @element = nil
  @data    = nil

  def initialize(element, data)
    @element = element
    @data    = data
  end

  def method_missing(name, *args, &block)
    started_at = Time.now
    res = @element.send(name, *args)
    @data.push("%.5f : #{name} #{args}" % (Time.now - started_at))
    return WatirElement.new(res, @data) if res.is_a? Watir::Element
    res
  end

end