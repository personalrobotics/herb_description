SW2URDF_POSTPROCESS=./scripts/postprocess_sw2urdf.py
RM=rm -f

PACKAGE=herb_description
WAM_COLOR=0.8784 0.949 1.0 1.0

.PHONY: all clean

all: robots/bh280.urdf.xacro robots/wam.urdf.xacro

clean:
	$(RM) robots/wam.urdf.xacro

robots/bh280.urdf.xacro: robots/BHD_URDF_280.URDF
	$(SW2URDF_POSTPROCESS) --name=bh280 --package=$(PACKAGE) --color $(WAM_COLOR) $< $@

robots/wam.urdf.xacro: robots/WAM_URDF.URDF 
	$(SW2URDF_POSTPROCESS) --name=wam --package=$(PACKAGE) --color $(WAM_COLOR) $< $@
