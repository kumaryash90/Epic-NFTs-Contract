// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstRandomWord = ["Penguins_", "Zebras_", "Whales_", "Koalas_", "Hippos_", "Ants_", "Turtles_", "Sloths_", "Frogs_", "Crows_"];
    string[] secondRandomWord = ["love_", "hate_", "danceTo_", "ate_", "worship_", "despise_", "bought_", "like_", "play_", "manage_"];
    string[] thirdRandomWord = ["Queen", "RollingStones", "TheWho", "LedZeppelin", "Beatles", "PinkFloyd", "AC/DC", "GunsNRoses", "Nirvana", "PearlJam"];

    uint256 maxNFTs = 25;
    uint256 totalMinted = 0;

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("StoicNFT","STOIC") {
        console.log("NFT contract");
    }

    function _generateRandomString(uint tokenId) private view returns(string memory) {
        uint randomNumber = uint(keccak256(abi.encodePacked("Random Words", Strings.toString(tokenId)))) % 1000;
        uint firstWordIndex = (randomNumber / 100);
        uint secondWordIndex = (randomNumber / 10) % 10;
        uint thirdWordIndex = randomNumber % 10;
        return string(abi.encodePacked(firstRandomWord[firstWordIndex], secondRandomWord[secondWordIndex], thirdRandomWord[thirdWordIndex]));
    }

    function getMaxNFT() public view returns(uint256) {
        return maxNFTs;
    }

    function getTotalMinted() public view returns(uint256) {
        return totalMinted;
    }

    function makeAnEpicNFT() public {
        require(totalMinted <= maxNFTs, "All NFTs have been minted");
        uint256 newItemId = _tokenIds.current();
        
        string memory threeWordString = _generateRandomString(newItemId);
        string memory finalSvg = string(abi.encodePacked(baseSvg, threeWordString, "</text></svg>"));
        string memory jsonbase64 = Base64.encode((abi.encodePacked('{"name" :"', threeWordString, '", "description" :', '"random 3 word NFTs"', ', "image" :"data:image/svg+xml;base64,', string(Base64.encode(bytes(finalSvg))), '"}')));
        string memory myNftUri = string(abi.encodePacked("data:application/json;base64,", jsonbase64));
        
        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, myNftUri);
        console.log("NFT Id: %s, Minted to: %s", newItemId, msg.sender);
        _tokenIds.increment();
        totalMinted++;
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}