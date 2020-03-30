from os import system
from os.path import abspath, dirname, join as pathJoin, isfile
from random import randint

dirName = dirname(abspath(__file__))
TEST_IN = pathJoin(dirName, "myTest.in")
TEST_OUT = pathJoin(dirName, "myTest.out")
failed = False

def test(x, y, operator, programPath):
    global TEST_IN, TEST_OUT, failed

    with open(TEST_IN, "w") as f:
        f.write(str(x))
        f.write("\n")
        f.write(str(y))
        f.write("\n")
    
    system(programPath + " < " + TEST_IN + " > " + TEST_OUT)

    with open(TEST_OUT, "r") as f:
        sres = f.read().strip()

    try:
        res = int(sres)
    except ValueError:
        print("Bad output")
        return
    
    ans = operator['apply'](x, y)
    if (ans != res):
        sans = str(ans)
        print(x, operator['str'], y, "!=", sres, "answer is", sans, sep='\n')

        for i in range(len(sans)):
            if sans[i] != sres[i]:
                print(str(i) + "-th character differs")
                break

        print("Lengths are:", "Result =", len(sres), "Answer =", len(sans))
        print()
        failed = True

def printTestInfo(range, n):
    print("Testing on %s for %d times" % (range, n))

def createOperator(str, apply):
    return {'str': str, 'apply': apply}

sumOperator = createOperator('+', lambda x, y: x + y)
subOperator = createOperator('-', lambda x, y: x - y)
mulOperator = createOperator('*', lambda x, y: x * y)

N = 100
10 ** 6000
LR = [
    (0, -1),
    (-1, -2),
    (-2, -3),
    (-3, -4),
    (-6, -10),
    (-19, -20),
    (-49, -50),
    (-99, -100),
    (-999, -1000),
    (-1999, -2000),
]

tests = [
    (-1000, 0),
    (1, 1),
    (0, 0)
]

testingFiles = [
    ("subtract", subOperator),
    ("multiply", mulOperator)
]

def toInt(x):
    return x if x >= 0 else 10 ** -x

def toStr(x):
    return str(x) if x >= 0 else "1e" + str(-x)

try:
    for file in testingFiles:
        fileName = pathJoin(dirName, "out", file[0])
        operator = file[1]
        
        if not isfile(fileName):
            print("File " + fileName + " doesn't exist. Trying to compile...")
            buildFile = pathJoin(dirName, "build.sh")
            if not isfile(buildFile):
                print("Build script should be placed near testScript.py")
                failed = True
                continue
            system(buildFile)
            if not isfile(fileName):
                print("File " + fileName + " still doesn't exist. Try build it by yourself.")
                failed = True
                continue
        print("Testing " + fileName + " with " + operator['str'])
        
        for tst in tests:
            printTestInfo("(" + toStr(tst[0]) + ", " + toStr(tst[1]) + ")", 1)
            test(toInt(tst[0]), toInt(tst[1]), operator, fileName)

        for lr in LR:
            L = toInt(lr[0])
            R = toInt(lr[1])
            printTestInfo("random[" + toStr(lr[0]) + ", " + toStr(lr[1]) + "]", N)
            for i in range(N):
                x = randint(L, R)
                y = randint(L, R)
                test(max(x, y), min(x, y), operator, fileName)
finally:
    if isfile(TEST_IN):
        system('rm ' + TEST_IN)
    if isfile(TEST_OUT):
        system('rm ' + TEST_OUT)
    
print("Failed :(" if failed else "Success!")

