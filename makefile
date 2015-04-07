BIN := node_modules/.bin

setup:
	npm install

# SASS
STYLESRC   = ./src/sass/main.scss
STYLEOUT   = ./build/sir-trevor.css
STYLEFLAGS = --output-style compressed $(STYLESRC) $@
STYLEOBJ   = $(STYLESRC) $(wildcard ./src/sass/**/*.js ./src/sass/*.js)

# JS
SCRIPTSRC   = ./index.js
SCRIPTOUT   = ./build/sir-trevor.js
SCRIPTDEBUG = ./build/sir-trevor.debug.js
SCRIPTMIN   = ./build/sir-trevor.min.js
SCRIPTFLAGS = $(SCRIPTSRC) $@ --config ./.webpackconfig 
SCRIPTOBJ   = $(SCRIPTSRC) $(wildcard ./src/**/*.js ./src/*.js)

# Build SASS
$(STYLEOUT): $(STYLEOBJ)
	@$(BIN)/node-sass $(STYLEFLAGS)
	@$(BIN)/autoprefixer $@

.PHONY: styles
styles: $(STYLEOUT)

# Build JS
$(SCRIPTOUT): $(SCRIPTOBJ)
	@$(BIN)/webpack $(SCRIPTFLAGS)

.PHONY: js
js: $(SCRIPTOUT)

# Build debug JS
$(SCRIPTDEBUG): $(SCRIPTOBJ)
	@$(BIN)/webpack $(SCRIPTFLAGS) --debug 

.PHONY: debug
debug: $(SCRIPTDEBUG)

# Build minified JS
$(SCRIPTMIN): $(SCRIPTOUT)
	@$(BIN)/uglify -s $< -o $@

.PHONY: uglify
uglify: $(SCRIPTMIN)

.PHONY: scripts
scripts: js debug uglify

# jshint
jshint:
	@$(BIN)/jshint --config .jshintrc $(SCRIPTOBJ)

define BANNER
"/*\n\
  * Sir Trevor JS v`./$(BIN)/mversion | sed -n -e 's/^.*package\.json: //p'`\n\
  *\n\
  * Released under the MIT license\n\
  * www.opensource.org/licenses/MIT\n\
  *\n\
  * `date +%Y-%m-%d`\n\
  */"
endef

# banner
banner: 
	echo $(BANNER) | cat - $(SCRIPTOUT) > /tmp/out && mv /tmp/out $(SCRIPTOUT)

# tests
# watch

.PHONY: test
test: jshint

.PHONY: build
build: test styles scripts banner

.PHONY: dev
dev: styles $(SCRIPTDEBUG)

