import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams.update({'font.size': 14})

path = '/home/gayal/PycharmProjects/microservices-performance/'
csv = 'Results/5_CPU_Orchestration.csv'
save_to = 'Analysis/Plotting/plots/5_CPU_Orchestration/'
data = pd.read_csv(path+csv)
prime = [521, 7919, 10007, 100003, 1000003, 10000019]


for s in range(0, 121, 24):
    plt.figure()
    # plt.title('Prime number - {} (Aggregator pattern)'.format(prime[s//24]))
    plt.xlabel('Concurrency')
    plt.ylabel('Throughput (requests/second)')
    plt.plot(data['Users'].iloc[s:s+7], data['Throughput'].iloc[s:s+7], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+15], data['Throughput'].iloc[s+8:s+15], label='2 Services', marker='o')
    plt.plot(data['Users'].iloc[s+16:s+23], data['Throughput'].iloc[s+16:s+23], label='3 Services', marker='o')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/TPS_plot'+str(s//24), bbox_inches='tight')

for s in range(0, 121, 24):
    plt.figure()
    # plt.title('Prime number - {} (Aggregator pattern)'.format(prime[s//24]))
    plt.xlabel('Concurrency')
    plt.ylabel('Average Response Time (ms)')
    plt.plot(data['Users'].iloc[s:s+7], data['Avg_Latency'].iloc[s:s+7], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+15], data['Avg_Latency'].iloc[s+8:s+15], label='2 Services', marker='o')
    plt.plot(data['Users'].iloc[s+16:s+23], data['Avg_Latency'].iloc[s+16:s+23], label='3 Services', marker='o')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/Latency_plot'+str(s//24), bbox_inches='tight')
