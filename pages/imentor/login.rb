module IMentorPage

  class Login < IMentorPage::MetaPage

    URL   = base_url("imentor")
    TITLE = "iMi Mentors for Change: Login"

    include IMentorPage::Navigation

    def locator(key, *options)
      hash = {
        "email field"    => [:id => "id_email"],
        "password field" => [:id => "id_password"],
        "login button"   => [:id => "btn_login"],
        "" => [],
        "" => [],
        "" => [],
        "" => [],
      }
      hash.has_key?(key) ? hash[key] : defined?(super) ? super : raise("Locator [#{key}] does not exist in #{self.class.to_s}")
    end

    def is_loaded(title)
      super(title)
    end
    
    def login(email, password)
      @browser.text_field(*locator("email field")).set(email)
      @browser.text_field(*locator("password field")).set(password)
      @browser.button(*locator("login button")).click
      #IMentorPage::Home.new @browser
    end

  end

end
