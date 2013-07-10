require 'optparse'
require 'fileutils'
require 'hpricot'
require 'nokogiri'
require "./lib/pool"

# TASKS

task :clean do
  FileUtils.rm Dir.glob('output/*.xml')
  FileUtils.rm Dir.glob('output/*.xml.*')
end

desc "Run all tests"
task :default => [:clean] do
  ENV['DIR'] ||= 'spec/'
  run_suite
end

# HELPER FUNCTIONS

def setup_environment

  ENV['BROWSER']   ||= "firefox"
  ENV['PLATFORM']  ||= ""
  ENV['EMAIL']     ||= ""
  ENV['WAIT']      ||= "3"
  ENV['TIMES']     ||= "10"
  ENV['RETRY']     ||= "1"
  ENV['THREADS']   ||= "2"
  ENV['PROCESSES'] ||= "2"

end

def get_spec_files(directory)

  files = []

  Dir.glob(directory).each do |element|
    if File.directory? element
      files << get_spec_files("#{element}/*")
    else
      files << element if !element.end_with?("spec_helper.rb") && element.end_with?(".rb")
    end
  end

  files

end

def filter_files(files)

  return files if !ENV['FILES']

  valid_files = []

  files.each do |f|
    valid_files << f if ENV['FILES'].split(",").any? {|filter| f.end_with? filter}
  end

  valid_files

end

def execute_tests(files)

  # Run the threads in parallel
  p = Pool.new(Integer(ENV['THREADS']))

  tags = "--tag ~ignore "
  if ENV['TAGS']
    tags_array = ENV['TAGS'].split ","
    tags_array.each do |tag| tags += "--tag #{tag} " end
  end

  example = ENV['EXAMPLE'] ? "--example '#{ENV['EXAMPLE']}'" : "";

  files.each_with_index do |file, i|
    p.schedule do
      basename   = File.basename(file.gsub(/\//, "_"), '.*')
      header     = "\n" + file.ljust(75,"-") + "\n"
      finished   = "Job #{i} finished by thread #{Thread.current[:id]}\n"
      test_count = %x(rspec ./#{file} -r ./lib/test_count.rb -f TestCount #{tags} #{example}).lines.to_a.last.strip!
      ENV['PARALLEL_SPLIT_TEST_PROCESSES'] = test_count.to_i < ENV['PROCESSES'].to_i ? test_count : ENV['PROCESSES']
      results = %x(parallel_split_test ./#{file} -r ./lib/junit.rb -f JUnit -o output/#{basename}.xml -f documentation #{tags} #{example}) if ENV['PARALLEL_SPLIT_TEST_PROCESSES'].to_i > 0
      puts header + finished + results if !results.nil?
    end
  end

  p

end

def normalize_xml(folder)

  xml_files = []
  Dir.entries(folder).each do |element|
    xml_files << "#{folder}/#{element}" if element.end_with?(".xml")
  end

  merged_files = {}

  xml_files.each do |xml_file|

    merged_files[xml_file] = []
    file   = File.new(xml_file)
    number = 1
    result = ""

    file.each_line do |line|
      if line.start_with? "<?xml"
        if !result.empty?
          new_file_name = xml_file.gsub(".xml", ".#{number}.xml")
          merged_files[xml_file] << new_file_name
          new_file = File.new(new_file_name, "w")
          new_file.write(result)
          new_file.close
          number += 1
        end
        result = ""
      end
      result << line
    end

    new_file_name = xml_file.gsub(".xml", ".#{number}.xml")
    merged_files[xml_file] << new_file_name
    new_file = File.new(new_file_name, "w")
    new_file.write(result)
    new_file.close

    File.delete(xml_file)

  end

  merged_files.each do |merged_file, files_to_merge|

    errors   = 0
    failures = 0
    skipped  = 0
    tests    = 0
    time     = 0
    cases    = []

    files_to_merge.each do |file|

      # Collect the test cases
      temp = File.new(file)
      hdoc = Hpricot::XML(temp)
      (hdoc/:testcase).each { |testcase| cases << testcase }

      # Add up the attributes
      temp = File.new(file)
      xdoc = Nokogiri::XML(temp)
      xdoc.css("testsuite").each do |element|
        errors   += element.attr("errors").to_i
        failures += element.attr("failures").to_i
        skipped  += element.attr("skipped").to_i
        tests    += element.attr("tests").to_i
        time     += element.attr("time").to_f
      end

      File.delete(file)

    end

    # Write the final merged results.xml
    results = File.new(merged_file, "w")
    results.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    results.write("<testsuite errors=\"#{errors}\" failures=\"#{failures}\" skipped=\"#{skipped}\" tests=\"#{tests}\" time=\"#{time}\">\n")
    results.write("  <properties/>\n")
    cases.each { |tc| results.write("  #{tc}\n") }
    results.write("</testsuite>")
    results.close

  end

end

def merge_output(pool)

  # Wait for thread pool to finish
  at_exit do

    # Gracefully shutdown the thread pool
    pool.shutdown

    # Validate all xml result files
    normalize_xml("output")

    # Merge the result files into result.xml
    xml_files = []
    Dir.entries('output').each do |element|
      xml_files << element if element.end_with?(".xml")
    end

    errors   = 0
    failures = 0
    skipped  = 0
    tests    = 0
    time     = 0
    cases    = []
    xml_files.each do |xml_file|

      # Collect the test cases
      temp = File.new("output/#{xml_file}")
      hdoc = Hpricot::XML(temp)
      (hdoc/:testcase).each { |testcase| cases << testcase }

      # Add up the attributes
      temp = File.new("output/#{xml_file}")
      xdoc = Nokogiri::XML(temp)
      xdoc.css("testsuite").each do |element|
        errors   += element.attr("errors").to_i
        failures += element.attr("failures").to_i
        skipped  += element.attr("skipped").to_i
        tests    += element.attr("tests").to_i
        time     += element.attr("time").to_f
      end

    end

    # Write the final merged results.xml
    results = File.new("output/results.xml", "w")
    results.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
    results.write("<testsuite errors=\"#{errors}\" failures=\"#{failures}\" skipped=\"#{skipped}\" tests=\"#{tests}\" time=\"#{time}\">\n")
    results.write("  <properties/>\n")
    cases.each { |tc| results.write("  #{tc}\n") }
    results.write("</testsuite>")
    results.close

  end

end

def run_suite
  setup_environment
  ENV['DIR'] ||= "spec/*"
  files = filter_files(get_spec_files(ENV['DIR']).flatten!)
  merge_output(execute_tests files)
end