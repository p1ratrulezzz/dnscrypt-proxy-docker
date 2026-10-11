#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <unistd.h>
int main(void) {
    int s = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in a = {.sin_family = AF_INET, .sin_port = htons(53)};
    inet_pton(AF_INET, "127.0.0.1", &a.sin_addr);
    unsigned char q[] = {
        0x00,0x01, 0x01,0x00, 0x00,0x01, 0,0,0,0,0,0,
        6,'g','o','o','g','l','e',3,'c','o','m',0, 0x00,0x01, 0x00,0x01
    };
    struct timeval tv = {.tv_sec = 3};
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof tv);
    if (sendto(s, q, sizeof q, 0, (void *)&a, sizeof a) < 0) return 1;
    unsigned char b[512];
    return recv(s, b, sizeof b, 0) < 12;
}