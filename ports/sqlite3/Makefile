CFLAGS=-fPIC -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_OMIT_WAL -DSQLITE_OMIT_RANDOMNESS -DSQLITE_OMIT_AUTHORIZATION -DSQLITE_OMIT_DEPRECATED

all: libsqlite3.a libsqlite3.so

libsqlite3.a: sqlite3.o
	$(AR) rcs $@ sqlite3.o

libsqlite3.so: sqlite3.o
	$(CC) -shared sqlite3.o -o $@

sqlite3.o: sqlite3.h
