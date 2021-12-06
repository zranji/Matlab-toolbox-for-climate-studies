# program name
PROGS =      gribsimp 

# destination
DEST      = ../bin

# source files

SRC      = apply_bitmap.c \
	   exit_handler.c \
           fill_tables.c \
           gbyte.c      \
	   gribdec.c \
           gribgetbds.c \
           gribgetbms.c \
           gribgetgds.c \
           gribgetpds.c \
	   gribsimp.c \
           init_struct.c \
           hdr_print.c \
           printer.c \
           prt_err.c 

# object files
OBJ      = gribsimp.o \
	   gribdec.o \
           gribgetbds.o \
           gribgetbms.o \
           gribgetgds.o \
           gribgetpds.o \
           gbyte.o      \
           init_struct.o \
           hdr_print.o \
           prt_err.o \
           printer.o \
           fill_tables.o \
	   apply_bitmap.o \
	   exit_handler.o

# includes
INCLUDES	= -I../include

# compile and link flags
CFLAGS        = $(INCLUDES)

CC         = gcc

RM =      /bin/rm -f

LDFLAGS      = -lm

all: $(PROGS)

# create the executable
$(PROGS):	      $(OBJ)
			         @echo "Linking $(PROGS)..."
			         $(CC) $(CFLAGS) $(OBJ) -o $(DEST)/$(PROGS) $(LDFLAGS)
			         @echo "done"

print_all:
			a2ps Makefile $(SRC)

clean:
			-$(RM) *.o $(PROGS)

###
gribsimp.o: ../include/grib.h ../include/tables.h
gribdec.o: ../include/grib.h
gribgetpds.o: ../include/grib.h
gribgetgds.o: ../include/grib.h
gribgetbms.o: ../include/grib.h
gribgetbds.o: ../include/grib.h
gbyte.o: ../include/grib.h
init_struct.o: ../include/grib.h
apply_bitmap.o: ../include/grib.h
exit_handler.o: ../include/grib.h ../include/tables.h
fill_tables.o: ../include/grib.h ../include/tables.h
hdr_print.o: ../include/grib.h
printer.o: ../include/grib.h ../include/tables.h
prt_errs.o: ../include/grib.h 
