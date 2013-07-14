SW2URDF_POSTPROCESS=./scripts/postprocess_sw2urdf.py
RM=rm -f

TARGETS=robots/herb.urdf ordata/robots/herb.kinbody.xml
COMPONENTS=robots/herb_base.urdf.xacro robots/bh280.urdf.xacro robots/wam.urdf.xacro
PACKAGE=herb_description
HERB_COLOR=0.792 0.820 0.9333 1.0
WAM_COLOR=0.878 0.949 1.0 1.0

.PHONY: all clean

all: $(TARGETS)

clean:
	$(RM) $(TARGETS) $(COMPONENTS)

ordata/robots/herb.kinbody.xml: robots/herb.urdf
	rosrun or_urdf load.py $< $@

robots/herb_base.urdf.xacro: robots/HERB_BASE_URDF.URDF
	$(SW2URDF_POSTPROCESS) --name=herb_base --package=$(PACKAGE) --color $(HERB_COLOR) $< $@

robots/bh280.urdf.xacro: robots/BHD_URDF_280.URDF
	$(SW2URDF_POSTPROCESS) --name=bh280 --package=$(PACKAGE) --color $(WAM_COLOR) $< $@

robots/wam.urdf.xacro: robots/WAM_URDF.URDF 
	$(SW2URDF_POSTPROCESS) --name=wam --package=$(PACKAGE) --color $(WAM_COLOR) $< $@

%.urdf: %.urdf.xacro
	rosrun xacro xacro.py $< > $@
