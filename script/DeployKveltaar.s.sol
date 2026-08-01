// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {KveltaarInstitutionalWallet} from "../src/KveltaarInstitutionalWallet.sol";
import {KveltaarWalletFactory} from "../src/KveltaarWalletFactory.sol";

contract DeployKveltaar is Script {
    address private constant ENTRY_POINT_V09 = 0x433709009B8330FDa32311DF1C2AFA402eD8D009;

    uint256 private constant WALLET_SALT = 1;

    function run() external returns (KveltaarWalletFactory factory, KveltaarInstitutionalWallet wallet) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        factory = new KveltaarWalletFactory(IEntryPoint(ENTRY_POINT_V09));

        wallet = factory.createWallet(deployer, deployer, WALLET_SALT);

        vm.stopBroadcast();

        console2.log("Factory:", address(factory));
        console2.log("Wallet:", address(wallet));
        console2.log("Owner:", deployer);
        console2.log("Admin:", deployer);
        console2.log("EntryPoint:", ENTRY_POINT_V09);
    }
}
