CORE_PATH:=$(OPENWCH_PATH)/EVT/EXAM/SRC

INCLUDES:=
DEFINES:=
C_SRC:=
A_SRC:=
CFLAGS:=
CXXFLAGS:=
LDFLAGS:=

-include $(EXAMPLE)/$(notdir $(EXAMPLE)).mk

MK_INC:=$(foreach d, $(USE), $(wildcard $(d)/$(notdir $(d)).mk))

USE_FLOAT:=y

-include $(MK_INC)

C_SRC+=$(wildcard $(EXAMPLE)/*/*.c)
C_SRC+=$(wildcard $(EXAMPLE)/*/*/*.c)

CXX_SRC+=$(wildcard $(EXAMPLE)/*/*.cpp)
CXX_SRC+=$(wildcard $(EXAMPLE)/*/*/*.cpp)

H_APP:=$(wildcard $(EXAMPLE)/*/*/*.h)
H_APP+=$(wildcard $(EXAMPLE)/*/*.h)

C_SRC+=$(foreach d, $(USE), $(wildcard $(d)/*.c))

CXX_SRC+=$(foreach d, $(USE), $(wildcard $(d)/*.cpp))

C_SRC+=$(wildcard $(CORE_PATH)/Peripheral/src/*.c)
ifeq ($(findstring debug.c, $(C_SRC)),)
C_SRC+=$(wildcard $(CORE_PATH)/Debug/*.c)
endif
C_SRC+=$(wildcard $(CORE_PATH)/Core/*.c)

LD_SCRIPT:=$(wildcard $(EXAMPLE)/Ld/Link.ld)

ifeq ($(LD_SCRIPT),)
LD_SCRIPT:=$(CORE_PATH)/Ld/Link.ld
endif

A_SRC+=$(CORE_PATH)/Startup/startup_ch32v30x_D8C.S

INCLUDES+=$(CORE_PATH)/Debug
INCLUDES+=$(CORE_PATH)/Core
INCLUDES+=$(CORE_PATH)/Peripheral/inc
INCLUDES+=$(EXAMPLE)/User/
INCLUDES+=$(sort $(dir $(H_APP)))
INCLUDES+=$(foreach d, $(USE), $(d))

REQUIRE_NET:=$(findstring net_config.h, $(H_APP))
ifneq ($(REQUIRE_NET),)

REQUIRE_ETH_DRIVER:=$(strip $(findstring eth_driver.c, $(C_SRC)))
ifeq ($(REQUIRE_ETH_DRIVER),)
C_SRC+=$(wildcard $(OPENWCH_PATH)/EVT/EXAM/ETH/NetLib/eth_driver.c)
endif

INCLUDES+=$(OPENWCH_PATH)/EVT/EXAM/ETH/NetLib/
LIB_PATH+=$(OPENWCH_PATH)/EVT/EXAM/ETH/NetLib/
LIBS+=wchnet_float
endif

TEMPLATE_FILE:=$(file < $(EXAMPLE)/.cproject)
REQUIRE_UDISK:=$(findstring Udisk_Lib, $(TEMPLATE_FILE))
ifneq ($(REQUIRE_UDISK),)
$(info require udisklib)
FS_HS:=$(findstring USBFS, $(EXAMPLE))
$(info FS/HS: $(FS_HS) in $(EXAMPLE))
ifeq ($(FS_HS),USBFS)
$(info use FS)
UDISK_LIB_BASE:=$(OPENWCH_PATH)/EVT/EXAM/USB/USBFS/Udisk_Lib
else
$(info use HS)
UDISK_LIB_BASE:=$(OPENWCH_PATH)/EVT/EXAM/USB/USBHS/Udisk_Lib
endif

C_SRC+=$(UDISK_LIB_BASE)/CH32V103UFI.c
INCLUDES+=$(UDISK_LIB_BASE)/
LIB_PATH+=$(UDISK_LIB_BASE)/
LIBS+=RV3UFI
USE_FLOAT:=n

endif

DEFINES+=

ifeq ($(USE_FLOAT),y)
ARCH=-march=rv32imafc -mabi=ilp32f
else
ARCH=-march=rv32imac -mabi=ilp32
endif

COMMON_FLAGS:=$(ARCH) -Og -g3
COMMON_FLAGS+=$(addprefix -I,$(INCLUDES))
COMMON_FLAGS+=$(addprefix -D,$(DEFINES))
COMMON_FLAGS+=-fdata-sections -ffunction-sections

CFLAGS+=$(COMMON_FLAGS)
CFLAGS+=-std=gnu11

CXXFLAGS+=$(COMMON_FLAGS)
CXXFLAGS+=-std=gnu++17
CXXFLAGS+=-fno-rtti
CXXFLAGS+=-fno-exceptions
CXXFLAGS+=-fno-non-call-exceptions
CXXFLAGS+=-fno-threadsafe-statics

LDFLAGS+=$(ARCH)
LDFLAGS+=-T$(LD_SCRIPT)
LDFLAGS+=$(addprefix -L,$(LIB_PATH))
LDFLAGS+=$(addprefix -l,$(LIBS))
LDFLAGS+=-specs=nosys.specs
LDFLAGS+=-specs=nano.specs
LDFLAGS+=-nostartfiles
LDFLAGS+=-Wl,--print-memory-usage
LDFLAGS+=-Wl,--gc-sections

CROSS_PREFIX:=riscv-none-embed-
CC=$(CROSS_PREFIX)gcc
CXX=$(CROSS_PREFIX)g++
LD=$(if $(CXX_SRC), $(CROSS_PREFIX)g++, $(CROSS_PREFIX)gcc)
AS=$(CROSS_PREFIX)gcc -x assembler-with-cpp

PROJECT?=$(basename $(notdir $(realpath $(EXAMPLE))))

PROJECT_ELF:=$(OUT)/$(PROJECT).elf
PROJECT_HEX:=$(patsubst %.elf, %.hex, $(PROJECT_ELF))
PROJECT_BIN:=$(patsubst %.elf, %.bin, $(PROJECT_ELF))
PROJECT_LST:=$(patsubst %.elf, %.lst, $(PROJECT_ELF))
PROJECT_MAP:=$(patsubst %.elf, %.map, $(PROJECT_ELF))

LDFLAGS+=-Wl,-Map=$(strip $(PROJECT_MAP))

OBJECTS:=$(addprefix $(OUT)/, $(patsubst %.c, %.o, $(C_SRC)))
OBJECTS+=$(addprefix $(OUT)/, $(patsubst %.S, %.o, $(A_SRC)))
OBJECTS+=$(addprefix $(OUT)/, $(patsubst %.cpp, %.o, $(CXX_SRC)))

DEPS:=$(patsubst %.o, %.d, $(OBJECTS))

ifeq ($(strip $(VERBOSE)),y)
V:=
else
V:=@
endif

all: $(PROJECT_ELF) $(PROJECT_HEX) $(PROJECT_BIN) $(PROJECT_LST)

-include $(DEPS)

$(OUT)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo CC $(notdir $@)
	$(V)$(CC) -MMD $(CFLAGS) -c $< -o $@

$(OUT)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo CXX $(notdir $@)
	$(V)$(CXX) -MMD $(CXXFLAGS) -c $< -o $@

$(OUT)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo AS $(notdir $@)
	$(V)$(AS) $(CFLAGS) -c $< -o $@

$(PROJECT_ELF): $(OBJECTS)
	@mkdir -p $(dir $@)
	@echo LD $(notdir $@)
	$(V)$(LD) $(OBJECTS) $(LDFLAGS) -o $@

%.hex: %.elf
	@echo HEX $(notdir $@)
	$(V)$(CROSS_PREFIX)objcopy -O ihex $< $@

%.bin: %.elf
	@echo BIN $(notdir $@)
	$(V)$(CROSS_PREFIX)objcopy -O binary $< $@

%.lst: %.elf
	@echo LST $(notdir $@)
	$(V)$(CROSS_PREFIX)objdump -dSx $< > $@

print-%:
	@echo $*: $($*)

clean:
	@echo CLEAN
	$(V)rm -fr $(OUT)

flash: $(PROJECT_ELF)
	@echo "FLASH $(notdir $<)"
	$(V)wlink --chip CH32V30X flash $<

.PHONY: clean all flash
