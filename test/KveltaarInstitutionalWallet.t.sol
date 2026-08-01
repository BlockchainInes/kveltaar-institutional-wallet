// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Test} from "forge-std/Test.sol";
import {EntryPoint} from "@account-abstraction/contracts/core/EntryPoint.sol";
import {KveltaarInstitutionalWallet} from "../src/KveltaarInstitutionalWallet.sol";

contract KveltaarInstitutionalWalletTest is Test {
    EntryPoint private entryPoint;
    KveltaarInstitutionalWallet private wallet;

    address private owner;
    address private admin;
    address private operator;
    address private complianceOfficer;
    address private recipient;

    function setUp() public {
        owner = makeAddr("owner");
        admin = makeAddr("admin");
        operator = makeAddr("operator");
        complianceOfficer = makeAddr("complianceOfficer");
        recipient = makeAddr("recipient");

        entryPoint = new EntryPoint();
        wallet = new KveltaarInstitutionalWallet(entryPoint, owner, admin);

        vm.startPrank(admin);
        wallet.grantRole(wallet.OPERATOR_ROLE(), operator);
        wallet.grantRole(wallet.COMPLIANCE_ROLE(), complianceOfficer);
        vm.stopPrank();

        vm.deal(address(wallet), 10 ether);
    }

    function testInitialization() public view {
        assertEq(address(wallet.entryPoint()), address(entryPoint));
        assertEq(wallet.owner(), owner);
        assertTrue(wallet.hasRole(wallet.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(wallet.hasRole(wallet.TREASURY_ROLE(), admin));
        assertTrue(wallet.hasRole(wallet.OPERATOR_ROLE(), admin));
        assertTrue(wallet.hasRole(wallet.COMPLIANCE_ROLE(), admin));
    }

    function testReceiveNativeAsset() public {
        address depositor = makeAddr("depositor");
        vm.deal(depositor, 2 ether);

        vm.prank(depositor);
        (bool success,) = address(wallet).call{value: 1 ether}("");

        assertTrue(success);
        assertEq(address(wallet).balance, 11 ether);
    }

    function testOperatorCanExecuteInstitutionalTransaction() public {
        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(operator);
        wallet.executeInstitutional(recipient, 1 ether, bytes(""));

        assertEq(recipient.balance, recipientBalanceBefore + 1 ether);
        assertEq(address(wallet).balance, 9 ether);
    }

    function testUnauthorizedAccountCannotExecute() public {
        address unauthorized = makeAddr("unauthorized");

        vm.prank(unauthorized);
        vm.expectRevert();

        wallet.executeInstitutional(recipient, 1 ether, bytes(""));
    }

    function testComplianceOfficerCanPause() public {
        vm.prank(complianceOfficer);
        wallet.pause();

        assertTrue(wallet.paused());
    }

    function testPausedWalletRejectsExecution() public {
        vm.prank(complianceOfficer);
        wallet.pause();

        vm.prank(operator);
        vm.expectRevert();

        wallet.executeInstitutional(recipient, 1 ether, bytes(""));
    }

    function testAdminCanUnpause() public {
        vm.prank(complianceOfficer);
        wallet.pause();

        vm.prank(admin);
        wallet.unpause();

        assertFalse(wallet.paused());
    }

    function testTreasuryCanDepositIntoEntryPoint() public {
        address depositor = makeAddr("entryPointDepositor");
        vm.deal(depositor, 2 ether);

        vm.prank(depositor);
        wallet.addDeposit{value: 1 ether}();

        assertEq(wallet.getDeposit(), 1 ether);
    }

    function testTreasuryCanWithdrawEntryPointDeposit() public {
        address depositor = makeAddr("entryPointDepositor");
        vm.deal(depositor, 2 ether);

        vm.prank(depositor);
        wallet.addDeposit{value: 1 ether}();

        uint256 recipientBalanceBefore = recipient.balance;

        vm.prank(admin);
        wallet.withdrawDepositTo(payable(recipient), 0.4 ether);

        assertEq(wallet.getDeposit(), 0.6 ether);
        assertEq(recipient.balance, recipientBalanceBefore + 0.4 ether);
    }

    function testNonTreasuryCannotWithdrawEntryPointDeposit() public {
        address depositor = makeAddr("entryPointDepositor");
        vm.deal(depositor, 2 ether);

        vm.prank(depositor);
        wallet.addDeposit{value: 1 ether}();

        vm.prank(operator);
        vm.expectRevert();

        wallet.withdrawDepositTo(payable(recipient), 0.4 ether);
    }
}
