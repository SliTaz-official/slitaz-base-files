# Makefile for SliTaz Bugs.
#

PACKAGE="slitaz-base"
PREFIX?=/usr
LINGUAS?=fr

all: help

help:
	@echo "make [pot|msgmerge|msgfmt|install-libtaz|install-msg|install|clean]"

# i18n

pot:
	xgettext -o po/$(PACKAGE).pot -L Shell --package-name="SliTaz Base" \
		./rootfs/lib/libtaz.sh

msgmerge:
	@for l in $(LINGUAS); do \
		echo -n "Updating $$l po file."; \
		msgmerge -U po/$$l.po po/$(PACKAGE).pot; \
	done;

msgfmt:
	@for l in $(LINGUAS); do \
		echo "Compiling $$l mo file..."; \
		mkdir -p po/mo/$$l/LC_MESSAGES; \
		msgfmt -o po/mo/$$l/LC_MESSAGES/$(PACKAGE).mo po/$$l.po; \
	done;

# Install

install-libtaz:
	install -m 0744 rootfs/lib/libtaz.sh $(DESTDIR)/lib
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	install -m 0644 doc/libtaz.txt $(DESTDIR)/usr/share/doc/slitaz

install-httphelper:
	install -m 0744 rootfs/usr/lib/slitaz/httphelper.sh \
		$(DESTDIR)/usr/lib/slitaz
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	install -m 0644 doc/httphelper.txt $(DESTDIR)/usr/share/doc/slitaz

install-msg: msgfmt
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale
	cp -a po/mo/* $(DESTDIR)$(PREFIX)/share/locale

install: install-msg
	cp -a rootfs/* $(DESTDIR)
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	cp -a doc/* $(DESTDIR)/usr/share/doc/slitaz
	chown -R root.root $(DESTDIR)

# Clean source

clean:
	rm -rf po/mo
	rm -f po/*~

