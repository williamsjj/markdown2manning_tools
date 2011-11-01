# Markdown 2 Manning #

(C) [Jason Williams](mailto:jasonjwilliams@gmail.com) & [Alvaro Videla](mailto:videlalvaro@gmail.com), All Rights Reserved. Distributed under the BSD license.

These tools will allow you to convert Markdown w/ Pandoc Extensions to PDF and Manning Publishing's version of DocBook.

Currently they allow you to:

* Create chapter stubs compatible with the tools.
* Convert single chapters to PDF and/or Manning DocBook (with validation against Manning schema).
* Convert all chapters into individual PDFs and/or Manning DocBook.
* Build a single PDF representing the whole book containing all chapters.
* Publish any chapter directly to Manning's LiveBook site.

# Required Software #

__IMPORTANT:__ We now use Manning's Agile Author PDF maker (you get Manning ready PDFs as a result)! Please read how to install below.

* Agile Author PDF Maker: We can't distribute this. But you can get it from Manning (or email us and we'll help) if you're an author.
	* To install: Unpack the AA PDF maker archive into __AAMakePDF/__ in the root directory of this repo.
* Agile Author Validator: We can't distribute this either. But you can get it from Manning (or email us and we'll help) if you're an author.
	* To install: Unpack the AA validator archive into __validator/__ in the root directory of this repo.
* TexLive or MacTex (I use MacTex) - Required for PDF generation
	* TexLive: [http://tug.org/texlive/](http://tug.org/texlive/)
	* MacTex: [http://www.tug.org/mactex/](http://www.tug.org/mactex/)
* Haskell
	* For most platforms this is the easy way: [http://hackage.haskell.org/platform/](http://hackage.haskell.org/platform/)
* Pandoc 1.8 - Converts Markdown and Pandoc extended Markdown to other formats (PDF/Docbook)
	* Once you've got Haskell installed, run:
		* cabal update
		* cabal install pandoc
		* NB: pandoc will throw some warnings regarding deprecated functions that we plan to fix later
	* [http://johnmacfarlane.net/pandoc/index.html](http://johnmacfarlane.net/pandoc/index.html)	
* xmllib2 - Specifically we need the __xsltproc__, __xpath__ and __xmllint__ programs.
* curl
* GNU make
* GNU awk
* GNU sed

# Creating a new book #

* Check out this repository.
* Make a new directory for your book somewhere on your computer (e.g. /book/mycoolbook)
* Copy the entire contents of this repository into your book directory.
* Change to your new book directory.
* Run __echo X > BOOK\_ID__ where X is your book's number in Manning LiveBook.
* Run __echo "XYZ" > LIVEBOOK\_URL__ where XYZ is the full URL to the chapter addition page in LiveBook.
* Edit __Makefile__ :
	*  change _BOOK\_NAME_ to the name of your book (i.e. RabbitMQ in Action)
	*  change _BOOK\_FILE_ to the filename (without extension) you want your single book PDF to have
* Edit __toc.md__ and change the title, author and date info to match (multi-authors separated by ";")
* Create your first chapter by running __make new\_chapter NUM=1__
* You should now have a directory in your book called __./chapter-1/__ with a file inside called __chapter-1.md__
* Change directories into __./chapter-1/__, and let's make your first PDF and DocBook: run __make__
* You should now have a chapter-1.pdf and chapter-1.xml


# Things to know about markdown2manning #

* Chapters must be in directories called "chapter-X" where X is the chapter number.
* Chapter files themselves must be in their "chapter-X" directory and named "chapter-X.md".
* Put chapter images inside the chapter directory for the chapter they belong to (.png, .jpg, and .gif are supported)
* Only use the single # section for chapter title at the beginning of a file (all other sections should use at least ## ):

Example:

	# Chapter 1 #

# Extended Markdown Syntax #

By default, we support the Pandoc extensions to markdown. There are also a few other extensions to markdown we've added specific to authoring Manning books:

* __Code Listings__: Using the syntax below will create a titled code listing (make sure there are at least 3 tildas). Note that you don't have to put the listing number in the title, it will be automatically created for you when the XML and PDF are generated. The normal markdown syntax for [code blocks](http://daringfireball.net/projects/markdown/syntax#precode) will create a code snippet instead.

Example:
    ~~~~~~~~~{title="My cool code example"}
    import foo
    
    foo.super\_print("Ain't this rockin'?")
    ~~~~~~~~~


* __Callouts__: Inside of a code listing, you can use special comment syntax to create a "callout". This will convert the comment when formatted into a number placed next to the section with your comment text as the explanation. It will also allow you to reference the callout number in your explanatory paragraphs below the code listing. The syntax is <code>#/(calloutID) Comment text.</code> __calloutID__ can be any string without spaces you want and must be unique across all of your callouts.

Example:
    ~~~~~~~~~{title="Anti-Gravity Machine"}
    import grav\_neutralizer
    
    g = grav\_neutralizer() #/(agm.1) Initialize the neutralizer.
    g.activate() #/(agm.2) Start repelling gravity.
    ~~~~~~~~~

# Command Reference #

* Book Commands (run from the book's root directory)
	* __make new\_chapter NUM=x__ - Creates a new chapter stub where x is the chapter number.
	* __make all\_chapters__ - Runs "make" inside of all the chapter directories.
	* __make book__ - Creates a single PDF
* Chapter Commands (run from inside an individual chapter directory)
	* __make__ or __make all__ - Create PDF and Manning DocBook versions of the chapter.
	* __make pdf__ - Create PDF version only of the chapter.
	* __make docbook__ - Create Manning DocBook versions of the chapter (validates against Manning schema).
	* __make publish__ - Re-create the Manning DocBook version of the chapter, ZIP it up with the images in the directory and upload it to Manning LiveBook


# Using Markdown w/ Pandoc Extensions #

The Pandoc extensions to Markdown allow you to create tables, insert cross-references, add footnotes, and sanely insert images. You can also insert inline TeX commands if you're so inclined (\\newpage is a very useful TeX command for positioning tables and images). Checkout the Pandoc Markdown syntax reference below:

* [Pandoc Markdown Extensions syntax reference](http://johnmacfarlane.net/pandoc/README.html#pandocs-markdown-vs.standard-markdown)
* [Standard Markdown syntax reference](http://daringfireball.net/projects/markdown/syntax)