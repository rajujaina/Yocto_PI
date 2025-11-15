#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/i2c-dev.h>
#include <linux/spi/spidev.h>

// Example custom application for Raspberry Pi hardware interfaces
// This demonstrates basic I2C and SPI usage

#define I2C_DEVICE "/dev/i2c-1"
#define SPI_DEVICE "/dev/spidev0.0"

int test_i2c() {
    int fd;
    
    printf("Testing I2C interface...\n");
    
    fd = open(I2C_DEVICE, O_RDWR);
    if (fd < 0) {
        printf("Failed to open I2C device: %s\n", I2C_DEVICE);
        return -1;
    }
    
    printf("I2C device opened successfully: %s\n", I2C_DEVICE);
    close(fd);
    return 0;
}

int test_spi() {
    int fd;
    
    printf("Testing SPI interface...\n");
    
    fd = open(SPI_DEVICE, O_RDWR);
    if (fd < 0) {
        printf("Failed to open SPI device: %s\n", SPI_DEVICE);
        return -1;
    }
    
    printf("SPI device opened successfully: %s\n", SPI_DEVICE);
    close(fd);
    return 0;
}

int test_gpio() {
    FILE *fp;
    
    printf("Testing GPIO interface...\n");
    
    // Export GPIO pin 18 for testing
    fp = fopen("/sys/class/gpio/export", "w");
    if (fp != NULL) {
        fprintf(fp, "18");
        fclose(fp);
        printf("GPIO pin 18 exported successfully\n");
        
        // Unexport the pin
        fp = fopen("/sys/class/gpio/unexport", "w");
        if (fp != NULL) {
            fprintf(fp, "18");
            fclose(fp);
            printf("GPIO pin 18 unexported\n");
        }
        return 0;
    } else {
        printf("Failed to access GPIO interface\n");
        return -1;
    }
}

int main() {
    printf("===========================================\n");
    printf("Custom Raspberry Pi Hardware Test App\n");
    printf("===========================================\n");
    
    test_i2c();
    printf("\n");
    
    test_spi();
    printf("\n");
    
    test_gpio();
    printf("\n");
    
    printf("Hardware interface tests completed!\n");
    printf("===========================================\n");
    
    return 0;
}