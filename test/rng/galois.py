
lfsr = 0b101101111

hit = [0] * 512
for i in range(512):
    feedback = ((lfsr >> 0) ^ (lfsr >> 1) ^ (lfsr >> 2) ^ (lfsr >> 6) ^ (lfsr >> 7) ^ (lfsr >> 8)) & 0b1
    lfsr = (lfsr << 1 | feedback) & 0x1ff
    hit[lfsr] = 1

print("galois9: ", sum(hit))

lfsr = 0b10110111

hit = [0] * 256
for i in range(256):
    feedback = ((lfsr >> 0) ^ (lfsr >> 1) ^ (lfsr >> 6) ^ (lfsr >> 7)) & 0b1
    lfsr = (lfsr << 1 | feedback) & 0xff
    hit[lfsr] = 1

print("galois8: ", sum(hit))

lfsr = 0b1011

hit = [0] * 16
for i in range(16):
    feedback = ((lfsr >> 0) ^ (lfsr >> 3)) & 0b1
    lfsr = (lfsr << 1 | feedback) & 0xf
    hit[lfsr] = 1

print("galois4: ", sum(hit))

lfsr = 0b00111

hit = [0] * 32
for i in range(32):
    feedback = ((lfsr >> 2) ^ (lfsr >> 4)) & 0b1
    lfsr = (lfsr << 1 | feedback) & 0x1f
    hit[lfsr] = 1

print("galois5: ", sum(hit))

lfsr = 0b00111

hit = [0] * 64
for i in range(64):
    feedback = ((lfsr >> 0) ^ (lfsr >> 5)) & 0b1
    lfsr = (lfsr << 1 | feedback) & 0x3f
    hit[lfsr] = 1

print("galois6: ", sum(hit))
