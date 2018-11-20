import matplotlib.pyplot as plt
import csv
import sys

dataset_1 = sys.argv[1]
dataset_2 = sys.argv[2]
dataset_3 = sys.argv[3]
dataset_4 = sys.argv[4]
dataset_5 = sys.argv[5]
dataset_6 = sys.argv[6]
dataset_7 = sys.argv[7]
dataset_8 = sys.argv[8]
category_1 = sys.argv[9]
category_2 = sys.argv[10]
category_3 = sys.argv[11]
category_4 = sys.argv[12]
category_5 = sys.argv[13]
category_6 = sys.argv[14]
category_7 = sys.argv[15]
category_8 = sys.argv[16]
plot_title = sys.argv[17]

x1=[]
y1=[]

x2=[]
y2=[]

x3=[]
y3=[]

x4=[]
y4=[]

x5=[]
y5=[]

x6=[]
y6=[]

x7=[]
y7=[]

x8=[]
y8=[]

with open(dataset_1, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x1.append(int(row[0]))
        y1.append(float(row[7]))
		
with open(dataset_2, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x2.append(int(row[0]))
        y2.append(float(row[7]))
		
with open(dataset_3, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x3.append(int(row[0]))
        y3.append(float(row[7]))

with open(dataset_4, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x4.append(int(row[0]))
        y4.append(float(row[7]))
		
with open(dataset_5, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x5.append(int(row[0]))
        y5.append(float(row[7]))

with open(dataset_6, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x6.append(int(row[0]))
        y6.append(float(row[7]))

with open(dataset_7, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x7.append(int(row[0]))
        y7.append(float(row[7]))

with open(dataset_8, 'r') as csvfile:
    plots= csv.reader(csvfile, delimiter=',')
    for row in plots:
        x8.append(int(row[0]))
        y8.append(float(row[7]))

plt.plot(x1,y1, marker='o')
plt.plot(x2,y2, marker='o')
plt.plot(x3,y3, marker='o')
plt.plot(x4,y4, marker='o')
plt.plot(x5,y5, marker='o')
plt.plot(x6,y6, marker='o')
plt.plot(x7,y7, marker='o')
plt.plot(x8,y8, marker='o')

plt.title(plot_title)

plt.legend([category_1, category_2, category_3, category_4, category_5, category_6, category_7, category_8])

plt.xlabel('Concurrency')
plt.ylabel('TPS')

plt.show()
