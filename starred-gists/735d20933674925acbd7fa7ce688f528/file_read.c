#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

/**
 * @def FILE_READ(id, fileName)
 * @brief Macro to read content from a file.
 * 
 * This macro reads the content of the specified file and assigns it to the provided variable.
 * If successful, it enters a block where the content is available.
 * If unsuccessful, it prints an error message using perror and exits the block.
 * 
 * @param id Identifier for the variable to store the file content.
 * @param fileName Name of the file to read.
 */
#define FILE_READ(id, fileName) \
    char *id = file_read(fileName);\
    if(!id) perror("Error");\
    else{

/**
 * @def FILE_READ_END(id)
 * @brief Macro to free resources after reading a file.
 * 
 * This macro is used to free the memory allocated for storing the file content after it has been read.
 * 
 * @param id Identifier for the variable holding the file content.
 */
#define FILE_READ_END(id) free(id);}

/**
 * @brief Reads the content of a file.
 * 
 * This function reads the content of the specified file and returns it as a dynamically allocated string.
 * 
 * @param fileName Name of the file to read.
 * @return A pointer to the dynamically allocated string containing the file content, or NULL if an error occurs.
 */
char *file_read(const char *fileName) {
    long int sizeInBytes = 0;
    FILE *file = fopen(fileName, "r");
    if(!file)
        return NULL;
    if(fseek(file, 0, SEEK_END)) {
        fclose(file);
        return NULL;
    }
    sizeInBytes = ftell(file) + 1;
    if(sizeInBytes == -1L) {
        fclose(file);
        return NULL;
    }
    if(fseek(file, 0, SEEK_SET)) {
        fclose(file);
        return NULL;
    }
    char *buffer = malloc(sizeInBytes);
    if(!buffer) {
        fclose(file);
        return NULL;
    }
    buffer[sizeInBytes - 1] = '\0';
    size_t s = fread(buffer, sizeof(char), sizeInBytes - 1, file);
    if(s != sizeInBytes && errno) {
        free(buffer);
        fclose(file);
        return NULL;
    }
    fclose(file);
    return buffer;
}


/**example program
int main() {
    FILE_READ(content, "data.txt") //block begin
    //this block will be processed if the read operation is successful
    printf("%s\n", content);
    FILE_READ_END(content) //block end
}
*/
