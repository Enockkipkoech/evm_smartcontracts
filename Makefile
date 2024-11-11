-include .env

.PHONY: help
.PHONY: all test clean

all : clean install build

# Clean the project
clean:; forge clean

# Install the project
install:; forge install foundry-rs/forge-std openzeppelin/openzeppelin-contracts --no-commit

# Update the dependencies
update:; forge update

# Build the project
build:; forge build

# Test the project
test:; forge test -vvvv --rpc-url $(RPC_URL) --gas-report

# Snapshot the project
snapshot:; forge snapshot

# Anvil
anvil:; forge anvil --fork-url $(RPC_URL)

# Deploy the project
mainnet:; forge script script/GasManager.s.sol --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --etherscan-api-key $(ETHERSCAN_API_KEY) --verify -vvvv
testnet:; forge script script/TradeManager.s.sol:TradeManagerScript --rpc-url $(RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --etherscan-api-key $(ETHERSCAN_API_KEY) --verify -vvvv
simulate:; forge script script/mainnet.s.sol:GasScript --rpc-url $(RPC_URL)  -vvvv


liskTestnet:;forge create --rpc-url $(RPC_URL) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify --verifier blockscout --verifier-url $(LISK_BLOCKSCOUT_TEST) --private-key $(PRIVATE_KEY) --contracts ./src/GasManager.sol GasManager --constructor-args 3 -vvvv



# MAINNET DEPLOYMENTS
trademanager:;forge create --rpc-url $(RPC_URL) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify --verifier blockscout --verifier-url $(LISK_BLOCKSCOUT_TEST) --private-key $(PRIVATE_KEY) --contracts ./src/TradeManager TradeManager --constructor-args $(ROUTER_V2) $(LISK_ADDRESS)  -vvvv


liskMainnet:;forge create --rpc-url $(RPC_URL) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify --verifier blockscout --verifier-url $(LISK_BLOCKSCOUT_TEST) --private-key $(PRIVATE_KEY) --contracts ./src/GasManager.sol GasManager --constructor-args 3 -vvvv

helloBlockchain:;forge create --rpc-url $(RPC_URL) --etherscan-api-key $(ETHERSCAN_API_KEY) --verify --verifier blockscout --verifier-url $(LISK_BLOCKSCOUT_TEST) --private-key $(PRIVATE_KEY) --contracts ./src/HelloBlockchain.sol HelloBlockchain --constructor-args "INITIAL MESSAGE" -vvvv