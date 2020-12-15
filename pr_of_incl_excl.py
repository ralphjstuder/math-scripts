import math
value = []
objects = int(input("Enter the number of objects (or dollar amount): "))
recipients = int(input("Enter the number of recipients(menu items or bins): "))
limit = int(input("Enter the maximum number of objects per recipients: "))

def nCr(n, k):
    f = math.factorial
    return f(abs(n)) // f(abs(k)) // f(abs(n - k))

def inclusion_exclusion(x):
    #Exclude cases that are double counted
    i = 0
    plus = []
    minus = []
    while i <= len(value) - 1:
        plus.append(value[i])
        try:
            minus.append(value[i + 1])
        except IndexError:
            pass
        i += 2
    print(x-(sum(plus) - sum(minus)))

def pie(objects, recipients, limit):
    #Stars and bars
    bars = recipients - 1
    total = int(nCr(objects + bars, bars))
    #All cases where limit is exceeded
    remain = objects+bars
    i = 1
    while remain >= bars:
        remain = remain - (limit + 1)
        incl_exc = int(nCr(recipients, i) * nCr(remain, bars))
        value.append(incl_exc)
        i += 1
    inclusion_exclusion(total)

pie(objects, recipients, limit)
