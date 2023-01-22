// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 

contract NFTMamaMarketplace {
    address public owner;

    uint public idForSale;
    // satılacak NFT'lerin bilgilerini buraya girmek için yeni bir veri tipi yaratmak istediğimden dolayı struct yapısı ile bunu yapıyorum

    struct ItemForSale {
        address contractAddress;
        address seller;
        address buyer;
        uint tokenId;
        uint price;
        bool state;
    }

    // Hangi NFT'ler satışta olduğunu göstermek için mapping yapısını kullanıyorum

    mapping(uint => ItemForSale) public IdToItemForSale;

    constructor(){
        owner = msg.sender;
    
    }

    function startNFTSale(address _contractAddress, uint price, uint _tokenId) public {
        IERC721 NFT = IERC721(_contractAddress);
        require(NFT.ownerOf(_tokenId) == msg.sender, "Bu NFT size ait degil!!");
        NFT.transferFrom(msg.sender, address(this), _tokenId);
        IdToItemForSale[idForSale] = ItemForSale(_contractAddress, msg.sender, msg.sender, price, _tokenId, false);
        idForSale += 1;
    } 
    function cancelNFTSale(uint Id) public {
        ItemForSale memory info = IdToItemForSale[Id];
        IERC721 NFT = IERC721(info.contractAddress);
        require(Id < idForSale);
        require(info.seller == msg.sender);
        require(info.state == false);
        NFT.transferFrom(address(this), msg.sender, info.tokenId);
        IdToItemForSale[Id] = ItemForSale(address(0), address(0), address(0), 0, 0, true);


    }

    function buyNFT(uint Id) public payable {
        ItemForSale storage info = IdToItemForSale[Id];
        require(Id < idForSale);
        require(msg.sender != info.seller);
        require(msg.value == info.price);
        require(info.state == false);
        IERC721 NFT = IERC721(info.contractAddress);
        NFT.transferFrom(address(this), msg.sender, info.tokenId);
        uint price = msg.value;
        payable(info.seller).transfer(price);
        payable(owner).transfer(msg.value - price);
        info.buyer = msg.sender;
        info.state = true;

    }
    function changeOwner() public {

    }
}
