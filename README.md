![Bluetooth](https://content.instructables.com/ORIG/F5E/U6LP/J7QGI2TI/F5EU6LPJ7QGI2TI.jpg)
# Bluetooth
## Introdução
## Implementação
### bluetooth_server.c
```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/rfcomm.h>
#include <led.h>

typedef char *(*CommandExec)(void);

typedef struct 
{
    const char *command;
    CommandExec exec;
} Commands;

char *LedOn(void);
char *LedOff(void);

static Commands commands[] = 
{
    {"LED ON", LedOn},
    {"LED OFF", LedOff},
};

static LED_t led = {
        .gpio.pin = 0,
        .gpio.eMode = eModeOutput
    };

static void changeToUpper(char *data);

static int commands_amount = sizeof(commands)/sizeof(commands[0]);

int main(int argc, char const *argv[])
{

    if(system("./sdp.sh") != 0)
    {
        exit(1);
    }

    if(LED_init(&led))
        return EXIT_FAILURE;
    
    LED_set(&led, eStateLow);

    struct sockaddr_rc server_address = {0};
    struct sockaddr_rc client_address = {0};

    char data[1024] = {0};
    char *pSend = NULL;
    int s, clientsocket, bytes;
    socklen_t opt = sizeof(client_address);

    s = socket(AF_BLUETOOTH, SOCK_STREAM, BTPROTO_RFCOMM);

    server_address.rc_family = AF_BLUETOOTH;
    server_address.rc_bdaddr = *BDADDR_ANY;
    server_address.rc_channel = 1;

    bind(s, (struct sockaddr *)&server_address, sizeof(server_address));
    listen(s, 1);

    clientsocket = accept(s, (struct sockaddr *)&client_address, &opt);

    ba2str(&client_address.rc_bdaddr, data);
    fprintf(stderr, "Connected to %s\n", data);
    memset(data, 0, sizeof(data));

    for(;;)
    {
        bytes = recv(clientsocket, data, sizeof(data), 0);
        if(bytes > 0)
        {
            changeToUpper(data);
            
            if(strncmp(data, "QUIT", 4) == 0)
            {
                printf("Quitting...\n");
                break;
            }

            for(int i = 0; i < commands_amount; i++)
            {
                if(strncmp(data, commands[i].command, strlen(commands[i].command)) == 0)
                {
                    pSend = commands[i].exec();
                }
            }
            
            if(pSend == NULL)
            {
                pSend = "Command does not exist.\n";
            }
            printf("%s\n", data);
            send(clientsocket, pSend, strlen(pSend), 0);
        }
        memset(data, 0, sizeof(data));
        pSend = NULL;
    }

    printf("Closing connection.\n");
    close(clientsocket);
    close(s);

    return 0;
}

char *LedOn(void)
{
    const char *message = "LED On\n";
    LED_set(&led, eStateHigh);
    return (char *)message;
}

char *LedOff(void)
{
    const char *message = "LED Off\n";
    LED_set(&led, eStateLow);
    return (char *)message;
}

static void changeToUpper(char *data)
{
    while(*data != '\0')
    {
        *data = toupper(*data);
        data++;
    }
}
```
## Conclusão
