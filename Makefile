# Build RabbitMQ in Action 
BOOK_NAME=RabbitMQ in Action
BOOK_FILE=rabbitmq_in_action
TOC=toc
CHAPTERS=$(shell ls -d chapter-*)
CHAPTER_FILES_MD := $(foreach chapter, $(CHAPTERS), $(chapter)/$(chapter).md)
CHAPTER_FILES_PDF := $(foreach chapter, $(CHAPTERS), $(chapter)/$(chapter).pdf)
NUM:=0
.PHONY: new_chapter

all: all_chapters book packzip

new_chapter:
ifeq ($(NUM), 0)
	@echo "Must pass NUM=x argument to 'make new_chapter'."
else
	@if test -d chapter-$(NUM); then \
		echo "Chapter $(NUM) already exists. Exiting."; \
	else \
		echo "Creating chapter-$(NUM)"; \
		mkdir chapter-$(NUM); \
		cd chapter-$(NUM); \
		ln -s ../Makefile.chapter Makefile; \
		echo -e "# Chapter Title #\n\n## My first cool section ##\n\n" > chapter-$(NUM).md; \
	fi
endif

packzip:
	ditto -ck --rsrc --sequesterRsrc examples rabbitmq_in_action_examples.zip

all_chapters:
	@for i in $(CHAPTERS); do \
	echo "Make all chapters in $$i..."; \
	(cd $$i; make all;) done

book: all_chapters
#		DocBook
		@echo Making $(BOOK_NAME) in DocBook
		pandoc -r markdown -s -w docbook -o $(BOOK_FILE).xml $(TOC).md $(CHAPTER_FILES_MD)
#		PDF
		@echo Making $(BOOK_NAME) in PDF
		markdown2pdf $(TOC).md -o $(TOC).pdf
		texexec --purgeall --pdfarrange --result=$(BOOK_FILE) $(TOC).pdf $(CHAPTER_FILES_PDF)
		rm $(BOOK_FILE).log
