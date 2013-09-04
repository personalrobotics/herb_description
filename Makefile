OR_URDF=$(shell rospack find or_urdf)/scripts/load.py
PARAMS_POSTPROCESS=./scripts/postprocess_params.py
XACRO_POSTPROCESS=./scripts/postprocess_xacro.py
RM=rm -f

TARGETS=robots/herb.urdf robots/herb.srdf ordata/robots/herb.kinbody.xml
COMPONENTS=robots/herb_base.urdf.xacro robots/bh280.urdf.xacro robots/wam.urdf.xacro
PACKAGE=herb_description

.PHONY: all clean
.SECONDARY:

all: $(TARGETS)

clean:
	$(RM) $(TARGETS) $(COMPONENTS)

ordata/robots/herb.kinbody.xml: robots/herb.urdf
	$(OR_URDF) load.py $< $@

robots/herb.urdf: $(COMPONENTS)

# Wrap the URDF in an xacro macro.
%.urdf.xacro: %_raw.urdf
	$(XACRO_POSTPROCESS) --name=$(notdir $*) --package=$(PACKAGE) $< $@

# Insert parameters (i.e. joint limits, inertias).
robots/wam_raw.urdf: robots/WAM_URDF.URDF config/wam_params.urdf
	$(PARAMS_POSTPROCESS) $^ $@

robots/bh280_raw.urdf: robots/BHD280_URDF.URDF config/bh280_params.urdf
	$(PARAMS_POSTPROCESS) $^ $@

robots/herb_base_raw.urdf: robots/HERB_BASE_URDF.URDF config/herb_params.urdf
	$(PARAMS_POSTPROCESS) $^ $@

# General rules.
%: %.xacro
	rosrun xacro xacro.py $< > $@
