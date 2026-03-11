# Standard stuff

.SUFFIXES:
$(VERBOSE).SILENT:

MAKEFLAGS+= --no-builtin-rules
MAKEFLAGS+= --warn-undefined-variables

export hostSystemName=$(shell uname)

.PHONY: all check test format clean distclean
all: .init
	cmake --preset dev --fresh --log-level=VERBOSE
	ln -fs build/dev/compile_commands.json .
	cmake --workflow --preset dev

check:
	# run-clang-tidy -p build/dev -checks='-*,misc-header-*,misc-include-*' src/tests
	ninja -C build/dev spell-check
	#NO! ninja -C build/dev format-check

test: .init
	cmake --preset ci-${hostSystemName}
	ln -fs build/compile_commands.json .
	cmake --build build
	cmake --install build --prefix $(CURDIR)/stagedir
	cmake -G Ninja -B build/tests -S src/tests -D CMAKE_PREFIX_PATH=$(CURDIR)/stagedir \
		-D CMAKE_EXPORT_COMPILE_COMMANDS=ON
	ln -fs build/tests/compile_commands.json .
	cmake --build build/tests
	ctest --test-dir build/tests

.init: requirements.txt .CMakeUserPresets.json
	perl -p -e 's/<hostSystemName>/${hostSystemName}/;' .CMakeUserPresets.json > CMakeUserPresets.json
	-pip3 install --upgrade -r requirements.txt
	touch .init

# format:
# 	git ls-files ::*CMakeList.txt ::*.cmake ::*.cmake.in | xargs gersemi -i

clean:
	rm -rf build compile_commands.json

distclean: clean
	rm -rf stagedir .init tags *.bak CMakeUserPresets.json

GNUmakefile :: ;
*.txt :: ;
*.json :: ;

# Anything we don't know how to build will use this rule.
#
% ::
	ninja -C build/dev $@
