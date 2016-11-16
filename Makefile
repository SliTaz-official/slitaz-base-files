# Makefile for SliTaz Bugs.
#

PACKAGE=slitaz-base
PREFIX?=/usr
LINGUAS?=ca de el es fa fr pl pt_BR ru sv vi_VN zh_CN zh_TW

all: help

help:
	@echo "make [pot|msgmerge|msgfmt|install-libtaz|install-msg|install|clean]"

# i18n

pot:
	xgettext -o po/$(PACKAGE).pot -L Shell --package-name="SliTaz Base" \
		--copyright-holder="SliTaz" -k -k_ -klgettext -cTranslators \
		./rootfs/lib/libtaz.sh
	xgettext -j -o po/$(PACKAGE).pot -L Shell --package-name="SliTaz Base" \
		--copyright-holder="SliTaz" -k_ -k_n -cTranslators \
		./rootfs/usr/lib/slitaz/libpkg.sh \
		./rootfs/var/www/cgi-bin/cgi-env.sh \
		./rootfs/var/www/cgi-bin/index.cgi \
		./rootfs/usr/bin/man

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
	# Strip comments addressed to translators
	sed -i '/# Translators:/d' $(DESTDIR)/lib/libtaz.sh
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	install -m 0644 doc/libtaz.txt $(DESTDIR)/usr/share/doc/slitaz

install-httphelper:
	install -m 0744 rootfs/usr/lib/slitaz/httphelper.sh \
		$(DESTDIR)/usr/lib/slitaz
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	install -m 0644 doc/httphelper.txt $(DESTDIR)/usr/share/doc/slitaz

install-libpkg:
	install -m 0755 -d $(DESTDIR)/usr/lib/slitaz
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	install -m 0744 rootfs/usr/lib/slitaz/libpkg.sh \
		$(DESTDIR)/usr/lib/slitaz
	install -m 0644 doc/libpkg.txt $(DESTDIR)/usr/share/doc/slitaz

install-slitaz:
	install -m 0755 -d $(DESTDIR)/usr/bin
	install -m 0755 -d $(DESTDIR)/etc/slitaz
	install -m 0744 rootfs/usr/bin/slitaz $(DESTDIR)/usr/bin
	install -m 0644 rootfs/etc/slitaz/slitaz.conf $(DESTDIR)/etc/slitaz

install-msg: msgfmt
	install -m 0755 -d $(DESTDIR)$(PREFIX)/share/locale
	cp -a po/mo/* $(DESTDIR)$(PREFIX)/share/locale

install: install-msg
	cp -a rootfs/* $(DESTDIR)/
	# strip "man" script
	sed -i '/^[^#]*$$/,$${s|^\t*||;/^ *#/d;/^$$/d}' $(DESTDIR)/usr/bin/man
	install -m 0755 -d $(DESTDIR)/usr/share/doc/slitaz
	cp -a doc/* $(DESTDIR)/usr/share/doc/slitaz
	chown -R root:root $(DESTDIR)/usr/share/doc/slitaz

# Clean source

clean:
	rm -rf po/mo
	rm -f po/*~
	rm -f po/*.mo
	rm -f po/*~ $(PACKAGE)*.tar.gz $(PACKAGE)*.md5
