// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract AmelimiaNFT is ERC721, Ownable {
    uint256 public mintPrice;
    uint256 public totalSupply;
    uint256 public maxSupply;
    uint256 public maxPerWallet;
    bool public isPublicMintEnabled;
    string internal baseTokenUri;
    address payable public withdrawWallet;

    //opensea url to use where the images are located

    //keep track of all the mints
    mapping(address => uint256) public walletMints;

    constructor() payable ERC721('Amelimia','MIA') {

    }

    //trigger to enable mint
    function setIsPublicMintEnabled(bool _isPublicMintEnabled) external onlyOwner {
        isPublicMintEnabled = _isPublicMintEnabled;
    }

    //set maxPerWallet
    function setMaxPerWallet(uint256 _maxPerWallet) external onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    //set mintPrice
    function setMintPrice(uint256 _mintPrice) external onlyOwner {
        mintPrice = _mintPrice;
    }

    //set maxSupply
    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    //set withdrawWallet
    function setWithdrawWallet(address payable _withdrawWallet) external onlyOwner {
        withdrawWallet = _withdrawWallet;
    }

    //nft image url
    function setBaseTokenUri(string calldata _baseTokenUri) external onlyOwner {
        baseTokenUri = _baseTokenUri;
    }

    //token id
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        require(_exists(_tokenId), 'Token does not exist!');
        //allows OS to grab the correct image url and token attached to json
        return string(abi.encodePacked(baseTokenUri,Strings.toString(_tokenId), ".json"));
    }

    //allow wallet withdrawal
    function withdraw() external onlyOwner {
        (bool success, ) = withdrawWallet.call{value: address(this).balance }('');
        require(success, 'withdraw failed');
    }

    function mint(uint256 _quantity) external payable {
        require(isPublicMintEnabled, 'minting is not live');
        require(msg.value == _quantity * mintPrice, 'wrong amount');
        require(totalSupply + _quantity <= maxSupply, 'sold out');
        require(walletMints[msg.sender]<1,'Already minted');

        for(uint256 i = 0; i < _quantity; i++) {
            uint256 newTokenId = totalSupply + 1;
            //check effect interaction. stop reentrancy attack
            totalSupply ++;
            walletMints[msg.sender] ++;
            _safeMint(msg.sender, newTokenId);
        }
    }

}

