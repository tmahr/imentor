require 'watir-webdriver'
require_relative "./watir_element"

class WatirBrowser

  @browser = nil
  @data    = nil
  @@ignore = [
    :extract_selector,
    :driver,
    :wd,
    :assert_exists,
    :title,
    :url,
    :run_checkers,
    :stack,
  ]

  def initialize(browser = :firefox, *args)
    @browser = Watir::Browser.new(browser, *args)
    @data    = []
    return @browser
  end

  def stack
    @data
  end

  def method_missing(name, *args, &block)
    started_at = Time.now
    res = @browser.send(name, *args)
    @data.push("%.5f : #{name} #{args}" % (Time.now - started_at)) if !@@ignore.include? name
    return WatirElement.new(res, @data) if res.is_a? Watir::Element
    res
  end

end