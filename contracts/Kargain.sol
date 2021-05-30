// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract Kargain is ERC721BurnableUpgradeable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;
    using ECDSAUpgradeable for bytes32;

    uint256 private constant COMMISSION_EXPONENT = 4;
    uint256 private _tokenCurrentId;
    address payable private _platformAddress;
    uint256 private _platformCommission;

    mapping (uint => Token) private _tokens;
    mapping (uint256 => address payable) private _offers;
    mapping (uint256 => uint256) private _offers_closeTimestamp;

    event TokenCreated(address indexed creator, uint256 indexed tokenId);
    event OfferReceived(address indexed payer, uint tokenId);
    event OfferAccepted(address indexed payer, uint tokenId);
    event OfferRejected(address indexed payer, uint tokenId);

    struct Token {
        address owner;
        uint amount;
        bool isValue;
        bool offer;
        bool offerAccepted;
    }

    struct TransferType {
        address from;
        address to;
        uint256 tokenId;
        uint256 amount;
    }

    modifier onlyAdmin(){
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "Kargain: Caller is not a admin");
        _;
    }

    function initialize(address payable platformAddress_, uint256 platformCommissionPercent_)
    initializer public {
        _platformAddress = platformAddress_;
        _platformCommission = platformCommissionPercent_;
        __ERC721Burnable_init();
        __ERC721_init("Kargain", "KGN");
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function platformCommission() public view returns(uint256){
        return _platformCommission;
    }

    function setPlatformCommission(uint256 platformCommission_) public onlyAdmin {
        _platformCommission = platformCommission_;
    }

    function platformAddress() public view returns(address payable){
        return _platformAddress;
    }

    function setPlatformAddress(address payable platformAddress_) public onlyAdmin {
        _platformAddress = platformAddress_;
    }

    function create(address payable creator, uint256 tokenId, uint256 amount) public payable{
        require(!_tokens[tokenId].isValue, "Kargain: Id for this token already exist");
        super._mint(creator, _tokenCurrentId);
        _tokens[tokenId].owner = creator;
        _tokens[tokenId].isValue = true;
        _tokens[tokenId].amount = amount;
        emit TokenCreated(creator, tokenId);
    }

    function purchaseToken(uint256 _tokenId) public payable {
        require(!_tokens[_tokenId].isValue, "Kargain: Auction for this token already exist");
        require(_tokens[_tokenId].offer, "Kargain: An offer is pending");
        require(_tokens[_tokenId].offerAccepted, "Kargain: Offer was accepted");
        require(msg.value != _tokens[_tokenId].amount, "Kargain: the offer amount is invalid");
        address payable refundAddress = _offers[_tokenId];
        _offers[_tokenId] = payable(address(msg.sender));
        refundAddress.transfer(_tokens[_tokenId].amount);
        emit OfferReceived(msg.sender, _tokenId);
    }

}
