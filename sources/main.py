import numpy as np
import librosa

files = ['A', 'B', 'D', 'E', 'E2', 'G']

with open('load_to_mem.sv', 'w') as f:
    for fileName in files:
        w, fs = librosa.load(f'./notas/{fileName}.wav', sr=1024)
        w = w[:1024]
        w[w >= 0] = 200
        w[w < 0] = 0

        f.write(f'const bit signed [9:0] note{fileName}[0:1023] = ')
        f.write('{')
        for num in w:
            f.write(str(int(num)) + ', ')
        f.write('};\n')
