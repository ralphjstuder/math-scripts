import math
value = []
objects = int(input("Enter the number of objects for distribution: "))
nodes = int(input("Enter the number of nodes: "))
limit = int(input("Enter the maximum number of objects per node: "))

def nCr(n, r):
    # Number of combinations for choosing r out of n
    f = math.factorial
    return f(abs(n)) // f(abs(r)) // f(abs(n - r))

def inclusion_exclusion(x):
    # Exclude cases that are double counted
    count = 0
    plus = []
    minus = []
    while count <= len(value) - 1:
        plus.append(value[count])
        try:
            minus.append(value[count + 1])
        except IndexError:
            pass
        count += 2
    print(x-(sum(plus) - sum(minus)))

def principle_of_inclusion_exclusion(obj, node, lim):
    # Stars and bars
    bars = nodes - 1
    total = int(nCr(objects + bars, bars))
    
    # All cases where limit is exceeded
    remain = objects+bars
    count = 1
    while remain >= bars:
        remain = remain - (limit + 1)
        incl_exc = int(nCr(nodes, count) * nCr(remain, bars))
        value.append(incl_exc)
        count += 1
    inclusion_exclusion(total)

principle_of_inclusion_exclusion(objects, nodes, limit)
