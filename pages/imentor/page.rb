module IMentorPage

  class MetaPage < PageObjects::MetaPage
    
    def initialize(browser, title = "")
      @browser = browser
      if !self.class.name.eql?("IMentorPage::MetaPage")
        begin
          super(browser, title)
        rescue => e
          raise "#{self.class} cannot be instantiated - #{e.message}"
        end
      end
    end

  end

end