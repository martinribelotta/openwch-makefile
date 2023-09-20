CORE_PATH:=$(OPENWCH_PATH)/EVT/EXAM/SRC

INCLUDES:=
DEFINES:=
C_SRC:=
A_SRC:=
CFLAGS:=
LDFLAGS:=

C_SRC+=$(wildcard $(OPENWCH_PATH)/$(EXAMPLE)/*/*.c)
C_SRC+=$(wildcard $(OPENWCH_PATH)/$(EXAMPLE)/*/*/*.c)

C_SRC+=$(wildcard $(CORE_PATH)/Peripheral/src/*.c)
ifeq ($(findstring debug.c, $(C_SRC)),)
C_SRC+=$(wildcard $(CORE_PATH)/Debug/*.c)
endif
C_SRC+=$(wildcard $(CORE_PATH)/Core/*.c)

LD_SCRIPT:=$(wildcard $(OPENWCH_PATH)/$(EXAMPLE)/Ld/Link.ld)

ifeq ($(LD_SCRIPT),)
LD_SCRIPT:=$(CORE_PATH)/Ld/Link.ld
endif

A_SRC+=$(CORE_PATH)/Startup/startup_ch32v30x_D8C.S

INCLUDES+=$(CORE_PATH)/Debug
INCLUDES+=$(CORE_PATH)/Core
INCLUDES+=$(CORE_PATH)/Peripheral/inc
INCLUDES+=$(OPENWCH_PATH)/$(EXAMPLE)/User/
INCLUDES+=$(sort $(dir $(wildcard $(OPENWCH_PATH)/$(EXAMPLE)/User/*/*.h)))

DEFINES+=

ARCH=-march=rv32imafc -mabi=ilp32f

CFLAGS+=$(ARCH) -Og -g3
CFLAGS+=$(addprefix -I,$(INCLUDES))
CFLAGS+=$(addprefix -D,$(DEFINES))
CFLAGS+=-fdata-sections -ffunction-sections

LDFLAGS+=$(ARCH)
LDFLAGS+=-T$(LD_SCRIPT)
LDFLAGS+=-specs=nosys.specs
LDFLAGS+=-nostartfiles
LDFLAGS+=-Wl,--print-memory-usage
LDFLAGS+=-Wl,--gc-sections

CROSS_PREFIX:=riscv-none-embed-
CC=$(CROSS_PREFIX)gcc
CXX=$(CROSS_PREFIX)g++
LD=$(CROSS_PREFIX)gcc
AS=$(CROSS_PREFIX)gcc -x assembler-with-cpp

PROJECT:=$(basename $(EXAMPLE))

OBJECTS:=$(addprefix $(OUT)/, $(patsubst %.c, %.o, $(C_SRC)))
OBJECTS+=$(addprefix $(OUT)/, $(patsubst %.S, %.o, $(A_SRC)))

PROJECT_ELF:=$(OUT)/$(PROJECT).elf
PROJECT_HEX:=$(patsubst %.elf, %.hex, $(PROJECT_ELF))
PROJECT_BIN:=$(patsubst %.elf, %.bin, $(PROJECT_ELF))
PROJECT_LST:=$(patsubst %.elf, %.lst, $(PROJECT_ELF))
PROJECT_MAP:=$(patsubst %.elf, %.map, $(PROJECT_ELF))

LDFLAGS+=-Wl,-Map=$(strip $(PROJECT_MAP))

ifeq ($(strip $(VERBOSE)),y)
V:=
else
V:=@
endif

all: $(PROJECT_ELF) $(PROJECT_HEX) $(PROJECT_BIN) $(PROJECT_LST)

$(OUT)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo CC $(notdir $@)
	$(V)$(CC) $(CFLAGS) -c $< -o $@

$(OUT)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo AS $(notdir $@)
	$(V)$(AS) $(CFLAGS) -c $< -o $@

$(PROJECT_ELF): $(OBJECTS)
	@mkdir -p $(dir $@)
	@echo LD $(notdir $@)
	$(V)$(LD) $(LDFLAGS) $(OBJECTS) -o $@

%.hex: %.elf
	@echo HEX $(notdir $@)
	$(V)$(CROSS_PREFIX)objcopy -O ihex $< $@

%.bin: %.elf
	@echo BIN $(notdir $@)
	$(V)$(CROSS_PREFIX)objcopy -O binary $< $@

%.lst: %.elf
	@echo LST $(notdir $@)
	$(V)$(CROSS_PREFIX)objdump -dsx $< > $@

print-%:
	@echo $*: $($*)

clean:
	@echo CLEAN
	$(V)rm -fr $(OUT)
