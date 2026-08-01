// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {BaseAccount} from "@account-abstraction/contracts/core/BaseAccount.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "@account-abstraction/contracts/core/Helpers.sol";

contract KveltaarInstitutionalWallet is BaseAccount, AccessControl, Pausable, ReentrancyGuard {
    bytes32 public constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    IEntryPoint private immutable _entryPoint;
    address public owner;

    error InvalidAddress();
    error UnauthorizedExecutor(address caller);
    error NativeTransferFailed(address target, uint256 value);

    event WalletInitialized(address indexed entryPoint, address indexed owner, address indexed admin);

    event NativeReceived(address indexed sender, uint256 amount);

    event InstitutionalExecution(address indexed operator, address indexed target, uint256 value, bytes data);

    constructor(IEntryPoint entryPoint_, address owner_, address admin_) {
        if (address(entryPoint_) == address(0) || owner_ == address(0) || admin_ == address(0)) {
            revert InvalidAddress();
        }

        _entryPoint = entryPoint_;
        owner = owner_;

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(TREASURY_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);
        _grantRole(COMPLIANCE_ROLE, admin_);

        emit WalletInitialized(address(entryPoint_), owner_, admin_);
    }

    receive() external payable {
        emit NativeReceived(msg.sender, msg.value);
    }

    function entryPoint() public view override returns (IEntryPoint) {
        return _entryPoint;
    }

    function executeInstitutional(address target, uint256 value, bytes calldata data)
        external
        nonReentrant
        whenNotPaused
        onlyRole(OPERATOR_ROLE)
        returns (bytes memory result)
    {
        if (target == address(0)) {
            revert InvalidAddress();
        }

        (bool success, bytes memory returnData) = target.call{value: value}(data);

        if (!success) {
            assembly {
                revert(add(returnData, 0x20), mload(returnData))
            }
        }

        emit InstitutionalExecution(msg.sender, target, value, data);

        return returnData;
    }

    function pause() external onlyRole(COMPLIANCE_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function addDeposit() external payable {
        entryPoint().depositTo{value: msg.value}(address(this));
    }

    function withdrawDepositTo(address payable recipient, uint256 amount) external onlyRole(TREASURY_ROLE) {
        if (recipient == address(0)) {
            revert InvalidAddress();
        }

        entryPoint().withdrawTo(recipient, amount);
    }

    function getDeposit() external view returns (uint256) {
        return entryPoint().balanceOf(address(this));
    }

    function _requireForExecute() internal view override {
        if (msg.sender != address(entryPoint()) && msg.sender != owner && msg.sender != address(this)) {
            revert UnauthorizedExecutor(msg.sender);
        }
    }

    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        override
        returns (uint256 validationData)
    {
        address recoveredSigner = ECDSA.recover(userOpHash, userOp.signature);

        if (recoveredSigner != owner) {
            return SIG_VALIDATION_FAILED;
        }

        return SIG_VALIDATION_SUCCESS;
    }
}
