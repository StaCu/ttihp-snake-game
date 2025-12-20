

dx = 11
dy = 7

x = 0
y = 0

hit = [0] * 220

for i in range(32*16):
    if x < 20 and y < 11:
        x = (x + dx) % 32
        y = (y + dy) % 16
    else:
        if x >= 20:
            x = (x + dx) % 32
        if y >= 11:
            y = (y + dy) % 16
    idx = x*11+y
    if x < 20 and y < 11 and hit[idx] == 0:
        hit[idx] = 1
        print(x, y)


print(sum(hit))
print(hit)
