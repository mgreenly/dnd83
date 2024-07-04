ERB  = $(patsubst src/%,out/%,$(basename $(shell find src -type f -name '*.erb')))
HTML = $(patsubst src/%,out/%,$(shell find src -type f -iname '*.html'))
CSS  = $(patsubst src/%,out/%,$(shell find src -type f -iname '*.css'))
JS   = $(patsubst src/%,out/%,$(shell find src -type f -iname '*.js'))
PNG  = $(patsubst src/%,out/%,$(shell find src -type f -iname '*.png'))
JPG  = $(patsubst src/%,out/%,$(shell find src -type f -iname '*.jpg'))
ALL  = $(sort $(ERB) $(HTML) $(CSS) $(JS) $(PNG) $(JPG))

all: $(ALL)

# if no other rule matches there's nothing to do so we just link the target to the source
out/%: src/%
	@mkdir -p $(dir $@)
	ln $< $@

# if the source file ends in *.html we want copy it then tidy it
out/%.html: src/%.html
	@mkdir -p $(dir $@)
	cp $< $@
	tidy -quiet -indent -utf8 -modify --tidy-mark no $@

# if the source file ends in *.erb we want to process it as erb
out/%: src/%.erb ./site.rb
	@mkdir -p $(dir $@)
	erb -T - -r './site.rb' $< > $@

# if the source file ends in *.html.erb we want to process it as erb then tidy it
out/%.html: src/%.html.erb ./site.rb
	@mkdir -p $(dir $@)
	erb -T - -r './site.rb' $< > $@
	tidy -quiet -indent -utf8 -modify --tidy-mark no $@

.PHONY: publish
publish: all
	rsync \
  	--copy-links \
  	--delete \
  	-avzr out/ \
  	admin@metaspot.org:/var/www/dnd83.metaspot.org

.PHONY: sso
sso:
	aws sso login --no-browser

.PHONY: backup
backup:
	aws s3 sync src/assets/images s3://dnd83.metaspot.org/assets/images

.PHONY: restore
restore:
	aws s3 sync s3://dnd83.metaspot.org/assets/images src/assets/images

.PHONY: tidy
tidy:
	find src \( -name '*.html' -o -name '*.html.erb' \) -exec tidy -quiet -indent -utf8 -modify --tidy-mark no {} \;

.PHONY: rename
rename:
	file-rename 'y/A-Z/a-z/' src/*

.PHONY: info
info:
	@printf " ERB=$(ERB)\n"
	@printf " HTML=$(HTML)\n"
	@printf " CSS=$(CSS)\n"
	@printf "  JS=$(JS)\n"
	@printf " PNG=$(PNG)\n"
	@printf " JPG=$(JPG)\n"
	@printf " ALL=$(ALL)\n"


.PHONY: clean
clean:
	rm -rf tmp
	rm -rf out
