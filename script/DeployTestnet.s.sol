// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Evvm} from "@EVVM/testnet/evvm/Evvm.sol";
import {SMate} from "@EVVM/testnet/staking/SMate.sol";
import {Estimator} from "@EVVM/testnet/staking/Estimator.sol";
import {MateNameService} from "@EVVM/testnet/mns/MateNameService.sol";

contract DeployTestnet is Script {
    SMate sMate;
    Evvm evvm;
    Estimator estimator;
    MateNameService mateNameService;
    address admin = 0x5cBf2D4Bbf834912Ad0bD59980355b57695e8309;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        sMate = new SMate(admin);
        evvm = new Evvm(admin, address(sMate));
        estimator = new Estimator(
            0x976EA74026E726554dB657fA54763abd0C3a0aa9,
            address(evvm),
            address(sMate),
            admin
        );
        mateNameService = new MateNameService(
            address(evvm),
            admin
        );

        sMate._addEstimator(address(estimator));
        evvm._setMateNameServiceAddress(address(mateNameService));

        vm.stopBroadcast();

        console2.log("SMate deployed at:", address(sMate));
        console2.log("Evvm deployed at:", address(evvm));
        console2.log("Estimator deployed at:", address(estimator));
    }
}
