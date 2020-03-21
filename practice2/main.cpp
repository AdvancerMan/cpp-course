#include <iostream>
#include <cstdlib>
#include <cstring>
#include <string>

void calculateZFunction(char* s, size_t size, size_t* result) {
    size_t lastBiggestSuffix = 0;
    result[0] = 0;
    for (size_t i = 1; i < size; i++) {
        result[i] = std::max(0, std::min((int) result[i - lastBiggestSuffix], (int) (lastBiggestSuffix + result[lastBiggestSuffix] - i)));
        if (i + result[i] >= lastBiggestSuffix + result[lastBiggestSuffix]) {
            lastBiggestSuffix = i;
            while (result[lastBiggestSuffix] < size && s[result[lastBiggestSuffix]] == s[result[lastBiggestSuffix] + lastBiggestSuffix]) {
                result[lastBiggestSuffix]++;
            }
        }
    }
}

// calculates zFunction based on firstS...s[0..s.size - firstS.size - 1] string
void calculateZFunction(char* firstS, size_t firstSize, char* s, size_t size, size_t* firstBlock, size_t* result, std::pair<int, size_t>* lastBlockSuffix) {
    int lastBiggestSuffix = lastBlockSuffix->first;
    for (size_t i = 0; i <= size - firstSize; i++) {
        size_t lastBiggestSuffixValue = lastBiggestSuffix == lastBlockSuffix->first ? lastBlockSuffix->second : result[lastBiggestSuffix];
        result[i] = std::max(0, std::min((int) i - lastBiggestSuffix < firstSize ? (int) firstBlock[i - lastBiggestSuffix] : 0, 
                               (int) (lastBiggestSuffix + lastBiggestSuffixValue - i)));
        if (i + result[i] >= lastBiggestSuffix + lastBiggestSuffixValue) {
            lastBiggestSuffix = i;
            while (lastBiggestSuffix + result[lastBiggestSuffix] < size 
                && result[lastBiggestSuffix] < firstSize
                && s[lastBiggestSuffix + result[lastBiggestSuffix]] == firstS[result[lastBiggestSuffix]]) {
                result[lastBiggestSuffix]++;
            }
        }
    }
    lastBlockSuffix->first = lastBiggestSuffix - size;
    lastBlockSuffix->second = result[lastBiggestSuffix];
}

// deadline: 17:00
// O(|argv[1]|) mem
// O(|argv[1]| + |file(argv[2])|) time
int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "usage: " << (argc > 0 ? argv[0] : "<program name>") << " <substring> <filename>\n";
        return EXIT_FAILURE;
    }

    size_t substringSize = strlen(argv[1]);
    const size_t bufferSize = substringSize * 4;

    size_t firstBlockZFunction[substringSize];
    calculateZFunction(argv[1], substringSize, firstBlockZFunction);

    std::pair<int, size_t> biggestSuffix = {0, 0};
    char buffer[bufferSize];
    size_t zFunction[bufferSize];

    FILE* f = fopen(argv[2], "r");
    if (!f) {
        perror("fopen failed");
        return EXIT_FAILURE;
    }

    bool contains = false;
    bool firstTime = true;
    while (!contains) {
        size_t bytesInBuffer, bytesRead;
        if (firstTime) {
            bytesRead = bytesInBuffer = fread(buffer, sizeof(char), bufferSize, f);
            firstTime = false;
        } else {
            bytesRead = fread(buffer + substringSize, sizeof(char), bufferSize - substringSize, f);
            bytesInBuffer = bytesRead + substringSize;
        }

        if (bytesRead == 0) {
            if (ferror(f)) {
                perror("fread failed");
                fclose(f);
                return EXIT_FAILURE;
            }
            break;
        }

        calculateZFunction(argv[1], substringSize, 
            buffer, bytesInBuffer, 
            firstBlockZFunction,
            zFunction, &biggestSuffix);
        for (size_t i = 0; i <= bytesInBuffer - substringSize; i++) {
            contains = contains || zFunction[i] >= substringSize;
        }
        
        biggestSuffix.first += substringSize;
        for (size_t i = bufferSize - substringSize; i < bufferSize; i++) {
            buffer[i - (bufferSize - substringSize)] = buffer[i];
        }
    }
    fclose(f);

    size_t bytesWritten = fwrite(contains ? "true\n" : "false\n", sizeof(char), contains ? 5 : 6, stdout);
    if (bytesWritten == 0) {
        perror("fwrite failed");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
