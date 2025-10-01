// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SignatureRecover} from "@EVVM/testnet/lib/SignatureRecover.sol";
import {AdvancedStrings} from "@EVVM/testnet/lib/AdvancedStrings.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {Evvm} from "@EVVM/testnet/contracts/evvm/Evvm.sol";

// ===== エラー =====  
library ErrorsLib {
    error NonceAlreadyUsed();
    error SenderIsNotAdmin();
    error UserIsNotOwnerOfIdentity();
    error InvalidUsername(bytes1 code);
    error PreRegistrationNotValid();
    error IdentityNotFound();
    error OfferNotValid();
}

/**
 * @title 署名検証ユーティリティ
 */
library SignatureUtils {
    function verifyMessageSignedForPreRegistrationUsername(
        address signer,
        bytes32 _hashUsername,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "5d232a55",
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
        return SignatureRecover.signatureVerification(
            string.concat(
                "afabc8db",
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
    
    function verifyMessageSignedForAddCustomMetadata(
        address signer,
        string memory _identity,
        string memory _metadata,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "b3c4d5e6",
                ",",
                _identity,
                ",",
                _metadata,
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
    
    function verifyMessageSignedForAddMetadataSlot(
        address signer,
        string memory _identity,
        uint256 _numberOfSlots,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "c4d5e6f7",
                ",",
                _identity,
                ",",
                Strings.toString(_numberOfSlots),
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
    
    function verifyMessageSignedForMakeOffer(
        address signer,
        string memory _username,
        uint256 _expireDate,
        uint256 _amount,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "d5e6f7g8",
                ",",
                _username,
                ",",
                Strings.toString(_expireDate),
                ",",
                Strings.toString(_amount),
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
    
    function verifyMessageSignedForAcceptOffer(
        address signer,
        string memory _username,
        uint256 _offerID,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "e6f7g8h9",
                ",",
                _username,
                ",",
                Strings.toString(_offerID),
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
    
    function verifyMessageSignedForCancelOffer(
        address signer,
        string memory _username,
        uint256 _offerID,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "f7g8h9i0",
                ",",
                _username,
                ",",
                Strings.toString(_offerID),
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
    
    function verifyMessageSignedForRenewUsername(
        address signer,
        string memory _username,
        uint256 _nameServiceNonce,
        bytes memory signature
    ) internal pure returns (bool) {
        return SignatureRecover.signatureVerification(
            string.concat(
                "g8h9i0j1",
                ",",
                _username,
                ",",
                Strings.toString(_nameServiceNonce)
            ),
            signature,
            signer
        );
    }
}

/**
 * @title EVVM Name Service Contract
 * @notice 人間が読めるID管理とマーケットプレイス機能を提供
 */
contract NameService {
    
    // ===== 定数 =====
    address private constant PRINCIPAL_TOKEN_ADDRESS = 
        0x0000000000000000000000000000000000000001;
    
    // ===== 構造体 =====
    
    struct AddressTypeProposal {
        address current;
        address proposal;
        uint256 timeToAccept;
    }
    
    struct IdentityBaseMetadata {
        address owner;
        uint256 expireDate;
        uint256 customMetadataMaxSlots;
        uint256 offerMaxSlots;
        bytes1 flagNotAUsername; // 0x01: 事前登録, 0x00: 通常
    }
    
    struct OfferMetadata {
        address offerer;
        uint256 expireDate;
        uint256 amount;
    }
    
    // ===== 状態変数 =====
    
    AddressTypeProposal public admin;
    AddressTypeProposal public evvmAddress;
    
    mapping(string => IdentityBaseMetadata) private identityDetails;
    mapping(string => mapping(uint256 => string)) private identityCustomMetadata;
    mapping(string => mapping(uint256 => OfferMetadata)) private usernameOffers;
    mapping(address => mapping(uint256 => bool)) private nameServiceNonce;
    
    uint256 public mateTokenLockedForWithdrawOffers;

    // ===== イベント =====
    
    event PreRegistrationCreated(address indexed user, bytes32 hash);
    event UsernameRegistered(address indexed user, string username);
    event CustomMetadataAdded(string indexed username, string metadata);
    event MetadataSlotsAdded(string indexed username, uint256 slots);
    event OfferMade(string indexed username, address indexed offerer, uint256 amount, uint256 offerID);
    event OfferAccepted(string indexed username, address indexed from, address indexed to, uint256 amount);
    event OfferCancelled(string indexed username, address indexed offerer, uint256 offerID);
    event UsernameRenewed(string indexed username, address indexed owner);
    event AdminProposed(address indexed newAdmin);
    event AdminChanged(address indexed newAdmin);
    event EvvmAddressProposed(address indexed newEvvm);
    event EvvmAddressChanged(address indexed newEvvm);
    
    // ===== モディファイア =====
    
    modifier onlyAdmin() {
        if (msg.sender != admin.current) revert ErrorsLib.SenderIsNotAdmin();
        _;
    }
    
    modifier onlyOwnerOfIdentity(address _user, string memory _identity) {
        if (identityDetails[_identity].owner != _user)
            revert ErrorsLib.UserIsNotOwnerOfIdentity();
        _;
    }
    
    modifier verifyIfNonceIsAvailable(address _user, uint256 _nonce) {
        if (nameServiceNonce[_user][_nonce])
            revert ErrorsLib.NonceAlreadyUsed();
        _;
    }
    
    // ===== コンストラクタ =====
    
    constructor(address _evvmAddress, address _admin) {
        evvmAddress.current = _evvmAddress;
        admin.current = _admin;
    }
    
    // ===== ユーザー名登録機能 =====
    
    /**
     * @notice ステップ1: ハッシュコミットメントで事前登録
     */
    function preRegistrationUsername(
        address user,
        bytes32 hashPreRegisteredUsername,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public verifyIfNonceIsAvailable(user, nonce) {
        // サービス署名の検証
        require(
            SignatureUtils.verifyMessageSignedForPreRegistrationUsername(
                user,
                hashPreRegisteredUsername,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // 決済処理
        makePay(
            user,
            getPricePerRegistration(),
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        // 事前登録キーの作成
        string memory key = string.concat(
            "@",
            AdvancedStrings.bytes32ToString(hashPreRegisteredUsername)
        );
        
        // 30分間有効な事前登録を作成
        identityDetails[key] = IdentityBaseMetadata({
            owner: user,
            expireDate: block.timestamp + 30 minutes,
            customMetadataMaxSlots: 0,
            offerMaxSlots: 0,
            flagNotAUsername: 0x01
        });
        
        // nonceを使用済みとしてマーク
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                (50 * Evvm(evvmAddress.current).getRewardAmount()) + priorityFee_EVVM
            );
        }
        
        emit PreRegistrationCreated(user, hashPreRegisteredUsername);
    }
    
    /**
     * @notice ステップ2: 実際のユーザー名を公開して正式登録
     */
    function registrationUsername(
        address user,
        string memory username,
        uint256 clowNumber,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public verifyIfNonceIsAvailable(user, nonce) {
        // サービス署名の検証
        require(
            SignatureUtils.verifyMessageSignedForRegistrationUsername(
                user,
                username,
                clowNumber,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // ユーザー名の形式検証
        isValidUsername(username);
        
        // 事前登録の検証
        string memory _key = string.concat(
            "@",
            AdvancedStrings.bytes32ToString(hashUsername(username, clowNumber))
        );
        
        if (identityDetails[_key].owner != user ||
            identityDetails[_key].expireDate < block.timestamp) {
            revert ErrorsLib.PreRegistrationNotValid();
        }
        
        // 決済処理
        makePay(
            user,
            getPricePerRegistration(),
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        // 正式登録(366日間有効)
        identityDetails[username] = IdentityBaseMetadata({
            owner: user,
            expireDate: block.timestamp + 366 days,
            customMetadataMaxSlots: 0,
            offerMaxSlots: 0,
            flagNotAUsername: 0x00
        });
        
        // 事前登録を削除
        delete identityDetails[_key];
        
        // nonceを使用済みとしてマーク
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                (50 * Evvm(evvmAddress.current).getRewardAmount()) + priorityFee_EVVM
            );
        }
        
        emit UsernameRegistered(user, username);
    }
    
    // ===== メタデータ管理 =====
    
    /**
     * @notice カスタムメタデータの追加
     */
    function addCustomMetadataToIdentity(
        address user,
        string memory identity,
        string memory metadata,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public 
        onlyOwnerOfIdentity(user, identity)
        verifyIfNonceIsAvailable(user, nonce) 
    {
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForAddCustomMetadata(
                user,
                identity,
                metadata,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // メタデータ形式の検証: [schema]:[subschema]>[value]
        require(isValidMetadataFormat(metadata), "Invalid metadata format");
        
        // スロットの確認と更新
        uint256 currentSlot = identityDetails[identity].customMetadataMaxSlots;
        require(currentSlot > 0, "No available slots");
        
        // メタデータを保存
        identityCustomMetadata[identity][currentSlot - 1] = metadata;
        identityDetails[identity].customMetadataMaxSlots--;
        
        // 決済処理
        makePay(
            user,
            getPriceToAddCustomMetadata(),
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                Evvm(evvmAddress.current).getRewardAmount() + priorityFee_EVVM
            );
        }
        
        emit CustomMetadataAdded(identity, metadata);
    }
    
    /**
     * @notice メタデータスロットの追加購入
     */
    function addCustomMetadataSlotToIdentity(
        address user,
        string memory identity,
        uint256 numberOfSlotsToAdd,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public 
        onlyOwnerOfIdentity(user, identity)
        verifyIfNonceIsAvailable(user, nonce) 
    {
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForAddMetadataSlot(
                user,
                identity,
                numberOfSlotsToAdd,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // 決済処理
        makePay(
            user,
            getPriceToAddCustomMetadata() * numberOfSlotsToAdd,
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        // スロット数を増加
        identityDetails[identity].customMetadataMaxSlots += numberOfSlotsToAdd;
        
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                Evvm(evvmAddress.current).getRewardAmount() + priorityFee_EVVM
            );
        }
        
        emit MetadataSlotsAdded(identity, numberOfSlotsToAdd);
    }
    
    // ===== マーケットプレイス機能 =====
    
    /**
     * @notice ユーザー名にオファーを出す
     */
    function makeOffer(
        address user,
        string memory username,
        uint256 expireDate,
        uint256 amount,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public verifyIfNonceIsAvailable(user, nonce) {
        // ユーザー名の存在確認
        require(verifyIfIdentityExists(username), "Username not found");
        require(identityDetails[username].owner != user, "Cannot offer own username");
        
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForMakeOffer(
                user,
                username,
                expireDate,
                amount,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // 決済処理(オファー金額をロック)
        makePay(
            user,
            amount,
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        // オファーIDの取得
        uint256 offerID = identityDetails[username].offerMaxSlots;
        
        // 0.5%のマーケットプレイス手数料を控除
        uint256 amountAfterFee = (amount * 995) / 1000;
        
        // オファーを保存
        usernameOffers[username][offerID] = OfferMetadata({
            offerer: user,
            expireDate: expireDate,
            amount: amountAfterFee
        });
        
        // オファースロットを増加
        identityDetails[username].offerMaxSlots++;
        
        // ロックされたトークンを追跡
        mateTokenLockedForWithdrawOffers += amountAfterFee + (amount / 800);
        
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬(オファー金額の0.125%)
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                Evvm(evvmAddress.current).getRewardAmount() +
                ((amount * 125) / 100_000) +
                priorityFee_EVVM
            );
        }
        
        emit OfferMade(username, user, amount, offerID);
    }
    
    /**
     * @notice オファーを受け入れる(ユーザー名を売却)
     */
    function acceptOffer(
        address user,
        string memory username,
        uint256 offerID,
        uint256 nonce,
        bytes memory signature
    ) public 
        onlyOwnerOfIdentity(user, username)
        verifyIfNonceIsAvailable(user, nonce) 
    {
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForAcceptOffer(
                user,
                username,
                offerID,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // オファーの有効性確認
        OfferMetadata memory offer = usernameOffers[username][offerID];
        require(offer.offerer != address(0), "Offer not found");
        require(offer.expireDate > block.timestamp, "Offer expired");
        
        address previousOwner = user;
        address newOwner = offer.offerer;
        uint256 saleAmount = offer.amount;
        
        // 所有権の移転
        identityDetails[username].owner = newOwner;
        identityDetails[username].expireDate = block.timestamp + 366 days;
        
        // オファーを削除
        delete usernameOffers[username][offerID];
        
        // ロックを解除
        mateTokenLockedForWithdrawOffers -= saleAmount;
        
        // 売却金額を元の所有者に送金
        makeCaPay(previousOwner, saleAmount);
        
        nameServiceNonce[user][nonce] = true;
        
        emit OfferAccepted(username, previousOwner, newOwner, saleAmount);
    }
    
    /**
     * @notice オファーをキャンセル
     */
    function cancelOffer(
        address user,
        string memory username,
        uint256 offerID,
        uint256 nonce,
        bytes memory signature
    ) public verifyIfNonceIsAvailable(user, nonce) {
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForCancelOffer(
                user,
                username,
                offerID,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // オファーの確認
        OfferMetadata memory offer = usernameOffers[username][offerID];
        require(offer.offerer == user, "Not your offer");
        
        uint256 refundAmount = offer.amount;
        
        // オファーを削除
        delete usernameOffers[username][offerID];
        
        // ロックを解除
        mateTokenLockedForWithdrawOffers -= refundAmount;
        
        // ロックされたトークンを返金
        makeCaPay(user, refundAmount);
        
        nameServiceNonce[user][nonce] = true;
        
        emit OfferCancelled(username, user, offerID);
    }
    
    // ===== 更新機能 =====
    
    /**
     * @notice ユーザー名の更新(366日延長)
     */
    function renewUsername(
        address user,
        string memory username,
        uint256 nonce,
        bytes memory signature,
        uint256 priorityFee_EVVM,
        uint256 nonce_EVVM,
        bool priorityFlag_EVVM,
        bytes memory signature_EVVM
    ) public 
        onlyOwnerOfIdentity(user, username)
        verifyIfNonceIsAvailable(user, nonce) 
    {
        // 署名検証
        require(
            SignatureUtils.verifyMessageSignedForRenewUsername(
                user,
                username,
                nonce,
                signature
            ),
            "Invalid service signature"
        );
        
        // 動的価格の計算
        uint256 renewPrice = seePriceToRenew(username);
        
        // 決済処理
        makePay(
            user,
            renewPrice,
            priorityFee_EVVM,
            nonce_EVVM,
            priorityFlag_EVVM,
            signature_EVVM
        );
        
        // 有効期限を延長
        identityDetails[username].expireDate = block.timestamp + 366 days;
        
        nameServiceNonce[user][nonce] = true;
        
        // フィッシャーに報酬
        if (Evvm(evvmAddress.current).isAddressStaker(msg.sender)) {
            makeCaPay(
                msg.sender,
                Evvm(evvmAddress.current).getRewardAmount() + priorityFee_EVVM
            );
        }
        
        emit UsernameRenewed(username, user);
    }
    
    // ===== 価格設定関数 =====
    
    function getPricePerRegistration() public view returns (uint256) {
        return Evvm(evvmAddress.current).getRewardAmount() * 100;
    }
    
    function getPriceToAddCustomMetadata() public view returns (uint256) {
        return 10 * Evvm(evvmAddress.current).getRewardAmount();
    }
    
    /**
     * @notice 市場駆動型の動的更新価格
     */
    function seePriceToRenew(string memory _identity) public view returns (uint256 price) {
        if (identityDetails[_identity].expireDate >= block.timestamp) {
            // 有効なオファーから市場価値を判断
            for (uint256 i = 0; i < identityDetails[_identity].offerMaxSlots; i++) {
                if (usernameOffers[_identity][i].expireDate > block.timestamp &&
                    usernameOffers[_identity][i].offerer != address(0)) {
                    if (usernameOffers[_identity][i].amount > price) {
                        price = usernameOffers[_identity][i].amount;
                    }
                }
            }
            
            if (price == 0) {
                price = 500 * 10 ** 18;  // ベース価格
            } else {
                uint256 mateReward = Evvm(evvmAddress.current).getRewardAmount();
                // 市場価格の0.5%、上限は500,000 * getRewardAmount()
                price = ((price * 5) / 1000) > (500000 * mateReward)
                    ? (500000 * mateReward)
                    : ((price * 5) / 1000);
            }
        } else {
            // 期限切れの場合
            price = 500_000 * Evvm(evvmAddress.current).getRewardAmount();
        }
    }
    
    // ===== EVVM統合ヘルパー =====
    
    function makePay(
        address user,
        uint256 amount,
        uint256 priorityFee,
        uint256 nonce,
        bool priorityFlag,
        bytes memory signature
    ) internal {
        if (priorityFlag) {
            Evvm(evvmAddress.current).payStaker_async(
                user,
                address(this),
                "",
                PRINCIPAL_TOKEN_ADDRESS,
                amount,
                priorityFee,
                nonce,
                address(this),
                signature
            );
        } else {
            Evvm(evvmAddress.current).payStaker_sync(
                user,
                address(this),
                "",
                PRINCIPAL_TOKEN_ADDRESS,
                amount,
                priorityFee,
                address(this),
                signature
            );
        }
    }
    
    function makeCaPay(address user, uint256 amount) internal {
        Evvm(evvmAddress.current).caPay(user, PRINCIPAL_TOKEN_ADDRESS, amount);
    }
    
    // ===== バリデーション関数 =====
    
    function isValidUsername(string memory username) internal pure {
        bytes memory usernameBytes = bytes(username);
        
        if (usernameBytes.length < 4) revert ErrorsLib.InvalidUsername(0x01);
        if (!_isLetter(usernameBytes[0])) revert ErrorsLib.InvalidUsername(0x02);
        
        for (uint256 i = 0; i < usernameBytes.length; i++) {
            if (!_isDigit(usernameBytes[i]) && !_isLetter(usernameBytes[i])) {
                revert ErrorsLib.InvalidUsername(0x03);
            }
        }
    }
    
    function isValidMetadataFormat(string memory metadata) internal pure returns (bool) {
        // 形式: [schema]:[subschema]>[value]
        bytes memory metadataBytes = bytes(metadata);
        bool hasColon = false;
        bool hasGreater = false;
        
        for (uint256 i = 0; i < metadataBytes.length; i++) {
            if (metadataBytes[i] == ":") hasColon = true;
            if (metadataBytes[i] == ">") hasGreater = true;
        }
        
        return hasColon && hasGreater;
    }
    
    function _isLetter(bytes1 char) private pure returns (bool) {
        return (char >= 0x41 && char <= 0x5A) || (char >= 0x61 && char <= 0x7A);
    }
    
    function _isDigit(bytes1 char) private pure returns (bool) {
        return (char >= 0x30 && char <= 0x39);
    }
    
    function hashUsername(string memory username, uint256 clowNumber) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(username, clowNumber));
    }
    
    // ===== ビュー関数 =====
    
    function verifyStrictAndGetOwnerOfIdentity(string memory username) 
        public view returns (address) 
    {
        if (!verifyIfIdentityExists(username)) revert ErrorsLib.IdentityNotFound();
        return identityDetails[username].owner;
    }
    
    function verifyIfIdentityExists(string memory username) 
        public view returns (bool) 
    {
        return identityDetails[username].owner != address(0) &&
               identityDetails[username].flagNotAUsername == 0x00;
    }
    
    function getCustomMetadata(string memory username, uint256 key) 
        public view returns (string memory) 
    {
        return identityCustomMetadata[username][key];
    }
    
    function checkIfNameServiceNonceIsAvailable(address user, uint256 nonce) 
        public view returns (bool) 
    {
        return nameServiceNonce[user][nonce];
    }
    
    function getIdentityDetails(string memory username) 
        public view returns (IdentityBaseMetadata memory) 
    {
        return identityDetails[username];
    }
    
    function getOffer(string memory username, uint256 offerID) 
        public view returns (OfferMetadata memory) 
    {
        return usernameOffers[username][offerID];
    }
    
    // ===== ガバナンス機能 =====
    
    function proposeAdmin(address _adminToPropose) public onlyAdmin {
        admin.proposal = _adminToPropose;
        admin.timeToAccept = block.timestamp + 1 days;
        emit AdminProposed(_adminToPropose);
    }
    
    function acceptProposeAdmin() public {
        require(admin.proposal == msg.sender, "Not proposed admin");
        require(block.timestamp >= admin.timeToAccept, "Time delay not passed");
        
        admin.current = admin.proposal;
        admin.proposal = address(0);
        admin.timeToAccept = 0;
        
        emit AdminChanged(msg.sender);
    }
    
    function proposeEvvmAddress(address _evvmToPropose) public onlyAdmin {
        evvmAddress.proposal = _evvmToPropose;
        evvmAddress.timeToAccept = block.timestamp + 1 days;
        emit EvvmAddressProposed(_evvmToPropose);
    }
    
    function acceptProposeEvvmAddress() public onlyAdmin {
        require(block.timestamp >= evvmAddress.timeToAccept, "Time delay not passed");
        
        evvmAddress.current = evvmAddress.proposal;
        evvmAddress.proposal = address(0);
        evvmAddress.timeToAccept = 0;
        
        emit EvvmAddressChanged(evvmAddress.current);
    }
}