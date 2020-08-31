import csv
import urllib.request
import matplotlib.pyplot as plt

plt.ion()
url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv'
response = urllib.request.urlopen(url)
cr = csv.reader(response.read().decode('utf-8').splitlines())

def plot(data):
    x_axis = list(range(len(data)))
    fig, ax = plt.subplots()
    ax.plot(x_axis, data)

for row in cr:
    if 'Alameda' in row and 'California' in row:
        first_case_index = row.index('1')
        case_data = [int(el) for el in row[first_case_index:]]
        l = len(case_data)
        new_cases = [case_data[i+7] - case_data[i] for i in range(l - 7)]
        plot(case_data)
        plot(new_cases)
        print(f'The seven-day period with the most cases had {max(new_cases)} cases.')
        print(f'The most recent seven-day period had {new_cases[-1]} cases.')
        k=input('Press any key to exit.')

