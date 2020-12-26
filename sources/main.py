import math

with open('sin_mem.sv', 'w') as f:
    for i in range(1024):
        num = int(math.sin(2*math.pi*i/1024) * (512))
        f.write(f" {num},")
    
    f.write('\n\n\n\n\n\n\n')

    for i in range(1024):
        num = int(math.cos(2*math.pi*i/1024) * (512))
        f.write(f" {num},")