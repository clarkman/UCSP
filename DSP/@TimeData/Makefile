SUBDIRS = private
AUTO_SUBDIR = 1


all:
	$(MAKE) -C private clean

clean:
	$(MAKE) -C private clean
	rm -f *.asv
	
clobber: clean
	$(MAKE) -C private clobber
	rm -f *~
	rm -f *.tmp

clobberall: clobber
	$(MAKE) -C private clobberall


