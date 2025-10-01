// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SignatureRecover} from "@EVVM/testnet/lib/SignatureRecover.sol";
import {AdvancedStrings} from "@EVVM/testnet/lib/AdvancedStrings.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * SignatureUtils ライブラリ
 */
library SignatureUtils {

    /**
     * @dev using EIP-191 (https://eips.ethereum.org/EIPS/eip-191) can be used to sign and
     *       verify messages, the next functions are used to verify the messages signed
     *       by the users for SERVICE OPERATIONS (not EVVM payments)
     */
    function verifyMessageSignedForPreRegistrationUsername(
        address signer,
        bytes32 _hashUsername,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return
            SignatureRecover.signatureVerification(
                string.concat(
                    "5d232a55",                                    // Function identifier
                    ",",
                    AdvancedStrings.bytes32ToString(_hashUsername),
                    ",",
                    Strings.toString(_nameServiceNonce)
                ),
                signature,
                signer
            );
    }

    function verifyMessageSignedForRegistrationUsername(
        address signer,
        string memory _username,
        uint256 _clowNumber,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return
            SignatureRecover.signatureVerification(
                string.concat(
                    "afabc8db",                          // Unique function identifier
                    ",",
                    _username,
                    ",",
                    Strings.toString(_clowNumber),
                    ",",
                    Strings.toString(_nameServiceNonce)
                ),
                signature,
                signer
            );
    }
    
    // Additional signature validation functions for all service operations...
}

/**
 * MyServiceSignatureUtils ライブラリ
 */ 
library MyServiceSignatureUtils {
    // Function identifier for your service operation (generate unique 8-character hex)
    string constant SERVICE_FUNCTION_ID = "a1b2c3d4"; // Replace with your unique ID
    
    /**
     * @dev Validates SERVICE signature (not EVVM payment signature)
     * @param signer Expected signer address
     * @param data Service-specific data
     * @param nonce Service nonce for replay protection
     * @param signature User's SERVICE signature
     */
    function verifyServiceOperationSignature(
        address signer,
        string memory data,
        uint256 nonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                SERVICE_FUNCTION_ID,
                ",",
                Strings.toHexString(uint256(uint160(signer)), 20),
                ",",
                data,
                ",",
                Strings.toString(nonce)
            ),
            signature,
            signer
        );
    }
}

/**
 * @title EVVM Name Service Contract
 * @notice EVVM上でユーザーにわかりやすい名前を提供するスマートコントラクトです。
 * @dev EVVMサービスと正しく連携する方法を示します。
 *
 * EVVM連携機能:
 * - 支払いにトークン抽象化を使用（ERC-20トークンを別途用意する必要なし）
 * - すべての操作でERC-191署名をチェック
 * - トランザクション実行時にFisher報酬を分配
 * - 2種類のノンス（サービス用とEVVM用）を使用
 * - EVVMのステーキングや報酬システムと連携
 * 
 * サービス機能:
 * - ユーザー名登録時のフロントランニングを防止（コミット・リビール方式）
 * - ユーザーが独自のメタデータを追加可能（スキーマで検証）
 * - 経済性を備えたユーザー名マーケットプレイス
 * - ガバナンスのセキュリティ向上のためのタイムディレイを採用
 * 
 * エコシステム連携:
 * - EVVMコア: 支払い処理と報酬分配を担当
 * - ステーキングシステム: Fisherの調整と報酬分配
 * - 他サービス: 他のコントラクトがユーザー名を参照可能
 */
contract MyNameService {
    // ライブラリを適用
    using MyServiceSignatureUtils for *;

    /// @dev SERVICE nonce mapping - tracks used nonces per address for service operations
    mapping(address => mapping(uint256 => bool)) private nameServiceNonce;
    mapping(address => uint256) public userNonces;

    /// @dev Ensures the SERVICE nonce hasn't been used before
    modifier verifyIfNonceIsAvailable(address _user, uint256 _nonce) {
        if (nameServiceNonce[_user][_nonce])
            revert ErrorsLib.NonceAlreadyUsed();
        _;
    }

    /**
     * @notice 2つの署名検証を行いサービスを実行します
     * @param user ユーザーアドレス
     * @param data サービス固有のデータ
     * @param nonce サービス用ノンス
     * @param signature サービス操作用のSERVICE署名
     * @param priorityFee_EVVM EVVMの優先手数料
     * @param nonce_EVVM EVVM用ノンス
     * @param priorityFlag_EVVM EVVMの非同期/同期フラグ
     * @param signature_EVVM 支払い認証用のEVVM支払い署名
     */
    function executeService(
        address user,
        string memory data,
        uint256 nonce,
        bytes memory signature,           // SERVICE signature
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM      // EVVM payment signature
    ) external verifyIfNonceIsAvailable(user, nonce) {
        // 1. サービスの署名を検証
        require(
            MyServiceSignatureUtils.verifyServiceOperationSignature(
                user,
                data,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // 2. EVVM上の署名データで決済を行う
        makeServicePayment(
            user,
            PRINCIPAL_TOKEN_ADDRESS,     // Token for payment
            SERVICE_FEE,                 // Service fee amount
            priorityFee_EVVM,           // Priority fee
            priorityFlag_EVVM,          // Async/sync flag
            nonce_EVVM,                 // EVVM nonce
            signature_EVVM              // EVVM payment signature
        );
        
        // 3. 実際のサービスロジックを実行する(dataにバイトコードが格納されているのでそれを実行する)
        _performServiceLogic(user, data);
        
        // 4. Mark service nonce as used
        serviceNonce[user][nonce] = true;
    }

    /**
     *
     */
    function preRegistrationUsername(
        address user,
        bytes32 hashPreRegisteredUsername,
        uint256 nonce,                    // SERVICE nonce
        bytes memory signature,           // SERVICE signature
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,              // EVVM nonce (handled by EVVM contract)
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM      // EVVM signature (validated by EVVM contract)
    ) public verifyIfNonceIsAvailable(user, nonce) {
        // Validate SERVICE signature with SERVICE nonce
        require(
            SignatureUtils.verifyMessageSignedForPreRegistrationUsername(
                user,
                hashPreRegisteredUsername,
                nonce,              // SERVICE nonce used in service signature
                signature           // SERVICE signature
            ),
            "Invalid service signature"
        );

        // EVVM handles its own nonce validation when processing payment
        makePay(
            user,
            getPricePerRegistration(),
            priorityFee_EVVM,
            nonce_EVVM,         // EVVM nonce - validated by EVVM contract
            priorityFlag_EVVM,
            signature_EVVM      // EVVM signature - validated by EVVM contract
        );

        // Mark SERVICE nonce as used
        nameServiceNonce[user][nonce] = true;
    }

    /**
     * @notice Checks if a SERVICE nonce has been used by a specific user
     * @dev Prevents replay attacks by tracking used service nonces per user
     * @param _user Address of the user to check
     * @param _nonce Service nonce value to verify
     * @return True if the nonce has been used, false if still available
     */
    function checkIfNameServiceNonceIsAvailable(
        address _user,
        uint256 _nonce
    ) public view returns (bool) {
        return nameServiceNonce[_user][_nonce];
    }

    function validateSyncNonce(address user, uint256 nonce) internal returns (bool) {
        if (nonce != userNonces[user] + 1) {
            return false;
        }
        userNonces[user] = nonce;
        return true;
    }

    
}