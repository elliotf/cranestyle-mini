all: render

define test_template

render: renders/$(1)

renders/$(1) : for_render/$(1).scad
	openscad-nightly -m make -o $$@.stl $$^ && echo $$^

.PHONY : renders/$(1)

endef

scads := $(foreach scad, $(wildcard for_render/*.scad),$(patsubst %.scad,%,$(notdir $(scad))))

$(foreach scad, $(scads), $(eval $(call test_template,$(scad))))
