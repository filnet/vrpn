
#############################################################################
# 
#  makefile for vrpn library
#
#  targets:
#	lib - Make the library
#
# revision history:
#
#  rich holloway	04/18/91	first version
#
#############################################################################

#
# common definitions
#

# commands
CC = g++
#CC = /usr/local/lib/CenterLine/bin/CC
makefile = makefile
MAKE = make -f $(makefile)
HW_OS = `/usr/local/bin/hw_os`
SHELL = /bin/sh

#
# main directories
#
HMD_DIR 	 = /afs/cs.unc.edu/proj/hmd
LIB_DIR 	 = $(HMD_DIR)/lib/$(HW_OS)
INCLUDE_DIR 	 = $(HMD_DIR)/include

BETA_DIR 	 = /afs/cs.unc.edu/proj/hmd/beta
BETA_LIB_DIR 	 = $(BETA_DIR)/lib/$(HW_OS)
BETA_INCLUDE_DIR  = $(BETA_DIR)/include

# subdirectories for make
OBJECT_DIR 	= $(HW_OS)

PXPL4_DIR 	= /usr/proj/pxpl
#PXPL5_DIR 	= /unc/pxpl5
PXPL5_DIR 	= /unc/pxpl5/beta

#
# flags
#
# {INCLUDE,LD}_FLAGS and LIBS are only defined for recursive pass
#
LINT_FLAGS 	= $(INCLUDE_FLAGS)
CFLAGS 		= -g $(INCLUDE_FLAGS)

#LIBS_5		= $(PXPL5_DIR)/lib/rc_mgp.o $(PXPL5_DIR)/lib/pg_gp.o \
		  -lv -ltracker -lad -lquat -ljoy -lphive -ljoy \
		  -lrc -lhostros -lring -lm

LIBS_5		= -lad -lquat -ljoy -lphive -ljoy -larm -lsdi -lm

LDFLAGS_5 	= -L. -L$(LIB_DIR) -L$(PXPL5_DIR)/lib

INCLUDE_FLAGS_5 = -I. -I$(INCLUDE_DIR) -I$(PXPL5_DIR)/include \
		  -I/usr/include/bsd

# files
LIB = libvrpn.a

#############################################################################
#
# implicit rule for all .C files
#
.SUFFIXES: .h .c .C
.c.o:
	@/bin/rm -f $@
	$(CC) -c $(CFLAGS) $<
	@chmod 664 $@

.C.o:
	@/bin/rm -f $@
	$(CC) -c $(CFLAGS) $<
	@chmod 664 $@

#############################################################################
#
# adlib stuff
#

#
# lib
#

LIB_FILES =  vrpn_Connection.C vrpn_Tracker.C vrpn_Button.C
LIB_OBJECTS =  vrpn_Connection.o vrpn_Tracker.o vrpn_Button.o

LIB_INCLUDES = vrpn_Connection.h vrpn_Tracker.h vrpn_Button.h

lib$(SUFFIX) : $(OBJECT_DIR)
	@$(MAKE) "EXE_NAME = $(LIB)" \
		"TARGET_INCLUDES = $(LIB_INCLUDES)" \
		"TARGET_OBJECTS = $(LIB_OBJECTS)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		doTheRest

#
# main rule for building library
#
$(LIB) : $(LIB_OBJECTS)
	@echo "Building $@..."
	@/bin/rm -f $@
	ar ruv $@ $(LIB_OBJECTS)
	-ranlib $@
	@chmod 664 $@

$(LIB_OBJECTS) : $(LIB_INCLUDES)

#############################################################################
#
# gory details:
#
#   the following rules handle most of the work of making an 
#   application for any architecture.
#
#  Explanation:
#
#   initially, PREFIX is defined to be some non-empty string so that the
#	rule $(PREFIX)$(EXE_NAME) is not defined at the same time that
#	the rule at the top with the same name is.  For example, for
#	"user":  user is defined at the top, with a rule that spawns off
#	make "blah blah" user ("user" is the eventual target, via the 
#	EXE_NAME macro and the calls to "doTheRest" and "mainTarget").
#	If there were no PREFIX and SUFFIX, one of the invocations of "make"
#	would see two rules for "user".  By setting PREFIX initially to
#	be nonblank, the second rule for user is covered up initially, 
#	and by setting SUFFIX in the first rule, the first rule is covered
#	up thereafter.
#
#   finally, the library rule is different, since the target name "lib" is
#	different from the actual executable to be made, so we leave
#	PREFIX and SUFFIX unchanged for that one.
#	
#
#############################################################################

doTheRest :
	@( if [ $(HW_OS) = "vax_ultrix" ] ; \
	   then \
	   	$(MAKE) \
		"TARGET_INCLUDES = $(TARGET_INCLUDES)" \
		"TARGET_OBJECTS = $(TARGET_OBJECTS)" \
		"INCLUDE_FLAGS = $(INCLUDE_FLAGS_4)" \
		"LDFLAGS = $(LDFLAGS_4)" \
		"LIBS = $(LIBS_4)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		"EXE_NAME = $(EXE_NAME)" \
		mainTarget ; \
	   else \
	   	$(MAKE) \
		"TARGET_INCLUDES = $(TARGET_INCLUDES)" \
		"TARGET_OBJECTS = $(TARGET_OBJECTS)" \
		"INCLUDE_FLAGS = $(INCLUDE_FLAGS_5)" \
		"LDFLAGS = $(LDFLAGS_5)" \
		"LIBS = $(LIBS_5)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		"EXE_NAME = $(EXE_NAME)" \
		mainTarget ; \
	   fi )


PREFIX = space_holder1
TARGET_OBJECTS = space_holder2

mainTarget :
	@echo "Moving objects from $(OBJECT_DIR) to current directory..."
	@-/bin/rm -f $(EXE_NAME) *.o *.a 2> /dev/null
	@-/bin/mv -f $(OBJECT_DIR)/$(EXE_NAME) $(OBJECT_DIR)/*.o \
		$(OBJECT_DIR)/*.a . 2> /dev/null
	@echo "Making $(EXE_NAME)..."
	@-$(MAKE) \
		"TARGET_INCLUDES = $(TARGET_INCLUDES)" \
		"TARGET_OBJECTS = $(TARGET_OBJECTS)" \
		"INCLUDE_FLAGS = $(INCLUDE_FLAGS)" \
		"LDFLAGS = $(LDFLAGS)" \
		"LIBS = $(LIBS)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		$(EXE_NAME)
	@echo "Moving objects back to $(OBJECT_DIR) subdir..."
	@-/bin/mv -f $(EXE_NAME) *.[oa] $(OBJECT_DIR) 2> /dev/null
	@echo "Done.  Executable (if any) is in $(OBJECT_DIR)/$(EXE_NAME)."

$(PREFIX)$(EXE_NAME) : $(LIB) $(TARGET_OBJECTS)
	$(CC) -o $(EXE_NAME) $(TARGET_OBJECTS) $(LDFLAGS) $(LIBS)

$(TARGET_OBJECTS) : $(TARGET_INCLUDES)


#############################################################################
#
# rule for making subdirs of the appropriate name
#
#############################################################################

$(OBJECT_DIR) :
	@-mkdir $(OBJECT_DIR)
	@echo "Made subdir '$(OBJECT_DIR)'."


#############################################################################
#
# misc rules
#


lint : 
	@( if [ $(HW_OS) = "vax_ultrix" ] ; \
	   then \
	   	$(MAKE) \
		"TARGET_INCLUDES = $(TARGET_INCLUDES)" \
		"TARGET_OBJECTS = $(TARGET_OBJECTS)" \
		"INCLUDE_FLAGS = $(INCLUDE_FLAGS_4)" \
		"LDFLAGS = $(LDFLAGS_4)" \
		"LIBS = $(LIBS_4)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		"TARGET = $(EXE_NAME)" \
		doLint ; \
	   else \
	   	$(MAKE) \
		"TARGET_INCLUDES = $(TARGET_INCLUDES)" \
		"TARGET_OBJECTS = $(TARGET_OBJECTS)" \
		"INCLUDE_FLAGS = $(INCLUDE_FLAGS_5)" \
		"LDFLAGS = $(LDFLAGS_5)" \
		"LIBS = $(LIBS_5)" \
		"PREFIX = $(PREFIX)" \
		"SUFFIX = $(SUFFIX)" \
		"EXE_NAME = $(EXE_NAME)" \
		doLint ; \
	   fi )

doLint :
	lint $(LINT_FLAGS) $(SIMPLE_FILES) $(LIB_FILES) | more

# rcs control
RCS_TMP = .rcs.tmp
RCS_FILES = $(LIB_FILES) $(LIB_INCLUDES) $(USER_FILES) $(USER_INCLUDES) \
		$(makefile)

#
# this ugly rule is a hack to get around the constant prompting "re-use the 
#   same log message?" by rcs
#
# we cat messge into a temp file, cat a quoted version into a shell var
#  (eval evaluates what's in the quotes), then use a quoted version as
#  an arg to "ci"
#
ci:
	@echo rcs files = $(RCS_FILES)
	@echo "Enter log message for ALL files (terminate with ^D):"
	@cat > $(RCS_TMP)
	@echo 'Doing check-in;  this may take a while...'
	@-( eval msg='`cat $(RCS_TMP)`'; \
		/usr/local/bin/ci -f -u -q -m"$$msg" $(RCS_FILES) )
	@echo 'Done.'
	@/bin/rm -f $(RCS_TMP)

# check out
co :
	@echo "Checking out all files..."
	@-co -l -q $(RCS_FILES)
	@echo "Done."

# check in a copy, then check out again
cio : 
	@$(MAKE) ci
	@$(MAKE) co
		

clean :
	/bin/rm -f *.o *.a *~ *.j foo stack.gp gpdump* a.out user \
	$(OBJECT_DIR)/user parser.ad_yy.c parser.tab.c


bin :
	mv $(OBJECT_DIR)/ad_diags $(HMD_DIR)/bin/$(HW_OS)/ad_diags

allclean :
	$(MAKE) clean
	/bin/rm -f $(OBJECT_DIR)/*

# install in lib dir
install : 
	$(MAKE) allclean
	$(MAKE) lib
	mv $(OBJECT_DIR)/$(LIB) $(LIB_DIR)
	-ranlib $(LIB_DIR)/$(LIB)
	echo "Copying new includes..."
	( cd $(INCLUDE_DIR) ; rm $(LIB_INCLUDES) )
	cp $(LIB_INCLUDES) $(INCLUDE_DIR)
	$(MAKE) clean

# install into beta lib dir
beta : 
	-$(MAKE) lib && \
	 $(MAKE) install_beta

install_beta :
	mv $(OBJECT_DIR)/$(LIB) $(BETA_LIB_DIR)
	-ranlib $(BETA_LIB_DIR)/$(LIB)
	-( cd $(BETA_INCLUDE_DIR); \
 		/bin/rm -f $(LIB_INCLUDES) )
	cp $(LIB_INCLUDES) $(BETA_INCLUDE_DIR) 
