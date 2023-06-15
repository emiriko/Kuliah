import math
from bitarray import bitarray
import struct

def nasnMd5(message):
    s = []
    k = []

    for i in range(0, 64):
        if(i >= 0 and i <= 15):
            if(i%4 == 0):
                s.append(7)
            elif(i%4 == 1):
                s.append(12)
            elif(i%4 == 2):
                s.append(17)
            else:
                s.append(22)
        elif(i >= 16 and i <= 31):
            if(i%4 == 0):
                s.append(5)
            elif(i%4 == 1):
                s.append(9)
            elif(i%4 == 2):
                s.append(14)
            else:
                s.append(20)
        elif(i >= 32 and i <= 47):
            if(i%4 == 0):
                s.append(4)
            elif(i%4 == 1):
                s.append(11)
            elif(i%4 == 2):
                s.append(16)
            else:
                s.append(23)
        elif(i >= 48 and i <= 63):
            if(i%4 == 0):
                s.append(6)
            elif(i%4 == 1):
                s.append(10)
            elif(i%4 == 2):
                s.append(15)
            else:
                s.append(21)


    for i in range(0, 64):
        k.append(math.floor(math.pow(2, 32)*abs(math.sin(i+1))))


    a0 = 0x67452301
    b0 = 0xefcdab89  
    c0 = 0x98badcfe   
    d0 = 0x10325476   

    bit_array = bitarray(endian="big")
    bit_array.frombytes(message.encode("utf-8"))

    bit_array.append(1)
    while(len(bit_array) % 512 != 448):
        bit_array.append(0)
    
    bit_arrayLittle = bitarray(bit_array, endian="little")

    length = (len(message) * 8) % pow(2, 64)
    length_bit_array = bitarray(endian="little")
    length_bit_array.frombytes(struct.pack("<Q", length))

    result = bit_arrayLittle.copy()

    result.extend(length_bit_array)


