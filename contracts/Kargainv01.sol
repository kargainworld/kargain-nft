// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract KargainV01 is ERC721BurnableUpgradeable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;
    using ECDSAUpgradeable for bytes32;

    uint256 private constant COMMISSION_EXPONENT = 4;
    address payable private _platformAddress;
    uint256 private _platformCommissionPercent;
    uint256 private _offerExpirationTime;

    mapping(uint256 => uint256) private _tokens_price;
    mapping(uint256 => address payable) private _offers;
    mapping(uint256 => uint256) private _offers_closeTimestamp;

    event TokenMinted(address indexed creator, uint256 indexed tokenId);
    event OfferReceived(address indexed payer, uint256 tokenId, uint256 amount);
    event OfferAccepted(address indexed payer, uint256 tokenId);
    event OfferRejected(address indexed payer, uint256 tokenId);
    event OfferExpired(address indexed payer, uint256 tokenId);
    event OfferCancelled(address indexed payer, uint256 tokenId);

    modifier onlyAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Kargain: Caller is not a admin"
        );
        _;
    }

    modifier tokenExists(uint256 _tokenId) {
        require(
            _exists(_tokenId),
            "Kargain: Id for this token does not exist."
        );
        _;
    }

    modifier onlyOwner(uint256 _tokenId) {
        require(
            ownerOf(_tokenId) == msg.sender,
            "Kargain: You are not the owner of this token."
        );
        _;
    }

    modifier offerExist(uint256 _tokenId) {
        require(
            _offers[_tokenId] != address(0),
            "Kargain: Does not exist any offer for this token."
        );
        _;
    }

    function initialize(
        address payable _platformAddress_,
        uint256 _platformCommissionPercent_
    ) public initializer {
        _platformAddress = _platformAddress_;
        _platformCommissionPercent = _platformCommissionPercent_;
        _offerExpirationTime = 1 days;
        __ERC721Burnable_init();
        __ERC721_init("Kargain", "KGN");
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function platformCommissionPercent() external view returns (uint256) {
        return _platformCommissionPercent;
    }

    function setPlatformCommissionPercent(uint256 platformCommissionPercent_)
        external
        onlyAdmin
    {
        _platformCommissionPercent = platformCommissionPercent_;
    }

    function platformAddress() external view returns (address payable) {
        return _platformAddress;
    }

    function setPlatformAddress(address payable platformAddress_)
        external
        onlyAdmin
    {
        _platformAddress = platformAddress_;
    }

    function offerExpirationTime() external view returns (uint256) {
        return _offerExpirationTime;
    }

    function setOfferExpirationTime(uint256 offerExpirationTime_)
        external
        onlyAdmin
    {
        _offerExpirationTime = offerExpirationTime_;
    }

    function tokenPrice(uint256 _tokenId)
        external
        view
        tokenExists(_tokenId)
        returns (uint256)
    {
        return _tokens_price[_tokenId];
    }

    function setTokenPrice(uint256 _tokenId, uint256 _price)
        external
        tokenExists(_tokenId)
        onlyOwner(_tokenId)
    {
        require(
            _offers[_tokenId] == address(0) ||
                _offers_closeTimestamp[_tokenId] < now,
            "Kargain: An offer is already submitted, token price cannot be changed until it expires."
        );
        _tokens_price[_tokenId] = _price;
    }

    function offerAddress(uint256 _tokenId)
        external
        view
        tokenExists(_tokenId)
        returns (address payable)
    {
        return _offers[_tokenId];
    }

    function _refundOffer(uint256 _tokenId)
        private
        tokenExists(_tokenId)
        offerExist(_tokenId)
    {
        address payable buyer = _offers[_tokenId];

        delete _offers[_tokenId];
        delete _offers_closeTimestamp[_tokenId];

        buyer.transfer(_tokens_price[_tokenId]);
    }

    function mint(uint256 _tokenId, uint256 _price) external {
        require(
            !_exists(_tokenId),
            "Kargain: Id for this token already exists."
        );
        require(_price > 0, "Kargain: Prices must be greater than zero.");
        super._mint(msg.sender, _tokenId);
        _tokens_price[_tokenId] = _price;
        emit TokenMinted(msg.sender, _tokenId);
    }

    function createOffer(uint256 _tokenId)
        external
        payable
        tokenExists(_tokenId)
    {
        require(
            ownerOf(_tokenId) != msg.sender,
            "Kargain: You cannot buy your own token."
        );
        require(
            _offers[_tokenId] == address(0) &&
                _offers_closeTimestamp[_tokenId] < now,
            "Kargain: An offer is already submitted."
        );
        require(
            msg.value == _tokens_price[_tokenId],
            "Kargain: The offer amount is invalid."
        );

        _offers[_tokenId] = payable(msg.sender);
        _offers_closeTimestamp[_tokenId] = now.add(_offerExpirationTime);
        emit OfferReceived(msg.sender, _tokenId, msg.value);
    }

    function acceptOffer(uint256 _tokenId)
        external
        tokenExists(_tokenId)
        offerExist(_tokenId)
        onlyOwner(_tokenId)
    {
        if (_offers_closeTimestamp[_tokenId] < now) {
            delete _offers[_tokenId];
            delete _offers_closeTimestamp[_tokenId];
            emit OfferExpired(msg.sender, _tokenId);
            return;
        }
        address payable buyer = _offers[_tokenId];

        delete _offers[_tokenId];
        delete _offers_closeTimestamp[_tokenId];

        uint256 platformCommission =
            _tokens_price[_tokenId].mul(_platformCommissionPercent).div(
                10**COMMISSION_EXPONENT
            );
        _platformAddress.transfer(platformCommission);

        msg.sender.transfer(_tokens_price[_tokenId].sub(platformCommission));
        safeTransferFrom(msg.sender, buyer, _tokenId);

        emit OfferAccepted(msg.sender, _tokenId);
    }

    function rejectOffer(uint256 _tokenId)
        external
        tokenExists(_tokenId)
        onlyOwner(_tokenId)
        offerExist(_tokenId)
    {
        _refundOffer(_tokenId);

        emit OfferRejected(msg.sender, _tokenId);
    }

    function cancelOffer(uint256 _tokenId)
        external
        tokenExists(_tokenId)
        offerExist(_tokenId)
    {
        require(
            _offers[_tokenId] == msg.sender ||
                hasRole(DEFAULT_ADMIN_ROLE, msg.sender),
            "Kargain: You do not have any offer for this token."
        );
        _refundOffer(_tokenId);

        emit OfferCancelled(msg.sender, _tokenId);
    }

    function version()public pure returns (string memory)
    {
        return "Kargain v01";
    }
}
