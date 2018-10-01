import matplotlib.pyplot as plt
import csv
import sys

dataset_1 = sys.argv[1]
dataset_2 = sys.argv[2]

x1=[]
y1=[]

x2=[]
y2=[]

with open(dataset_1, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x1.append(int(row[0]))
        y1.append(float(row[1]))
		
with open(dataset_2, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x2.append(int(row[0]))
        y2.append(float(row[1]))

plt.plot(x1,y1, marker='o')
plt.plot(x2,y2, marker='o')
plt.title('Echo')
plt.legend(["First Machine", "Second Machine"])
plt.xlabel('Concurrency')
plt.ylabel('Average Latency')

plt.show()