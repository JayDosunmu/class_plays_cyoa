#include <stdio.h>
#include <sys/socket.h>
#include <stdlib.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>

#define PORT 8080
//tcp://0.tcp.ngrok.io:15991

// Function declarations for use throughout program file
char* get_input(char *str);
int resolve_host(char*, char*);

int main(int argc, char const **argv) {
    struct sockaddr_in address, serv_addr; // socket adddress data
    int sock = 0, valread; // socket descriptor, and num_bytes read
    int port;
    size_t msgSize, bufferSize = 1025; // size of different buffers
    char ip[100] = {0};
    char hostname[100] = {0}; 
    char protocol[100] = {0};
    char buffer[1025] = {0};
    char msg[1025] = {0};

    if (argc == 2) {
        //tcp://0.tcp.ngrok.io:15991
        sscanf(argv[1], "%99[a-z]://%99[a-zA-Z0-9.]:%d", protocol, hostname, &port);
    } else if (argc == 3) {
        strcpy(hostname, argv[1]);
        port = atoi(argv[2]);
    } else {
        strcpy(ip, "127.0.0.1");
        port = PORT;
    }

    // return 0;
    if (ip[0] == '\0') {
        if(resolve_host(ip, hostname) != 0) {
            printf("\nUnable to resolve hostname \n");
            return -1;
        }
    }

    // create socket
    if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("\n Socket creation error \n");
        exit(EXIT_FAILURE);
    }

    memset(&serv_addr, 0, sizeof(serv_addr));

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(port);

    if(inet_pton(AF_INET, ip, &serv_addr.sin_addr) <= 0) {
        printf("\nInvalid address inputted \n");
        return -1;
    }

    // connect to socket
    if (connect(sock, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
        printf("\nConnection failed\n");
        return -1;
    }

    while (1) {
        // clear buffers
        memset(msg, 0, msgSize);
        memset(buffer, 0, bufferSize);

        // read input from user
        get_input(msg);
        // if the user inputted "quit", exit the loop
        if (strcmp(msg, "quit") == 0) {
            break;
        }
        // send inputted data to server
        send(sock, msg, strlen(msg), 0);

        // read acknowledgement from server
        valread = read(sock, buffer, 1025);
        printf("%s\n", buffer);
    }

    // close socket to clean up after program (alerts server that this connection has been terminated)
    close(sock);
    printf("Goodbye adventurer... We will await your return.\n");
    return 0;
}

char* get_input(char *str) {
    printf("What is your decision adventurer? (enter quit to stop)\n>> ");
    // read an entire line of input including spaces from stdin using fgets
    do {
        fflush(stdin);
        fgets(str, 1025, stdin); // note, I had to use an actual integer value instead of a variable for the input size
        // make sure to null terminate input to avoid weird overflow errors
        str[strlen(str) - 1] = '\0';
    // leep doing this until there is a valid string in the buffer
    } while(str[0] == '\n' || strlen(str) == 0);

    return str;

}

int resolve_host(char *ip, char *hostname) {
    struct hostent *he;
    struct in_addr **addr_list;
    int i;

    if ((he = gethostbyname(hostname)) == NULL) {
        herror("get host name");
        return 1;
    }

    addr_list = (struct in_addr **)he->h_addr_list;

    for(i=0; addr_list[i] != NULL; i++) {
        strcpy(ip, inet_ntoa(*addr_list[i]));
    }

    return 0;
}