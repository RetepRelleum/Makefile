TARGET_EXEC 	?=
PATHS 			?= 
INO				?=	

define newline


endef

BUILD_DIR 		?= build
SRC_DIRS 		?= src

PATHS_BUILD		:=$(addprefix -L,$(PATHS))
PATHS_BUILD 	:=$(addsuffix /$(BUILD_DIR)/$(SRC_DIRS),$(PATHS_BUILD))

PATHS_MAKE 		:= $(addprefix -C,$(PATHS))

PATHS_MAKE_CLEAN :=$(addsuffix ',$(PATHS))
PATHS_MAKE_CLEAN :=$(addprefix ',$(PATHS_MAKE_CLEAN))

#rename the ino file to cpp 

INOS:=$(shell find $(SRC_DIRS) -name *.ino )
INO1:=$(INOS:%.ino=%.cpp)
ifdef INOS
$(file >  $(INO1), #include "Arduino.h" $(newline) $(file < $(INOS))  )
endif

SRCS := $(shell find $(SRC_DIRS) -name *.cpp -or -name *.c -or -name *.s )
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
ifdef PATHS
INC_DIRS += $(shell find $(addsuffix /$(SRC_DIRS),$(PATHS) ) -type d)
endif
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS ?= $(INC_FLAGS) $(PATHS_BUILD) -MMD -MP -shared -lpthread -g 

$(BUILD_DIR)/$(TARGET_EXEC):$(PATHS_MAKE) $(OBJS)

ifdef TARGET_EXEC
	-$(MKDIR_P) $(dir $(TARGET_EXEC))
	$(CXX) -pthread -g $(foreach wrd,$(PATHS) . , $(shell find $(wrd)/$(BUILD_DIR) -name *.o) )-o $(TARGET_EXEC) $(LDFLAGS)  
	#-lX11 -lm
endif
# delete the ino file 
ifdef INOS
#	$(RM) $(INO1) 
endif

# assembly
$(BUILD_DIR)/%.s.o: %.s
	$(MKDIR_P) $(dir $@)
	$(AS) $(ASFLAGS) -c $< -o $@

# c source
$(BUILD_DIR)/%.c.o: %.c
	$(MKDIR_P) $(dir $@)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# c++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	$(MKDIR_P) $(dir $@)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

$(PATHS_MAKE):
	$(MAKE)  $@  

.PHONY: clean 

clean: $(PATHS_MAKE_CLEAN)
	$(RM) -r $(BUILD_DIR)

$(PATHS_MAKE_CLEAN):
	$(MAKE) -C $@ clean 

-include $(DEPS)

MKDIR_P ?= mkdir -p

