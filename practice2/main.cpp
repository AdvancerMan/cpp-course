#include <iostream>
#include <cstdlib>
#include <cstring>
#include <string>

void calculateZFunction(char* s, int size, int* result) {
    int lastBiggestSuffix = 0;
    result[0] = 0;
    for (int i = 1; i < size; i++) {
        result[i] = std::max(0, std::min(result[i - lastBiggestSuffix], lastBiggestSuffix + result[lastBiggestSuffix] - i));
        if (i + result[i] >= lastBiggestSuffix + result[lastBiggestSuffix]) {
            lastBiggestSuffix = i;
            while (result[lastBiggestSuffix] < size && s[result[lastBiggestSuffix]] == s[result[lastBiggestSuffix] + lastBiggestSuffix]) {
                result[lastBiggestSuffix]++;
            }
        }
    }
}

// calculates zFunction based on firstS...s[0..s.size - firstS.size - 1] string
void calculateZFunction(char* firstS, int firstSize, char* s, int size, int* firstBlock, int* result, std::pair<int, int>* lastBlockSuffix) {
    int lastBiggestSuffix = lastBlockSuffix->first;
    for (int i = 0; i <= size - firstSize; i++) {
        int lastBiggestSuffixValue = lastBiggestSuffix == lastBlockSuffix->first ? lastBlockSuffix->second : result[lastBiggestSuffix];
        result[i] = std::max(0, std::min(i - lastBiggestSuffix < firstSize ? firstBlock[i - lastBiggestSuffix] : 0, 
                               lastBiggestSuffix + lastBiggestSuffixValue - i));
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

    int substringSize = 0;
    while (argv[1][substringSize] != '\0') {
        substringSize++;
    }

    const int bufferSize = substringSize * 4;

    int firstBlockZFunction[substringSize];
    calculateZFunction(argv[1], substringSize, firstBlockZFunction);

    std::pair<int, int> biggestSuffix = {0, 0};
    char buffer[bufferSize];
    int zFunction[bufferSize];

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
        for (int i = 0; i <= bytesInBuffer - substringSize; i++) {
            contains = contains || zFunction[i] >= substringSize;
        }
        
        biggestSuffix.first += substringSize;
        for (int i = bufferSize - substringSize; i < bufferSize; i++) {
            buffer[i - (bufferSize - substringSize)] = buffer[i];
        }
    }
    fclose(f);

    size_t bytes_written = fwrite(contains ? "true\n" : "false\n", sizeof(char), contains ? 5 : 6, stdout);
    if (bytes_written == 0) {
        perror("fwrite failed");
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
