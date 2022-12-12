//SPDX-License-Identifier:MIT

pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTMarketPlace is ERC721,ReentrancyGuard{
    using Counters for Counters.Counter;
    //Total No.of token in the market
    Counters.Counter private tokenIds;
    //No.of Items sold in the market
    Counters.Counter private ItemsSold;

    address public owner;
    //Cost to list token in the market
    uint256 public listPrice = 0.001 ether; 

    address contractAddress;

    constructor(address marketplace)ERC721("PHOTONFT","PNFT"){
        owner = msg.sender;
        contractAddress = marketplace;
    }
    //Details of the token
    struct listedToken{
        uint256 tokenId;
        address payable owner;
        address payable seller;
        uint256 price;
        bool listed;
    }

    event statusOfListed(uint256 tokenId,address owner,address seller,uint256 price,bool listed );

    mapping(uint256 => listedToken)public ListedTokens;

    modifier onlyOwner(){
        require(msg.sender == owner,'Invalid request' );
        _;
    }
    
      function getTokenCount()public view returns(uint){
        return tokenIds.current();
    }
    
    function getLatestListedToken() public view returns (listedToken memory) {
        uint256 currentTokenId = tokenIds.current();
        return ListedTokens[currentTokenId];
    }

    function createToken(uint256 price)public payable returns(uint256){
        tokenIds.increment();
        uint256 newTokenId = tokenIds.current();
        _safeMint(msg.sender,newTokenId);
        approve(contractAddress, newTokenId);
        // _setTokenURI(tokenId,tokenURI);
        AddListedToken(newTokenId,price);
        return newTokenId;
    }

    function AddListedToken(uint256 tokenId,uint256 price)private{
        require(msg.value == listPrice,'Please sent valid amount');
        require(price > 0,'Invalid amount'); 

        ListedTokens[tokenId] = listedToken(
                                            tokenId,
                                            payable(address(this)),
                                            payable(msg.sender),
                                            price,
                                            true);

        _transfer(msg.sender,address(this),tokenId);
        emit statusOfListed(tokenId, address(this), msg.sender,price,true);
    }
    
    function getAllNfts()public view returns(listedToken[] memory){
        uint nftCount = tokenIds.current();
        listedToken[] memory tokens = new listedToken[](nftCount);
        uint currentIndex = 0 ;

        for(uint i=0; i<nftCount; i++){
            uint currentId = i+ 1;
            listedToken storage currentItem = ListedTokens[currentId];
            tokens[currentIndex] = currentItem;
            currentIndex += 1;
        }
        return tokens;
    }

    function getMyNft()public view returns(listedToken[] memory){
        uint totalItemCount = tokenIds.current();
        uint itemCount;
        uint currentIndex;

        for(uint i=0; i<totalItemCount; i++){
            if (ListedTokens[i+1].owner == msg.sender || ListedTokens[i+1].seller == msg.sender){
                itemCount +=1;
            }
        }
        
        listedToken[] memory items = new listedToken[](itemCount);
        for(uint i=0; i<totalItemCount; i++){
            if (ListedTokens[i+1].owner == msg.sender || ListedTokens[i+1].seller == msg.sender){
                uint currentId = i+1;
                listedToken storage currentItem = ListedTokens[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function getListedTokens(uint tokenId)public view returns(listedToken memory){
        return ListedTokens[tokenId];
    }  
    
    function executeSale(uint tokenId)public payable {
        uint price = ListedTokens[tokenId].price;
        address seller = ListedTokens[tokenId].seller;
        require(msg.value == price);

        ListedTokens[tokenId].listed = true;
        ListedTokens[tokenId].seller = payable(msg.sender);
       
        _transfer(address(this),msg.sender,tokenId);
        approve(address(this),tokenId);
        payable(owner).transfer(listPrice);
        payable(seller).transfer(msg.value);

    }
  }
