ENV['BROWSER']   ||= "firefox"
ENV['PLATFORM']  ||= ""
ENV['WAIT']      ||= "3"
ENV['TIMES']     ||= "3"
ENV['RETRY']     ||= "1"
ENV['PROCESSES'] ||= "2"
ENV['PARALLEL_SPLIT_TEST_PROCESSES'] = ENV['PROCESSES']

require 'rspec'
require 'rspec/retry'
require 'watir-webdriver'
require 'require_all'
require 'common'
require 'securerandom'
require 'json'

# Require all page objects for the specs
require_rel './../pages/page.rb'
require_rel './../pages/**/mixins/*.rb'
require_rel './../pages/'

RSpec.configure do |config|
  config.verbose_retry = false # show retry status in spec process
  config.default_retry_count = Integer(ENV['RETRY']) # default retry count
end