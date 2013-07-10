require 'yaml'
require 'net/smtp'
require_relative "./watir_browser"

def email
  return nil if ENV['EMAIL'].empty?
  ENV['EMAIL'].split(',')
end

def to_boolean(s)
  !!(s =~ /^(true|t|yes|y|1)$/i)
end

def base_url(site)
  url = ""
  case site
  when "imentor"
    url = "http://demo.imidev.org"
  end
  return url
end

def not_present(element, wait = nil, times = nil)
  wait  ||= Integer(ENV['WAIT'])
  times ||= Integer(ENV['TIMES'])
  for i in 0...times
    return true if element.present? == false
    sleep(wait)
  end
  return false
end

def present(element, wait = nil, times = nil)
  wait  ||= Integer(ENV['WAIT'])
  times ||= Integer(ENV['TIMES'])
  for i in 0...times
    return true if element.present? == true
    sleep(wait)
  end
  return false
end

def table_to_array(rows)
  result = []
  rows.each do |tr|
    result << cells_to_array(tr.tds)
  end
  result
end

def cells_to_array(cells)
  result = []
  cells.each do |cell| result << cell.text end
  result
end

def browser
  client                = Selenium::WebDriver::Remote::Http::Default.new
  client.timeout        = 3600
  capabilities          = eval("Selenium::WebDriver::Remote::Capabilities.#{ENV['BROWSER']}")
  capabilities.platform = ENV['PLATFORM'] if !ENV['PLATFORM'].empty?
  if ENV['TARGET']
    return WatirBrowser.new(:remote, :url => ENV['TARGET'], :desired_capabilities => capabilities, :http_client => client)
  end
  WatirBrowser.new ENV['BROWSER'], :http_client => client
end

# Watir::Exception::UnknownObjectException
def rescue_wait_retry(browser = nil, wait = nil, times = nil, &block)
  wait  ||= Integer(ENV['WAIT'])
  times ||= Integer(ENV['TIMES'])
  begin
    return yield
  rescue => e
    puts "#{e.message}. Sleeping #{wait} seconds." if ENV['DEBUG']
    sleep(wait)
    browser.refresh if !browser.nil?
    if (times -= 1) > 0
      puts "Retrying... #{times} times left" if ENV['DEBUG']
      retry
    end
  end
  yield
end

def email_body(example, url, stack)
  body  = "#{example.full_description}<br /><br />"
  body += "URL: #{url}<br />"
  body += "Platform: #{ENV['PLATFORM']}<br />" if !ENV['PLATFORM'].empty?
  body += "Browser: #{ENV['BROWSER']}<br /><br />"
  body += "Exception:<br />#{example.exception}<br /><br />"
  stack.each do |entry|
    body += "#{entry}<br />"
  end
  body += "<br />"
  body
end

def send_email(to, opts = {})

  return if to.nil?

  opts[:server]      ||= 'localhost'
  opts[:from]        ||= 'jenkins@renttherunway.com'
  opts[:from_alias]  ||= 'The Butler'
  opts[:subject]     ||= "Jenkins"
  opts[:body]        ||= ""

  marker = Time.now.to_i

  attachment = ""
  image = ""
  img_tag = ""

  recipient_list = ""
  recipients = []
  to.each do |recipient|
    recipient_list += "To: <#{recipient}>\n"
    recipients << "<#{recipient}>"
  end
  recipient_list.chop!

  if opts[:filename] && opts[:file]

    image =<<EOF
Content-Location: CID:selenium
Content-ID: <selenium.net>
Content-Type: IMAGE/PNG
Content-Transfer-Encoding: BASE64

#{opts[:file]}
--#{marker}
EOF

    img_tag += "<img src='cid:selenium.net' alt='error image'>"

  end

  headers = <<EOF
From: #{opts[:from_alias]} <#{opts[:from]}>
#{recipient_list}
Subject: #{opts[:subject]}
MIME-Version: 1.0
Content-Type: multipart/related; boundary=#{marker}; type="text/html"
--#{marker}
EOF

  body =<<EOF
Content-Type: text/html

#{opts[:body]}
<br /><br />
#{img_tag}
--#{marker}
EOF

  msg = headers + body + image

  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message msg, opts[:from], recipients
  end

end