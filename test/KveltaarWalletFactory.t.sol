// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {EntryPoint} from "@account-abstraction/contracts/core/EntryPoint.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {KveltaarInstitutionalWallet} from "../src/KveltaarInstitutionalWallet.sol";
import {KveltaarWalletFactory} from "../src/KveltaarWalletFactory.sol";

contract KveltaarWalletFactoryTest is Test {
    EntryPoint private entryPoint;
    KveltaarWalletFactory private factory;

    address private owner;
    address private admin;

    function setUp() public {
        owner = makeAddr("owner");
        admin = makeAddr("admin");

        entryPoint = new EntryPoint();
        factory = new KveltaarWalletFactory(entryPoint);
    }

    function testFactoryStoresEntryPoint() public view {
        assertEq(address(factory.entryPoint()), address(entryPoint));
    }

    function testCreatesWalletAtPredictedAddress() public {
        uint256 salt = 1;

        address predicted = factory.getWalletAddress(owner, admin, salt);

        KveltaarInstitutionalWallet wallet = factory.createWallet(owner, admin, salt);

        assertEq(address(wallet), predicted);
        assertEq(wallet.owner(), owner);
        assertEq(address(wallet.entryPoint()), address(entryPoint));
        assertTrue(wallet.hasRole(wallet.DEFAULT_ADMIN_ROLE(), admin));
    }

    function testRepeatedCreationReturnsExistingWallet() public {
        uint256 salt = 2;

        KveltaarInstitutionalWallet first = factory.createWallet(owner, admin, salt);

        KveltaarInstitutionalWallet second = factory.createWallet(owner, admin, salt);

        assertEq(address(first), address(second));
    }

    function testDifferentSaltCreatesDifferentAddress() public {
        address first = factory.getWalletAddress(owner, admin, 10);
        address second = factory.getWalletAddress(owner, admin, 11);

        assertTrue(first != second);
    }

    function testDifferentOwnerCreatesDifferentAddress() public {
        address secondOwner = makeAddr("secondOwner");

        address first = factory.getWalletAddress(owner, admin, 1);
        address second = factory.getWalletAddress(secondOwner, admin, 1);

        assertTrue(first != second);
    }

    function testRejectsZeroEntryPoint() public {
        vm.expectRevert(KveltaarWalletFactory.InvalidAddress.selector);

        new KveltaarWalletFactory(IEntryPoint(address(0)));
    }

    function testRejectsZeroOwner() public {
        vm.expectRevert(KveltaarWalletFactory.InvalidAddress.selector);

        factory.createWallet(address(0), admin, 1);
    }

    function testRejectsZeroAdmin() public {
        vm.expectRevert(KveltaarWalletFactory.InvalidAddress.selector);

        factory.createWallet(owner, address(0), 1);
    }
}
