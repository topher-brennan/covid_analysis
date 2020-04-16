require "open-uri"

GLOBAL_DEATHS = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
UNITED_STATES = "US"
ITALY = "Italy"
DATE_REGEX = /\d\d?\/\d\d?\/\d\d/

# Stolen from https://stackoverflow.com/a/57397583
# Use over other solutions because I don't want to put every array element on a separate line
module PrettyHash
  # Usage: PrettyHash.call(nested_hash)
  # Prints the nested hash in the easy to look on format
  # Returns the amount of all values in the nested hash

  def self.call(hash, level: 0, indent: 2)
    unique_values_count = 0
    hash.each do |k, v|
      (level * indent).times { print ' ' }
      print "#{k}:"
      if v.is_a?(Hash)
        puts
        unique_values_count += call(v, level: level + 1, indent: indent)
      else
        puts " #{v}"
        unique_values_count += 1
      end
    end
    unique_values_count
  end
end

def parse_csv_from_uri(uri)
  open(uri).read.split(/\n/).map { |row| row.split(",") }
end

def weekly_growth(rows, country)
  first_day = rows.first.index { |cell| cell.match?(DATE_REGEX) }
  deaths = rows.find { |row| row.include?(country) }.drop(first_day)

  i = 7
  results = []
  while i < deaths.size
    result = (deaths[i].to_i - deaths[i-7].to_i)
    results << result
    i += 1
  end
  results
end

def weekly_factors(rows, country)
  first_day = rows.first.index { |cell| cell.match?(DATE_REGEX) }
  deaths = rows.find { |row| row.include?(country) }.drop(first_day)

  i = 7
  results = []
  while i < deaths.size
    result = 0
    result = (deaths[i].to_f / deaths[i-7].to_f).round(1) if deaths[i-7].to_f > 0
    results << result
    i += 1
  end
  results
end

if __FILE__ == $PROGRAM_NAME
  rows = parse_csv_from_uri(GLOBAL_DEATHS)

  results = {
    italy: weekly_growth(rows, ITALY),
    united_states: weekly_growth(rows, UNITED_STATES)
  }
  print PrettyHash.call(results)
end
