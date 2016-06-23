.PHONY: all
all:

.PHONY: help
help:
	echo "Call 'make test' to call tests"

.PHONY: prepare
prepare:
	git clone git://github.com/os-autoinst/os-autoinst
	ln -s os-autoinst/tools .
	cd os-autoinst && cpanm -nq --installdeps .
	cpanm -nq --installdeps .

.PHONY: check-links
check-links:
	@test -d os-autoinst || (echo "Missing test requirements, \
link a local working copy of 'os-autoinst' into this \
folder or call 'make prepare' to install download a copy necessary for \
testing" && exit 2)
	@test -e tools || ln -s os-autoinst/tools .

.PHONY: test
test: check-links
	tools/tidy --check
	export PERL5LIB="../..:os-autoinst:lib:tests/installation:tests/x11:tests/qa_automation:$$PERL5LIB" ; for f in `git ls-files "*.pm" || find . -name \*.pm|grep -v /os-autoinst/` ; do perl -c $$f 2>&1 | grep -v " OK$$" && exit 2; done ; true

.PHONY: perlcritic
perlcritic: check-links
	PERL5LIB=tools/lib/perlcritic:$$PERL5LIB perlcritic --quiet --gentle --include Perl::Critic::Policy::HashKeyQuote .
