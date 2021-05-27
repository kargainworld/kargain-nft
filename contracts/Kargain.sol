// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";

contract Kargain is ERC721BurnableUpgradeable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;
    using ECDSAUpgradeable for bytes32;

    event Mint(address indexed author, uint256 indexed tokenId, bytes32 indexed tokenHash);
    event Received(address indexed payer, uint tokenId, uint256 amount, uint256 balance);

    uint256 private constant COMMISSION_EXPONENT = 4;
    uint256 private _tokenCurrentId;
    address payable private _platformAddress;
    uint256 private _platformCommission;
    bytes32 public constant OWNER_ROLE = keccak256("OWNER_ROLE");
    mapping (uint256 => address payable) private _tokenCreator;

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

    modifier onlyOwner(){
        require(hasRole(OWNER_ROLE, _msgSender()), "Kargain: Caller is not a owner");
        _;
    }

    function initialize(address payable platformAddress_, uint256 platformCommission_)
    initializer public {
        _platformAddress = platformAddress_;
        _platformCommission = platformCommission_;
        __ERC721Burnable_init();
        __ERC721_init("Kargain", "KGN");
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(OWNER_ROLE, msg.sender);
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

    function create(address payable creator, bytes32 tokenHash) public onlyOwner returns (uint256) {
        require(creator != address(0), "Kargain: Creator can't be 0x0");
        require(tokenHash != bytes32(0), "Kargain: Hash can't be 0x0");
        _tokenCurrentId = _tokenCurrentId + 1;
        _mint(creator, _tokenCurrentId);
        _tokenCreator[_tokenCurrentId] = creator;
        emit Mint(creator, _tokenCurrentId, tokenHash);
        return _tokenCurrentId;
    }

    function purchaseToken(address payable to, uint256 _tokenId, uint256 amount) public payable {
        require(_tokenCreator[_tokenId] != address(0x0), "Kargain: Creator query for nonexistent token");
        uint256 platformCommission_ = amount.mul(_platformCommission).div(10** COMMISSION_EXPONENT);
        require(msg.value == amount.add(platformCommission_), "Kargain: Invalid amount");
        transferFrom(ownerOf(_tokenId), to, _tokenId);
        _platformAddress.transfer(platformCommission_);
        emit Received(ownerOf(_tokenId), _tokenId, amount, address(ownerOf(_tokenId)).balance);
    }

}
