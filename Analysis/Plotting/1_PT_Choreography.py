import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams.update({'font.size': 14})


path = '/home/gayal/PycharmProjects/microservices-performance/'
csv = 'Results/1_PT_Choreography.csv'
save_to = 'Analysis/Plotting/plots/1_PT_Choreography'
size = [50, 400, 1024]
data = pd.read_csv(path+csv)

for s in range(0, 49, 24):
    plt.figure()
    # plt.title('Message Size - {} Bytes'.format(size[s//24]))
    plt.xlabel('Concurrency')
    plt.ylabel('Throughput (requests/second)')
    plt.plot(data['Users'].iloc[s:s+8], data['Throughput'].iloc[s:s+8], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+16], data['Throughput'].iloc[s+8:s+16], label='2 Services', marker='o')
    plt.plot(data['Users'].iloc[s+16:s+24], data['Throughput'].iloc[s+16:s+24], label='3 Services', marker='o')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/TPS_plot'+str(s//24), bbox_inches='tight')

for s in range(0, 49, 24):
    plt.figure()
    # plt.title('Message Size - {} Bytes'.format(size[s//24]))
    plt.xlabel('Concurrency')
    plt.ylabel('Average Response Time (ms)')
    plt.plot(data['Users'].iloc[s:s+8], data['Avg_Latency'].iloc[s:s+8], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+16], data['Avg_Latency'].iloc[s+8:s+16], label='2 Services', marker='o')
    plt.plot(data['Users'].iloc[s+16:s+24], data['Avg_Latency'].iloc[s+16:s+24], label='3 Services', marker='o')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/Latency_plot'+str(s//24), bbox_inches='tight')
