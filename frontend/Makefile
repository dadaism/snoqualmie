
SERVER_PORT := 3000

.PHONY: run-dev
run-dev: CONFIG := development
run-dev: set-env
	next dev -p ${SERVER_PORT}

# Choose the environment configs to pull from /env to root.
.PHONY: set-env
set-env:
	rm -f ./.env
	cp ./env/.env.${CONFIG} .env