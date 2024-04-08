import numpy as np
import torch


def thingtodo(z: torch.Tensor):
    print(z)


for i in range(10):
    print(10)
    x = np.zeros((10, 2), dtype=np.int32)
    way = 10
    y = way
    thingtodo(x)  # type: ignore [arg-type]

    if x is not None:
        x = np.zeros((10, 2), dtype=np.int32)
for j in range(10):
    print(10)
w = torch.zeros((10, 10), device="cuda")

z = 10
if z % 2 == 0:
    z = 20


lst = []
for i in range(100):
    lst.append(i)

print(lst)
