import argparse
import csv
import matplotlib.pyplot as plt
from num2words import num2words
import urllib.request

plt.ion()
url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv'
response = urllib.request.urlopen(url)
cr = csv.reader(response.read().decode('utf-8').splitlines())

parser = argparse.ArgumentParser()
parser.add_argument("--smoothing", type=int, default=7)
parser.add_argument("--state", default="California")
parser.add_argument("--county", default="Alameda")
args = parser.parse_args()
smoothing = args.smoothing
state = args.state
county = args.county

def plot(data):
    x_axis = list(range(len(data)))
    fig, ax = plt.subplots()
    ax.plot(x_axis, data)

def fix_reporting_errors_by_interpolation(data):
    for i in range(len(data) - 2):
        first, middle, last = data[i], data[i+1], data[i+2]
        if type(first) == int and type(last) == int and data[i+1] > data[i+2]:
            data[i+1] = (data[i] + data[i+2]) / 2

first_row = cr.__next__()
county_index = first_row.index('Admin2')
state_index = first_row.index('Province_State')

for row in cr:
    if row[county_index] == county and row[state_index] == state:
        fix_reporting_errors_by_interpolation(row)
        first_case_index = row.index('1')
        case_data = [int(el) for el in row[first_case_index:]]
        fix_reporting_errors_by_interpolation(case_data)
        l = len(case_data)
        new_cases = [round((case_data[i+smoothing] - case_data[i]) / float(smoothing)) for i in range(l - smoothing)]
        plot(case_data)
        plot(new_cases)
        smoothing_str = (num2words(smoothing) if smoothing < 10 else str(smoothing))
        print(f'The {smoothing_str}-day period with the most cases had {max(new_cases)} cases per day.')
        print(f'The most recent {smoothing_str}-day period had {new_cases[-1]} cases per day.')
        k=input('Press any key to exit.')

