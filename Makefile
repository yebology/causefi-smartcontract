.PHONY: test coverage deploy

test:
	forge test -vv

coverage:
	forge coverage

deploy:
	forge script script/CauseFi.s.sol:CauseFiScript --rpc-url ${RPC_URL} --private-key ${PRIVATE_KEY} --broadcast --verify --verifier ${VERIFIER} --verifier-url ${VERIFIER_URL}