// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Evvm} from "@EVVM/testnet/contracts/evvm/Evvm.sol";
import {Staking} from "@EVVM/testnet/contracts/staking/Staking.sol";
import {Estimator} from "@EVVM/testnet/contracts/staking/Estimator.sol";
import {NameService} from "@EVVM/testnet/contracts/nameService/NameService.sol";
import {EvvmStructs} from "@EVVM/testnet/contracts/evvm/lib/EvvmStructs.sol";

contract DeployTestnet is Script {
    Staking sMate;
    Evvm evvm;
    Estimator estimator;
    NameService nameService;
    address admin = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;
    address goldenFisher = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;
    address activator = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;
    EvvmStructs.EvvmMetadata evvmMetadata =
        EvvmStructs.EvvmMetadata({
            EvvmName: "EVVM",
            EvvmID: abi.encodePacked(uint256(1)),
            principalTokenName: "Mate Token",
            principalTokenSymbol: "MATE",
            principalTokenAddress: 0x0000000000000000000000000000000000000001,
            totalSupply: 2033333333000000000000000000,
            eraTokens: 2033333333000000000000000000 / 2,
            reward: 5000000000000000000
        });

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        sMate = new Staking(admin, goldenFisher);
        evvm = new Evvm(admin, address(sMate), evvmMetadata);
        estimator = new Estimator(
            activator,
            address(evvm),
            address(sMate),
            admin
        );
        nameService = new NameService(address(evvm), admin);

        sMate._setupEstimatorAndEvvm(address(estimator), address(evvm));
        evvm._setupNameServiceAddress(address(nameService));

        vm.stopBroadcast();

        console2.log("SMate deployed at:", address(sMate));
        console2.log("Evvm deployed at:", address(evvm));
        console2.log("Estimator deployed at:", address(estimator));
    }
}
