# encoding: utf-8
require 'optparse'

# Usage: rails_best_practices [options] path
#    -d, --debug                      Debug mode
#    -f, --format FORMAT              output format
#        --output-file FILE           output html file for the analyzing result
#        --without-color              only output plain text without color
#        --with-textmate              open file by textmate in html format
#        --with-mvim                  open file by mvim in html format
#        --with-git                   display git commit and username, only support html format
#        --with-hg                    display hg commit and username, only support html format
#        --vendor                     include vendor files
#        --spec                       include spec files
#        --test                       include test files
#        --features                   include features files
#    -x, --exclude PATTERNS           Don't analyze files matching a pattern
#                                     (comma-separated regexp list)
#    -g, --generate                   Generate configuration yaml
#    -v, --version                    Show this version
#    -h, --help                       Show this message
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: rails_best_practices [options] path"

  opts.on("-d", "--debug", "Debug mode") do
    options['debug'] = true
  end

  opts.on("-f", "--format FORMAT", "output format") do |format|
    options['format'] = format
  end

  opts.on("--without-color", "only output plain text without color") do
    options["without-color"] = true
  end

  opts.on("--with-textmate", "open file by textmate in html format") do
    options["with-textmate"] = true
  end

  opts.on("--with-mvim", "open file by mvim in html format") do
    options["with-mvim"] = true
  end

  opts.on("--with-hg", "display hg commit and username, only support html format") do
    options["with-hg"] = true
  end

  opts.on("--with-git", "display git commit and username, only support html format") do
    options["with-git"] = true
  end

  opts.on("--output-file OUTPUT_FILE", "output html file for the analyzing result") do |output_file|
    options["output-file"] = output_file
  end

  ["vendor", "spec", "test", "features"].each do |pattern|
    opts.on("--#{pattern}", "include #{pattern} files") do
      options[pattern] = true
    end
  end

  opts.on_tail('-v', '--version', 'Show this version') do
    require 'rails_best_practices/version'
    puts RailsBestPractices::VERSION
    exit
  end

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-x", "--exclude PATTERNS", "Don't analyze files matching a pattern", "(comma-separated regexp list)") do |list|
    begin
      options["exclude"] = list.split(/,/).map{|x| Regexp.new x}
    rescue RegexpError => e
      raise OptionParser::InvalidArgument, e.message
    end
  end

  opts.on("-g", "--generate", "Generate configuration yaml") do
    options["generate"] = true
  end

  opts.parse!
end

if options["generate"]
  RailsBestPractices::Analyzer.new(ARGV.first).generate
else
  analyzer = RailsBestPractices::Analyzer.new(ARGV.first, options)
  analyzer.analyze
  analyzer.output
  exit analyzer.runner.errors.size
end
