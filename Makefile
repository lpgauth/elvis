PROJECT = elvis_shell

DEPS = lager elvis_core getopt jiffy ibrowse egithub
SHELL_DEPS = sync
TEST_DEPS = meck xref_runner

dep_lager       = git https://github.com/basho/lager.git       2.0.3
dep_elvis_core  = git https://github.com/lpgauth/elvis_core    ignore_files
dep_getopt      = git https://github.com/jcomellas/getopt      v0.8.2
dep_jiffy       = git https://github.com/davisp/jiffy          0.14.2
dep_ibrowse     = git https://github.com/cmullaparthi/ibrowse  v4.1.2
dep_egithub     = git https://github.com/inaka/erlang-github   0.1.7
dep_sync        = git https://github.com/rustyio/sync.git      9c78e7b
dep_meck        = git https://github.com/eproxus/meck          0.8.3
dep_xref_runner = git https://github.com/inaka/xref_runner.git 0.2.2

include erlang.mk

ERLC_OPTS += +'{parse_transform, lager_transform}'
ERLC_OPTS += +warn_unused_vars +warn_export_all +warn_shadow_vars +warn_unused_import +warn_unused_function
ERLC_OPTS += +warn_bif_clash +warn_unused_record +warn_deprecated_function +warn_obsolete_guard +strict_validation
ERLC_OPTS += +warn_export_vars +warn_exported_vars +warn_missing_spec +warn_untyped_record +debug_info

# Commont Test Config

TEST_ERLC_OPTS += +'{parse_transform, lager_transform}'
CT_OPTS = -cover test/elvis.coverspec -erl_args -config config/test.config
SHELL_OPTS = -name elvis@`hostname` -s sync -s elvis -s lager -config config/elvis.config
ESCRIPT_NAME = elvis

# Builds the elvis escript.
escript::
	./elvis help

test-shell: build-ct-suites app
	erl -pa ebin -pa deps/*/ebin -name elvis-test@`hostname` -pa test -s sync -s elvis -s lager -config config/test.config

install: escript
	cp elvis /usr/local/bin

quicktests: ERLC_OPTS = $(TEST_ERLC_OPTS)
quicktests: clean app build-ct-suites
	@if [ -d "test" ] ; \
	then \
		mkdir -p logs/ ; \
		$(CT_RUN) -suite $(addsuffix _SUITE,$(CT_SUITES)) $(CT_OPTS) ; \
	fi
	$(gen_verbose) rm -f test/*.beam
