// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title CrossGameNFT
 * @dev Smart contract for NFTs that can be used across multiple games
 */
contract CrossGameNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Mapping to track NFT usage across different games
    // tokenId => gameId => isUsedInGame
    mapping(uint256 => mapping(string => bool)) private _gameUsage;
    
    // Mapping to store NFT attributes
    // tokenId => attribute => value
    mapping(uint256 => mapping(string => string)) private _attributes;
    
    // Events for tracking NFT usage
    event NFTUsedInGame(uint256 indexed tokenId, string gameId);
    event NFTReleased(uint256 indexed tokenId, string gameId);
    event AttributeSet(uint256 indexed tokenId, string attribute, string value);
    
    constructor() ERC721("CrossGameNFT", "CGNFT") Ownable(msg.sender) {}
    
    /**
     * @dev Mints a new NFT with cross-game utility
     * @param recipient Address to receive the NFT
     * @param tokenURI URI for the NFT metadata
     * @return The ID of the newly minted NFT
     */
    function mintNFT(address recipient, string memory tokenURI) public onlyOwner returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _mint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        
        return newTokenId;
    }
    
    /**
     * @dev Register NFT usage in a specific game
     * @param tokenId ID of the NFT
     * @param gameId Identifier for the game
     */
    function useNFTInGame(uint256 tokenId, string memory gameId) public {
        address owner = ownerOf(tokenId); // This will revert if token doesn't exist
        require(_msgSender() == owner || getApproved(tokenId) == _msgSender() || isApprovedForAll(owner, _msgSender()), 
                "Caller is not owner or approved");
        require(!_gameUsage[tokenId][gameId], "NFT already in use in this game");
        
        _gameUsage[tokenId][gameId] = true;
        emit NFTUsedInGame(tokenId, gameId);
    }
    
    /**
     * @dev Release NFT from a specific game
     * @param tokenId ID of the NFT
     * @param gameId Identifier for the game
     */
    function releaseNFTFromGame(uint256 tokenId, string memory gameId) public {
        address owner = ownerOf(tokenId); // This will revert if token doesn't exist
        require(_msgSender() == owner || getApproved(tokenId) == _msgSender() || isApprovedForAll(owner, _msgSender()), 
                "Caller is not owner or approved");
        require(_gameUsage[tokenId][gameId], "NFT not in use in this game");
        
        _gameUsage[tokenId][gameId] = false;
        emit NFTReleased(tokenId, gameId);
    }
    
    /**
     * @dev Check if an NFT is being used in a specific game
     * @param tokenId ID of the NFT
     * @param gameId Identifier for the game
     * @return Whether the NFT is being used in the specified game
     */
    function isNFTUsedInGame(uint256 tokenId, string memory gameId) public view returns (bool) {
        // This will revert if token doesn't exist
        ownerOf(tokenId);
        return _gameUsage[tokenId][gameId];
    }
    
    /**
     * @dev Set attribute for an NFT
     * @param tokenId ID of the NFT
     * @param attribute Name of the attribute
     * @param value Value of the attribute
     */
    function setAttribute(uint256 tokenId, string memory attribute, string memory value) public {
        address owner = ownerOf(tokenId); // This will revert if token doesn't exist
        require(_msgSender() == owner || getApproved(tokenId) == _msgSender() || isApprovedForAll(owner, _msgSender()), 
                "Caller is not owner or approved");
        _attributes[tokenId][attribute] = value;
        emit AttributeSet(tokenId, attribute, value);
    }
    
    /**
     * @dev Get attribute value for an NFT
     * @param tokenId ID of the NFT
     * @param attribute Name of the attribute
     * @return Value of the attribute
     */
    function getAttribute(uint256 tokenId, string memory attribute) public view returns (string memory) {
        // This will revert if token doesn't exist
        ownerOf(tokenId);
        return _attributes[tokenId][attribute];
    }
}