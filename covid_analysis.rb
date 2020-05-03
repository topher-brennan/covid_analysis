require "open-uri"

GLOBAL_DEATHS = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
GLOBAL_CONFIRMED = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
UNITED_STATES = "US"
ITALY = "Italy"
# The following five countries have about 98% of the US population.
BIG_FIVE = [
  "France",
  "Germany",
  "Italy",
  "Spain",
  "United Kingdom"
]
EUROPEAN_UNION = [
  "Austria",
  "Belgium",
  "Bulgaria",
  "Croatia",
  "Cyprus",
  "Czechia",
  "Denmark",
  "Estonia",
  "Finland",
  "France",
  "Germany",
  "Greece",
  "Hungary",
  "Ireland",
  "Italy",
  "Latvia",
  "Lithuania",
  "Luxembourg",
  "Malta",
  "Netherlands",
  "Poland",
  "Romania",
  "Slovakia",
  "Slovenia",
  "Spain",
  "Sweden",
]
# Per capita GDP of at least $34,000 in 2019
RICH_EUROPE = [
  "Spain",
  "Italy",
  "United Kingdom",
  "France",
  "Belgium",
  "Germany",
  "Finland",
  "Austria",
  "Netherlands",
  "Sweden",
  "Denmark",
  "Ireland",
  "Norway",
  "Switzerland",
  "Iceland",
  "Luxembourg"
]
BIG_5_POPULATION = 324_000_000
EU_POPULATION = 445_000_000
US_POPULATION = 331_000_000
RICH_EUROPE_POPULATION = 403_000_000
COUNTRY = "Country"
DATE_REGEX = /\d\d?\/\d\d?\/\d\d/

# Stolen from https://stackoverflow.com/a/57397583
# Use over other solutions because I don't want to put every array element on a separate line
def pretty_hash(hash, level: 0, indent: 2)
  unique_values_count = 0
  hash.each do |k, v|
    (level * indent).times { print ' ' }
    print "#{k}:"
    if v.is_a?(Hash)
      puts
      unique_values_count += pretty_hash(v, level: level + 1, indent: indent)
    else
      puts " #{v}"
      unique_values_count += 1
    end
  end
  unique_values_count
end

def parse_csv_from_uri(uri)
  open(uri).read.split(/\n/).map { |row| row.split(",") }
end

def summed_rows_for_countries(rows, countries)
  first_day = rows.first.index { |cell| cell.match?(DATE_REGEX) }
  country_column = rows.first.index { |cell| cell.match?(COUNTRY) }
  selected_rows = rows.select { |row| countries.include?(row[country_column]) }

  totals = Array.new(selected_rows.first.drop(first_day).size) { 0 }

  selected_rows.each do |row|
    row.drop(first_day).each_with_index do |cell, i|
      totals[i] += cell.to_i 
    end
  end

  totals
end

def per_million(rows, countries, population)
  rows = summed_rows_for_countries(rows, countries).map { |total| total * 1_000_000 / population }
  latest = rows[-1]
  increase_for_week = latest - rows[-8]
  "#{latest} (+#{increase_for_week})"
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
    result = (deaths[i].to_f / deaths[i-7].to_f).round(2) if deaths[i-7].to_f > 0
    results << result
    i += 1
  end
  results
end

def weekly_change_in_growth(rows, country)
  growth = weekly_growth(rows, country)
  
  i = 7
  results = []
  while i < growth.size
    result = 0
    result = (growth[i].to_f / growth[i-7].to_f).round(2) if growth[i-7].to_f > 0
    results << result
    i += 1
  end
  results
end

if __FILE__ == $PROGRAM_NAME
  death_rows = parse_csv_from_uri(GLOBAL_DEATHS)
  confirmed_rows = parse_csv_from_uri(GLOBAL_CONFIRMED)

  results = {
    deaths: {
      big_five: per_million(death_rows, BIG_FIVE, BIG_5_POPULATION),
      european_union: per_million(death_rows, EUROPEAN_UNION, EU_POPULATION),
      rich_europe: per_million(death_rows, RICH_EUROPE, RICH_EUROPE_POPULATION),
      united_states: per_million(death_rows, [UNITED_STATES], US_POPULATION),
    },
    confirmed: {
      big_five: per_million(confirmed_rows, BIG_FIVE, BIG_5_POPULATION),
      european_union: per_million(confirmed_rows, EUROPEAN_UNION, EU_POPULATION),
      rich_europe: per_million(confirmed_rows, RICH_EUROPE, RICH_EUROPE_POPULATION),
      united_states: per_million(confirmed_rows, [UNITED_STATES], US_POPULATION),
    }
  }

  print pretty_hash(results)
  print "\n"
end
