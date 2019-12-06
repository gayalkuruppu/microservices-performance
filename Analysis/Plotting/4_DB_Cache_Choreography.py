import pandas as pd
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams.update({'font.size': 14})

path = '/home/gayal/PycharmProjects/microservices-performance/'
csv = 'Results/4_DB_Cache_Choreography.csv'
save_to = 'Analysis/Plotting/plots/4_DB_Cache_Choreography/'
data = pd.read_csv(path+csv)


for s in range(0, 1, 24):
    plt.figure()
    # plt.title('DB cache - Chaining pattern')
    plt.xlabel('Concurrency')
    plt.ylabel('Throughput (requests/second)')
    plt.plot(data['Users'].iloc[s:s+8], data['Throughput'].iloc[s:s+8], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+16], data['Throughput'].iloc[s+8:s+16], label='2 Services', marker='o')
    # plt.plot(data['Users'].iloc[s+16:s+24], data['Throughput'].iloc[s+16:s+24], label='Three Services', marker='o')
    #
    # this is used only in chaining pattern where we have data for 3 services case. otherwise leave this line commented
    #
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/TPS_plot'+str(s//24), bbox_inches='tight')

for s in range(0, 1, 24):
    plt.figure()
    # plt.title('DB cache - Chaining pattern')
    plt.xlabel('Concurrency')
    plt.ylabel('Average Response Time (ms)')
    plt.plot(data['Users'].iloc[s:s+8], data['Avg_Latency'].iloc[s:s+8], label='1 Service', marker='o')
    plt.plot(data['Users'].iloc[s+8:s+16], data['Avg_Latency'].iloc[s+8:s+16], label='2 Services', marker='o')
    # plt.plot(data['Users'].iloc[s+16:s+24], data['Avg_Latency'].iloc[s+16:s+24], label='Three Services', marker='o')
    plt.ticklabel_format(style='sci', axis='y', scilimits=(0, 3))
    plt.legend()
    plt.savefig(path+save_to+'/Latency_plot'+str(s//24), bbox_inches='tight')
