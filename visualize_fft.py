import matplotlib.pyplot as plt
import numpy as np

X_r = []
X_i = []
with open('fft_out.txt', 'r') as f:
    for _ in range(1024):
        a = int(f.readline().replace(' ', '').replace('\n', ''))
        X_r.append(a)
    for _ in range(1024):
        a = int(f.readline().replace(' ', '').replace('\n', ''))
        X_i.append(a)

X_r = np.array(X_r)
X_i = np.array(X_i)

X = np.abs(X_r) + np.abs(X_i)

plt.plot(X[:512])
plt.show()