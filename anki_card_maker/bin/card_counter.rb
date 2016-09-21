require './lib/source_reader'
require './lib/tag_helper'
require './lib/latest_file_finder'
require './lib/mylogger'


path = '/Users/royce/Dropbox/Documents/Reviewer/javascript'

# Use folder of last modified file
file_mask = '*.md'
finder = LatestFileFinder.new('/Users/royce/Dropbox/Documents/Reviewer', file_mask)
finder.find
path = finder.latest_folder
$logger.debug("Path: #{ path }")


total_cards = 0
total_files = 0
total_api = 0

Dir[File.join(path, file_mask)].each do |filename|
  if filename =~ /\.(?:md|api)$/m
    total_files += 1
    File.open(filename, 'r') do |file|
      card_count = 0
      SourceReader.new(file).each_card { |tags, front, back| card_count += 1 }
      total_api += card_count if filename.include?'-API-'
      puts "#{ filename }: #{ card_count }"
      total_cards += card_count
    end
  end
end

puts "Total files: #{ total_files }"
puts "Total cards: #{ total_cards }"
puts "Total API cards: #{ total_api }"
puts "Total non-API cards: #{ total_cards-total_api }"


