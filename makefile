-include .env

.PHONY: all install compile anvil help

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Network Arguments
ANVIL_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast  --via-ir
ARB_SEPOLIA_TESTNET_ARGS := --rpc-url $(RPC_URL_ARB_SEPOLIA) --account defaultKey --broadcast --verify --verifier-url "https://api-sepolia.arbiscan.io/api" --etherscan-api-key $(ARBISCAN_API) -vvvv

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

# Deployment commands
mock: mockToken mockTreasury mockEvvm

deployTestnet: 
	@echo "Deploying testnet"
	@forge script script/DeployTestnet.s.sol:DeployTestnet $(ARB_SEPOLIA_TESTNET_ARGS) -vvvv




# Other commands
staticAnalysis:
	@echo "Running static analysis"
	@wake detect all >> reportWake.txt

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
	@echo "  make mock --------- Deploy all mock contracts (Token, Treasury, EVVM)"
	@echo "  make mockToken ---- Deploy mock Token contract"
	@echo "  make mockTreasury - Deploy mock Treasury contract"
	@echo "  make mockEvvm ----- Deploy mock EVVM contract"
	@echo ""
	@echo "-----------------------=Deployers for test networks=----------------------"
	@echo ""
	@echo "  make deployEvvmMock --------------------- Deploy EVVM mock to Ethereum Sepolia testnet"
	@echo "  make deploySideChainEvvmMock ------------ Deploy EVVM mock to Avalanche Fuji testnet"
	@echo "  make deploySideChainMateNameServiceMock - Deploy MNS mock to Avalanche Fuji testnet"
	@echo ""
	@echo "-----------------------=Test commands=----------------------"
	@echo ""
	@echo "  make fullTestEvvm ------- Run all EVVM tests"
	@echo "  make testEvvm ----------- Run EVVM unit tests"
	@echo "  make testEvvmRevert ----- Run EVVM revert tests"
	@echo "  make fullTestMNS -------- Run all MNS tests"
	@echo "  make testMNS ------------ Run MNS unit tests"
	@echo "  make testMNSRevert ------ Run MNS revert tests"
	@echo "  make fullTestSMate ------ Run all sMate tests"
	@echo "  make testSMate ---------- Run sMate unit tests"
	@echo "  make testSMateRevert ---- Run sMate revert tests"
	@echo "  make testEstimator ------ Run estimator tests"
	@echo "  make fullProtocolTest --- Run all protocol tests"
	@echo ""
	@echo "-----------------------=Fuzz test commands=----------------------"
	@echo ""
	@echo "  EVVM Fuzz tests"
	@echo ""
	@echo "  make fuzzTestEvvmPayMultiple ---- Run EVVM fuzz tests for payMultiple"
	@echo "  make fuzzTestEvvmDispersePay ---- Run EVVM fuzz tests for dispersePay"
	@echo "  make fuzzTestEvvmPay ------------ Run EVVM fuzz tests for pay"
	@echo "  make fuzzTestEvvmCaPay ---------- Run EVVM fuzz tests for caPay"
	@echo "  make fuzzTestEvvmDisperseCaPay -- Run EVVM fuzz tests for disperseCaPay"
	@echo "  make fuzzTestEvvmAdminFunctions - Run EVVM fuzz tests for admin functions"
	@echo "  make fuzzTestEvvmProxy ---------- Run EVVM fuzz tests for proxy implementations"
	@echo ""
	@echo "  MNS Fuzz tests"
	@echo ""
	@echo "  make fuzzTestMnsOffers --------------------- Run MNS fuzz tests for offers"
	@echo "  make fuzzTestMnsPreAndRegistrationUsername - Run MNS fuzz tests for username registration"
	@echo "  make fuzzTestMnsRenewUsername -------------- Run MNS fuzz tests for renewing usernames"
	@echo "  make fuzzTestMnsAddCustomMetadata ---------- Run MNS fuzz tests for adding custom metadata"
	@echo "  make fuzzTestMnsRemoveCustomMetadata ------- Run MNS fuzz tests for removing custom metadata"
	@echo "  make fuzzTestMnsFlushCustomMetadata -------- Run MNS fuzz tests for flushing custom metadata"
	@echo "  make fuzzTestMnsFlushUsername -------------- Run MNS fuzz tests for flushing usernames"
	@echo "  make fuzzTestMnsAdminFunctions ------------- Run MNS fuzz tests for admin functions"
	@echo ""
	@echo "-----------------------=Other commands=----------------------"
	@echo ""
	@echo "  make staticAnalysis --- Run static analysis and generate report"
	@echo ""
	@echo "---------------------------------------------------------------------------------"