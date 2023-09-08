PROJECT ?= rknn2
PREFIX ?= /usr
BINDIR ?= $(PREFIX)/bin
LIBDIR ?= $(PREFIX)/lib
MANDIR ?= $(PREFIX)/share/man
VERSION := 1.5.2

.PHONY: all
all: build

#
# Test
#
.PHONY: test
test:

#
# Build
#
.PHONY: build
build: build-doc rknnlite2/rknn_toolkit_lite2-$(VERSION)/rknnlite.egg-info

SRC-DOC		:=	.
DOCS		:=	$(SRC-DOC)/SOURCE
.PHONY: build-doc
build-doc: $(DOCS)

$(SRC-DOC):
	mkdir -p $(SRC-DOC)

.PHONY: $(SRC-DOC)/SOURCE
$(SRC-DOC)/SOURCE: $(SRC-DOC)
	echo -e "git clone $(shell git remote get-url origin)\ngit checkout $(shell git rev-parse HEAD)" > "$@"

rknnlite2: rknn-toolkit2/rknn_toolkit_lite2/packages/rknn_toolkit_lite2-$(VERSION)-cp39-cp39-linux_aarch64.whl
	wheel unpack -d "$@" "$<"

rknnlite2/rknn_toolkit_lite2-$(VERSION)/setup.py: rknnlite2.setup.py rknnlite2
	sed "s/__VERSION__/$(VERSION)/g" "$<" > "$@"

rknnlite2/rknn_toolkit_lite2-$(VERSION)/rknnlite.egg-info: rknnlite2/rknn_toolkit_lite2-$(VERSION)/setup.py
	cd rknnlite2/rknn_toolkit_lite2-$(VERSION) && \
	python3 setup.py bdist_egg

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-doc clean-deb

.PHONY: clean-doc
clean-doc:
	rm -rf $(DOCS)

.PHONY: clean-deb
clean-deb:
	rm -rf rknnlite2 obj-aarch64-linux-gnu debian/.debhelper debian/python3-rknnlite2/ debian/rknpu2-*/ debian/tmp/ debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.*.debhelper debian/*.substvars

#
# Release
#
.PHONY: dch
dch: debian/changelog
	gbp dch --debian-branch=main

.PHONY: deb
deb: debian
	debuild --set-envvar DEB_RKNN_VERSION="$(VERSION)" --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags bad-distribution-in-changes-file -- %p_%v_*.changes" --no-sign -b -aarm64 -Pcross
