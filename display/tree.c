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
#define GREEN       "\033[32;1m"


void tree(char* path, int dashes, int spaces, int level){
    /* open the directory specified by the path */
    DIR* dp = opendir(path);
    struct dirent* direntptr;


    /* while there are still items in the directory to read from */
    while ((direntptr = readdir(dp)) != NULL){
        /* we skip the current directory "." and the previous directory ".." */
        if ((strcmp(direntptr->d_name, ".") == 0) || (strcmp(direntptr->d_name, "..") == 0)){
            continue;
        }

        /* malloc extra space for the new path and construct it in a new string */
        char* newpath = (char*)malloc( sizeof(path) + sizeof(direntptr->d_name) + 2 );
        sprintf(newpath, "%s/%s", path, direntptr->d_name);

        /* if we are looking at a legitmate file/directory we print a new line */
        if ((strcmp(direntptr->d_name, ".") != 0) && (strcmp(direntptr->d_name, "..") != 0)){
            printf("\n");
        }
        /* print the pretty lines and dashes correctly with a space after the dashes */
        if ((strcmp(direntptr->d_name, ".") != 0) && (strcmp(direntptr->d_name, "..") != 0)){
            if (spaces > 0){
                /* we print one set of spaces for each level we are at, where level is how many sub driectories we have traversed into */
                for (int lvl = 0; lvl < level; lvl++){
                    printf("│");
                    for (int sp = 0; sp < spaces; sp++){
                        printf(" ");
                    }
                }
            }
            printf("├");
            /* always print 4 dashes. I think 4 dashes looks nice. */
            for (int place = 0; place < dashes; place++){
                printf("─");
            }
            printf(" ");
        }
        /* if we are looking at a directory and it isn't the current or previous directory, we print it and recurse into it.
            also check that the directory is readable with access and R_OK.
            note that we needed to malloc space for the whole path from the starting directory to any files/folders in subdirectories for access to work.
            if we were to just pass direntptr->d_name, it would just be the name of the file. 
                since the cwd of the process isn't in the same direcotry, access would not work*/
        if ((direntptr->d_type == DT_DIR) && (strcmp(direntptr->d_name, ".") != 0) && (strcmp(direntptr->d_name, "..") != 0) && (access(newpath, R_OK) == 0)){
            printf("%s%s%s", BLUE, direntptr->d_name, DEFAULT);
            /* recurse into the directory, keeping the same spaces and dashes but increasing the level by one */
            tree(newpath, dashes, spaces, level+1);
            free(newpath);
            continue;
        }
        /* if we cannot read the directory color it red */
        if ((access(newpath, R_OK) == -1) && (direntptr->d_type == DT_DIR)){
            printf("%s%s%s", RED, direntptr->d_name, DEFAULT);
            free(newpath);
            continue;
        }
        /* if it is not a directory and we can't access it color it red. this can probably be done in the above if-statement but i don't feel like changing it*/
        if ((access(newpath, R_OK) == -1)){
            printf("%s%s%s", RED, direntptr->d_name, DEFAULT);
            free(newpath);
            continue;
        }
        /* if it is a file and we have execute permissions, print it in green */
        if ((access(newpath, X_OK) == 0)){
            printf("%s%s%s", GREEN, direntptr->d_name, DEFAULT);
            free(newpath);
            continue;
        }
        /* otherwise it must just be a file we can read so we print it normally and continue */
        if ((strcmp(direntptr->d_name, ".") != 0) && (strcmp(direntptr->d_name, "..") != 0)){
            printf("%s%s%s", DEFAULT, direntptr->d_name, DEFAULT);
            free(newpath);
            continue;
        }
        free(newpath);
    }
    /* need to close the directory */
    closedir(dp);

    /* at this point we are done */
}

int main(int argc, char* argv[]){
    printf("%c", '\0');
    char* path = realpath(argv[1], NULL);
    //printf("%s", path);
    printf("%s%s%s",BLUE, argv[1], DEFAULT);
    tree(path, 4, 5, 0);
    puts("\0");
    free(path);
    return 0;
}
