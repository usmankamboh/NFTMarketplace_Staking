// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import "./MegaFansNFT.sol";
contract MegaFansMarketplace is Ownable {
    MegaFansNFT public nft;
    mapping(uint256 => mapping(address => uint256)) public listLevel;
    mapping(uint256 => uint256)  PricePerLevel;
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public listPerLevel;
    mapping(MegaFansNFT => mapping(address => mapping(uint256 => uint256))) public bought;
    mapping(uint256 => mapping(address => uint256)) gettinglevel;
    mapping (address => EnumerableSet.UintSet) private _holderTokens;
    // Enumerable mapping from token ids to their owners
    EnumerableMap.UintToAddressMap private _tokenOwners;
    address payable _owner;
    struct buyer {
        uint256[] tokenIds;
    }
    struct sellerlist {
        uint256[] tokenIds;
    }
    uint256 counter;
    mapping (address => buyer ) bought_NFT;
    mapping (address => sellerlist) list_NFT;
    constructor(MegaFansNFT _nft) {
        nft = _nft;
        _owner = payable (msg.sender);
        PricePerLevel[1] = 100000000000000000;
        PricePerLevel[2] = 250000000000000000;
        PricePerLevel[3] = 500000000000000000;
        PricePerLevel[4] = 1000000000000000000;
    }
    function buyNFT(uint256 level) public payable returns (bool)  {
        require (msg.value == PricePerLevel[level],"price not matched with level price"); 
        require (level > 0 && level < 5);
        nft.transferFrom(address(this),msg.sender,counter);
        buyer storage buyers = bought_NFT[msg.sender];
        buyers.tokenIds.push(counter);
        _owner.transfer(PricePerLevel[level]);
        gettinglevel[level][msg.sender]= counter;
        counter ++;
        return true;
    } 
    function listNFT(uint256 level,uint256 tokenId) public returns (bool){
        require(level > 0 && level <5,"level should be between 1 to 4");
        require(listPerLevel[level][tokenId][msg.sender] == false,"nft token Id for level is already listed");
        nft.transferFrom(msg.sender,address(this),tokenId);
        listLevel[level][address(this)] = tokenId;
        listPerLevel[level][tokenId][msg.sender] = true;
        return true;
    }
    function update_price(uint256 level,uint256 _updateprice) external onlyOwner{
        PricePerLevel[level] = _updateprice;
    }
    function boughtNFT(address _user)
        public
        view
        returns (uint256[] memory tokenIds)
    {
        return bought_NFT[_user].tokenIds;
    }
    function getpricelevel(uint256 level) public view returns (uint256){
    uint256 _price=PricePerLevel[level];
    return _price;
    }
    function updatenftaddress(MegaFansNFT _newnft) external onlyOwner{
        nft = _newnft;
    }
    function getlevel(uint256 tokenID,address _user) public view returns(uint256){
        uint256 _level = gettinglevel[tokenID][_user];
        return _level;
    }
}