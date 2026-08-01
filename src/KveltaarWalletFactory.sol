// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {KveltaarInstitutionalWallet} from "./KveltaarInstitutionalWallet.sol";

contract KveltaarWalletFactory {
    IEntryPoint public immutable entryPoint;

    error InvalidAddress();

    event WalletCreated(address indexed wallet, address indexed owner, address indexed admin, uint256 salt);

    constructor(IEntryPoint entryPoint_) {
        if (address(entryPoint_) == address(0)) {
            revert InvalidAddress();
        }

        entryPoint = entryPoint_;
    }

    function createWallet(address owner, address admin, uint256 salt)
        external
        returns (KveltaarInstitutionalWallet wallet)
    {
        if (owner == address(0) || admin == address(0)) {
            revert InvalidAddress();
        }

        address predicted = getWalletAddress(owner, admin, salt);

        if (predicted.code.length != 0) {
            return KveltaarInstitutionalWallet(payable(predicted));
        }

        wallet = new KveltaarInstitutionalWallet{salt: bytes32(salt)}(entryPoint, owner, admin);

        emit WalletCreated(address(wallet), owner, admin, salt);
    }

    function getWalletAddress(address owner, address admin, uint256 salt) public view returns (address predicted) {
        bytes memory creationCode =
            abi.encodePacked(type(KveltaarInstitutionalWallet).creationCode, abi.encode(entryPoint, owner, admin));

        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), address(this), bytes32(salt), keccak256(creationCode)));

        predicted = address(uint160(uint256(hash)));
    }
}
