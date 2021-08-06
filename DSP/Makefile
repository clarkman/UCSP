
MYBIN = $(HOME)/bin/

QFPROC = qfproc
QFPROC_TARGET =$(addprefix $(MYBIN),$(QFPROC))

QFMATLABMAKE = Matlab.mak
QFMATLABMAKE_TARGET =$(addprefix $(MYBIN),$(QFMATLABMAKE))

ifdef MATLAB
  MEX_TARGS = sql2datenum.$(MEX_ARCH)
endif

all: $(QFPROC_TARGET) $(QFMATLABMAKE_TARGET) $(MEX_TARGS)
	$(MAKE) -C @TimeData all
	$(MAKE) -C @FrequencyData all
	$(MAKE) -C @FrequencyTimeData all

sql2datenum.$(MEX_ARCH) : sql2datenum.c
	mex -DQF_MEX -lm -f $(MATLAB)/bin/mexopts.sh -g $<


$(QFPROC_TARGET): ./$(QFPROC)
	cp ./$(QFPROC) $(MYBIN)

$(QFMATLABMAKE_TARGET): ./$(QFMATLABMAKE)
	cp ./$(QFMATLABMAKE)  $(MYBIN)

clean:
	rm -f $(MEX_TARGS)
	$(MAKE) -C @TimeData clean
	$(MAKE) -C @FrequencyData clean
	$(MAKE) -C @FrequencyTimeData clean
	
clobber: clean
	$(MAKE) -C @TimeData clobber
	$(MAKE) -C @FrequencyData clobber
	$(MAKE) -C @FrequencyTimeData clobber


clobberall: clobber
	$(MAKE) -C @TimeData clobberall
	$(MAKE) -C @FrequencyData clobberall
	$(MAKE) -C @FrequencyTimeData clobberall


