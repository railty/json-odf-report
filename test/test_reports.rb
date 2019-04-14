require 'rubygems'
require 'bundler/setup'
Bundler.require

#LIBREOFFICE = "C:\\PortableApps\\PortableApps\\LibreOfficePortable\\LibreOfficePortable.exe --headless --invisible"
LIBREOFFICE = "C:\\LibreOfficePortable\\LibreOfficePortable.exe --headless --invisible"

OUTPUT = "pdf/"

def generate_report(data_file, template)
  puts "generating report for #{template} using #{data_file}"

  data = JSON.parse(File.read(data_file))
  #puts JSON.pretty_generate(data)

  report = JODFReport::Report.new(template, data)
  report_file = report.generate
  
  local_report_file = "odt/#{Pathname.new(report_file).basename}"
  #puts "#{report_file}-->#{local_report_file}"
  FileUtils.mv(report_file, local_report_file)
  
  cmd = "#{LIBREOFFICE} --convert-to pdf #{local_report_file} --outdir #{OUTPUT}"
  `#{cmd}`
end

if ARGV.length==2 then
  generate_report(ARGV[0], ARGV[1])
else
  puts "usage: #{$0} data_file template_file"
  puts "\n\nNow we go through all the combinitions"
  
  Dir["*.json"].each do |json|
    Dir["*.odt"].each do |odt|
      generate_report(json, odt)
    end
  end
end

