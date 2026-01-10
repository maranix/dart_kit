.PHONY test fix analyze publish publish_force

test:
	dart test

fix:
	dart fix . --apply

analyze:
	dart analyze

publish:
	dart fix . --apply && dart test && dart pub publish

publish_force:
	dart pub publish
