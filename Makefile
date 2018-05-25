.SUFFIXES: .html .md
.PHONY: clean upload

include config.mk

export ROOT = $(shell pwd)
VPATH = src:tmp:upload
MDAPI = /usr/bin/curl -sSk -X POST https://api.github.com/markdown/raw  -H 'Content-Type: text/plain' $(TOKEN) --data-binary @
ALL_MD_FP = $(wildcard src/*.md)
ALL_MD = $(notdir $(ALL_MD_FP))
title := $(shell grep ":title:" metadata | cut -f3 -d:)

%.html: %.md
	@echo "Compiling markdown $<"
	@$(MDAPI)$< > tmp/$@

#complete.html: %.html

final.html: $(ALL_MD:.md=.html) metadata
	@echo "Combining all html snippets"
	$(shell ./combine.sh)

all: final.html config.mk

clean: 
	rm -fr tmp/*.html
	rm upload/final.html

config: config.mk

config.mk:
	$(shell ./config.sh)

upload:
	cp upload/final.html upload/$(title).html
	$(RSYNC)	
