-include .env

.PHONY: all install compile anvil help

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Network Arguments
ANVIL_ARGS := --rpc-url http://localhost:8545 \
              --private-key $(DEFAULT_ANVIL_KEY) \
              --broadcast \
              --via-ir

ARB_SEPOLIA_TESTNET_ARGS := --rpc-url $(RPC_URL_ARB_SEPOLIA) \
                            --account defaultKey \
                            --broadcast \
                            --verify \
                            --verifier-url "https://api.etherscan.io/v2/api?chainid=421614" \
                            --etherscan-api-key $(ETHERSCAN_API) \

# Main commands
all: clean remove install update build 

install:
	@echo "Installing libraries"
	@npm install
	@forge compile --via-ir

compile:
	@forge b --via-ir --sizes

anvil:
	@echo "Starting Anvil, remember to use another terminal to run tests"
	@anvil -m 'test test test test test test test test test test test junk' --steps-tracing

deployTestnet: 
	@echo "Deploying testnet"
	@forge script script/DeployTestnet.s.sol:DeployTestnet $(ARB_SEPOLIA_TESTNET_ARGS) -vvvv

deployLocalTestnet: 
	@echo "Deploying local testnet"
	@forge script script/DeployLocalTestnet.s.sol:DeployLocalTestnet $(ANVIL_ARGS) -vvvv


# Help command
help:
	@echo "-------------------------------------=Usage=-------------------------------------"
	@echo ""
	@echo "  make install -- Install dependencies and compile contracts"
	@echo "  make compile -- Compile contracts"
	@echo "  make anvil ---- Run Anvil (local testnet)"
	@echo ""
	@echo "-----------------------=Deployers for local testnet (Anvil)=----------------------"
	@echo ""
	@echo "  make deployLocalTestnet ----------- Deploy local testnet contracts"
	@echo ""
	@echo "-----------------------=Deployers for test networks=----------------------"
	@echo ""
	@echo "  make deployTestnet ---------------- Deploy testnet contracts"
	@echo ""
	@echo "---------------------------------------------------------------------------------"