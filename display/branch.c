#include <stdio.h>
#include <dirent.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <errno.h>
#define FALSE       0
#define TRUE        1
#define BLUE        "\x1b[34;1m"
#define DEFAULT     "\x1b[0m"
#define RED         "\033[31;1m"

int main(int argc, char* argv[]){
    printf("hello world\n");
}