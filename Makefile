.PHONY: start-emulator
start-emulator:
	flow emulator

.PHONY: deploy-contract
deploy-contract:
	flow project deploy --update

.PHONY: setup-account
setup-account:
	flow transactions send --signer emulator-account ./transactions/user/setup_account.cdc

.PHONY: mint-passport
mint-passport:
	flow transactions send --signer emulator-account ./transactions/user/mint_passport.cdc 0xf8d6e0586b0a20c7 dadaism

.PHONY: mint-post
mint-post:
	flow transactions send --signer emulator-account ./transactions/user/mint_post.cdc "You are so stupid"

.PHONY: show-passports
show-passports:
	flow scripts execute ./scripts/read_all_passports.cdc 0xf8d6e0586b0a20c7

.PHONY: show-posts
show-passports:
	flow scripts execute ./scripts/read_all_posts.cdc 0xf8d6e0586b0a20c7