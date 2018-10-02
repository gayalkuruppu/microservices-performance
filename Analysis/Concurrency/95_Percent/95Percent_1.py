import matplotlib.pyplot as plt
import csv
import sys

dataset_1 = sys.argv[1]
plot_title= sys.argv[2]

x1=[]
y1=[]

with open(dataset_1, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x1.append(int(row[0]))
        y1.append(float(row[5]))

plt.plot(x1,y1, marker='o')
plt.title(plot_title)
plt.xlabel('Concurrency')
plt.ylabel('95 Percentile')

plt.show()