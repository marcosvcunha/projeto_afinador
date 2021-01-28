import serial
import json

ser = serial.Serial(
    port = 'COM4',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    bytesize=serial.EIGHTBITS,
    stopbits=serial.STOPBITS_ONE,
    timeout=5
)

# count = 0
mem_data = []
while len(mem_data) < 1024:
    data = ser.read()
    try:
        num = (int.from_bytes(data, 'little'))
        mem_data.append(num)
        # print(count)
    except:
        pass

json_data = json.dumps(mem_data)
with open('mem_data.txt', 'w') as f:
    f.write(json_data)