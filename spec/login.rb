require 'spec_helper'

describe "iMentor" do

  # Need to have localhost running SMTP server

  before :each do
    @page = IMentorPage::MetaPage.new browser
  end

  after :each do
    if example.exception != nil
      subject    = "#{example.full_description} [#{Time.now.to_i}]"
      url        = ""
      screenshot = ""
      @page.url(url).screenshot(screenshot)
      send_email email, :subject => subject, :body => email_body(example, url, @page.stack), :file => screenshot, :filename => "#{subject}.png"
    end
    @page.close
  end

  it "allows me to login" do
    @page.open(IMentorPage::Login)
         .login("username", "password")
    expect("").to eq("1")
  end
  
end