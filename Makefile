#====================================================================#
#Output files
EXECUTABLE=stm32_executable.elf
BIN_IMAGE=stm32_bin_image.bin

#======================================================================#
#Cross Compiler
CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

#======================================================================#
#Flags
CFLAGS=-Wall -mlittle-endian -mthumb -std=c11 --specs=nosys.specs
CFLAGS+=-mcpu=cortex-m3
CFLAGS+=-D USE_STDPERIPH_DRIVER
CFLAGS+=-D STM32F10X_MD


#stm32-flash
CFLAGS+=-Wl,-T,stm32f103c8t6_flash.ld

#======================================================================#
#Libraries

#Stm32 libraries
CMSIS_CORE_LIB=./lib/CMSIS/CM3/CoreSupport
CMSIS_DEVICE_LIB=./lib/CMSIS/CM3/DeviceSupport/ST/STM32F10x
ST_LIB=./lib/STM32F10x_StdPeriph_Driver
CoOS_LIB=./lib/CoOS

CFLAGS+=-I$(CMSIS_CORE_LIB)
CFLAGS+=-I$(CMSIS_DEVICE_LIB)
CFLAGS+=-I$(ST_LIB)/inc
CFLAGS+=-I$(CoOS_LIB)/kernel
CFLAGS+=-I$(CoOS_LIB)/portable

#User libraries
CFLAGS+=-I./app/inc

#======================================================================#
#setup system clock
SRC=$(CMSIS_DEVICE_LIB)/system_stm32f10x.c
#StdPeriph
SRC+=$(ST_LIB)/src/misc.c \
	$(ST_LIB)/src/stm32f10x_rcc.c \
	$(ST_LIB)/src/stm32f10x_usart.c \
	$(ST_LIB)/src/stm32f10x_gpio.c

#CoOS
SRC+=$(CoOS_LIB)/kernel/core.c \
	$(CoOS_LIB)/kernel/event.c \
	$(CoOS_LIB)/kernel/flag.c \
	$(CoOS_LIB)/kernel/hook.c \
	$(CoOS_LIB)/kernel/kernelHeap.c \
	$(CoOS_LIB)/kernel/mbox.c \
	$(CoOS_LIB)/kernel/mm.c \
	$(CoOS_LIB)/kernel/mutex.c \
	$(CoOS_LIB)/kernel/queue.c \
	$(CoOS_LIB)/kernel/sem.c \
	$(CoOS_LIB)/kernel/serviceReq.c \
	$(CoOS_LIB)/kernel/task.c \
	$(CoOS_LIB)/kernel/time.c \
	$(CoOS_LIB)/kernel/timer.c \
	$(CoOS_LIB)/kernel/utility.c \
	$(CoOS_LIB)/portable/arch.c \
	$(CoOS_LIB)/portable/GCC/port.c

#Major programs
USER_SRC_DIR=./app/src

SRC+=$(USER_SRC_DIR)/main.c \
	$(USER_SRC_DIR)/led.c \
	$(USER_SRC_DIR)/uart.c \
	$(USER_SRC_DIR)/SYN6288.c \
	$(USER_SRC_DIR)/gpio.c

#======================================================================#
#STM32 startup file
STARTUP=$(CMSIS_DEVICE_LIB)/startup/gcc_ride7/startup_stm32f10x_md.s


#======================================================================#
#Make rules

#Make all
all:$(BIN_IMAGE)

$(BIN_IMAGE):$(EXECUTABLE)
	$(OBJCOPY) -O binary $^ $@

STARTUP_OBJ = startup_stm32f10x_md.o

$(STARTUP_OBJ): $(STARTUP)
	$(CC) $(CFLAGS) $^ -c $(STARTUP)

$(EXECUTABLE):$(SRC) $(STARTUP_OBJ)
	$(CC) $(CFLAGS) $^ -o $@

#Make clean
clean:
	rm -rf $(STARTUP_OBJ)
	rm -rf $(EXECUTABLE)
	rm -rf $(BIN_IMAGE)

#======================================================================
.PHONY:all clean
