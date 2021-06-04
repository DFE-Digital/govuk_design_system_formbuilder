prefix=bundle exec
guide_dir=cd guide;
nanoc_default_port=3006
nanoc_internal_checks=internal_links stale mixed_content
nanoc_external_checks=external_links

check: ruby-lint slim-lint rspec nanoc-check
nanoc-check: nanoc-check-all

ruby-lint:
	${prefix} rubocop lib spec guide/lib util
slim-lint:
	${prefix} slim-lint guide
rspec:
	${prefix} rspec --format progress
npm-install:
	${guide_dir} npm ci --silent
nanoc-check-internal:
	${guide_dir} ${prefix} nanoc check ${nanoc_internal_checks}
nanoc-check-external:
	${guide_dir} ${prefix} nanoc check ${nanoc_external_checks}
nanoc-check-all: build-guide
	${guide_dir} ${prefix} nanoc check ${nanoc_internal_checks} ${nanoc_external_checks}
build:
	${prefix} gem build govuk_design_system_formbuilder.gemspec
build-guide: npm-install
	${guide_dir} ${prefix} nanoc
watch-guide: npm-install
	${guide_dir} ${prefix} nanoc live --port ${nanoc_default_port}
docs-server:
	yard server --reload
code-climate:
	codeclimate analyze {lib,spec,guide/lib}
clean:
	rm -rf guide/output/**/*

# the tasks below are experimental and will only work on my computer

run-apply-specs:
	./spec/scripts/apply.sh
