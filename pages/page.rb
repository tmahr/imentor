module PageObjects

  class MetaPage

    def initialize(browser, title)
      @browser = browser
      if !self.class.name.eql?("PageObjects::MetaPage")
        begin
          self.class::URL
          title = self.class::TITLE if title.empty?
          rescue_wait_retry(@browser) { self.is_loaded(title) }
        rescue => e
          raise "#{self.class} cannot be instantiated - #{e.message}"
        end
      end
    end

    def open(page, append = "")
      begin
        @browser.goto(page::URL + append)
      rescue => e
        raise e.message
      end
      page.new(@browser)
    end

    def is_loaded(title)
      Watir::Wait.until { @browser.title.downcase.include?(title.downcase) }
    end

    def stack
      @browser.stack
    end

    def stack_time
      time  = 0
      steps = @browser.stack
      steps.each do |row|
        time += row.split(":")[0].strip!.to_f
      end
      return time
    end

    def close
      @browser.close
    end

    def screenshot(result)
      result.replace @browser.screenshot.base64
      self
    end

    def url(result)
      result.replace @browser.url
      self
    end

    def refresh
      @browser.refresh
      self
    end

  end

end