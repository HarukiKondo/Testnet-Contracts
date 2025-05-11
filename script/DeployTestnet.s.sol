// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Evvm} from "@EVVM/testnet/evvm/Evvm.sol";
import {SMate} from "@EVVM/testnet/staking/SMate.sol";

contract DeployTestnet is Script {
    SMate sMate;

    function run() public {
        vm.broadcast();
        deployEvvm();
    }

    function deployEvvm() public returns (address sMateAddress) {
        sMate = new SMate(msg.sender);
        console2.log("sMate address: ", address(sMate));
        console2.log("Evvm address: ", sMate.getEvvmAddress());
        console2.log(
            "MNS address: ",
            Evvm(sMate.getEvvmAddress()).getMateNameServiceAddress()
        );
        return address(sMate);
    }
}
