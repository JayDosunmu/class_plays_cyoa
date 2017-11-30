#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/time.h>

#define true 1
#define false 0
#define PORT 8080

// Function declarations for use throughout program file
int store_command(const char*);

int main(int argc, char **argv)
{
    // Description of the following variables:
    int opt = true;
    int master_socket, // create address for socket location
        addrlen, // length of the address
        new_socket, // an address for active sockets
        client_socket[30], // a list containing available client sockets
        max_clients = 30, // the max size of that list
        activity, // variable to store whether there is activity in open connections
        i, // for loop sentinel variable
        val_read, // the number of bytes read from socket
        sd; // socket descriptor address for a socket
    // this is used to store the master socket descriptor
    int max_sd;
    // Struct containing the socket address data
    struct sockaddr_in address;
    
    // buffer to store data read from socket
    char buffer[1025];

    // file descriptor set struct
    fd_set readfds;

    // a response
    char *response = "The Fates have seen your choice...";

    // zero out all client sockets
    for (i=0; i<max_clients; i++) {
        client_socket[i] = 0;
    }

    // create a new master socket to work with
    if ((master_socket = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        perror("socket failed...");
        exit(EXIT_FAILURE);
    }

    // set options on master socket to allow multiple client socket connections
    if (setsockopt(master_socket, SOL_SOCKET, SO_REUSEADDR, (char *)&opt, sizeof(opt)) < 0) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }

    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(PORT);
    
    // bind the socket to the address/port
    if (bind(master_socket, (struct sockaddr *) &address, sizeof(address)) < 0) {
        perror("bind socket failed");
        exit(EXIT_FAILURE);
    }

    // begin listening on the main socket
    if (listen(master_socket, 3) < 0) {
        perror("listen failed");
        exit(EXIT_FAILURE);
    }

    addrlen = sizeof(address);
    puts("Waiting for incoming connections...");

    // Run continuously
    while(true) {
        // Zero out the list of sockets in set
        FD_ZERO(&readfds);

        // add master socket to the set
        FD_SET(master_socket, &readfds);
        max_sd = master_socket;

        // load the fd_set with socket descriptors
        for (i=0; i<max_clients; i++) {
            sd = client_socket[i];

            if (sd > 0) {
                FD_SET(sd, &readfds);
            }

            if (sd > max_sd) {
                max_sd = sd;
            }
        }

        // detect if there is activity on one of the connections
        activity = select(max_sd + 1, &readfds, NULL, NULL, NULL);

        // report an error in activity detection
        if ( (activity < 0) && (errno!=EINTR)) {
            printf("Socket error");
        }

        // if the master socket has activity, a new connection is coming in.
        if (FD_ISSET(master_socket, &readfds)) {
            // accept the new connection and create a new socket that references it
            if ((new_socket = accept(master_socket, (struct sockaddr *) &address, (socklen_t*)&addrlen))<0) {
                perror("accept");
                exit(EXIT_FAILURE);
            }

            printf("New connection , socket fd is %d , ip is : %s , port : %d\n" , new_socket , inet_ntoa(address.sin_addr) , ntohs
                (address.sin_port));
            // set the first free socket entry to the new socket value
            for (i=0; i<max_clients; i++) {
                if (client_socket[i] == 0) {
                    client_socket[i] = new_socket;
                    printf("Adding socket to list of open sockets as %d\n", i);

                    break;
                }
            }
        }

        // run through all the sockets and perform some operation on them
        for (i=0; i<max_clients; i++) {
            // get the socket identifier
            sd = client_socket[i];
            // clear the buffer to remove garbage data
            memset(buffer, 0, sizeof(buffer));

            // if the current socket is active, do something
            if (FD_ISSET(sd, &readfds)) {
                // read the info coming into the socket. If 0 bytes were read, the socket is closing. 
                if ((val_read = read(sd, buffer, 1024)) == 0) {
                    close(sd);
                    client_socket[i] = 0;

                } else {
                    // if a non-zero value of bytes are read, it is an incoming message. Use store_command
                    // to handle it
                    if(fork() == 0){
                        store_command(buffer);
                        printf("An adventurer has chosen: %s\n", buffer);

                        // respond to acknowledge
                        // if (send(new_socket, response, strlen(response), 0) != strlen(response)) {
                        //     perror("send");
                        // }

                        _Exit(EXIT_SUCCESS);
                    }
                }
            }
        }
    }

    return 0;
}

// function to store incoming commands into the file that the main game reads from
int store_command(const char *buffer) {
    // file data for the file to open
    FILE *fp;
    char *file = "commands";

    // open file to append data. Return error if file was unable to load 
    fp = fopen(file, "a");
    if (fp == NULL) {
        printf("Unable to open commands file. Failed to store command: %s", buffer);
        return 1;
    }

    // write the command to the file, and append a new line, then close the file
    fprintf(fp, buffer);
    fprintf(fp, "\n");
    fclose(fp);

    return 0;
}