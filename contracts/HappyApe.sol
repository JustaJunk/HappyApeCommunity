//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 @title Main NFT contract of Happy Ape Community
 @author Justa Liang
 */
contract HappyApe is ERC721Enumerable, PaymentSplitter, Ownable {

    using Strings for uint256;

    ///@dev Contract state
    struct State {
        uint16 femalePopulation;
        uint16 malePopulation;
        uint16 offsetId;
    }
    State public state;

    string private constant BASE_URI = "ipfs://<cid>/";             // TODO
    uint32 private constant START_TIMESTAMP = 1636524632;           // TODO
    uint32 private constant REVEAL_TIMESTAMP = 1636524632;          // TODO
    uint16 private constant EACH_MAX_POPULATION = 10;               // TODO
    uint256 private constant APE_BIRTH_COST = 0.09 ether;

    ///@dev Setup ERC721 and PaymentSplitter
    constructor(
        address[] memory payees_,
        uint256[] memory shares_
    )
        ERC721("HappyApe", "HAPA")
        PaymentSplitter(payees_, shares_)
    {
        state.femalePopulation = 0;
        state.malePopulation = 0;
        state.offsetId = 0;

        console.log("Deploying a HappyApe");
        console.log("    name:", name());
        console.log("    symbol:", symbol());
    }

    ///@notice Mint Ape NFT
    function mint(uint8 amount) external payable {
        require(
            !Address.isContract(_msgSender()),
            "can't from contract"
        );
        require(
            msg.value >= amount*APE_BIRTH_COST,
            "not enough fund"
        );
        require(
            block.timestamp >= START_TIMESTAMP,
            "haven't start"
        );
        uint256 factor = uint160(_msgSender()) ^ uint256(blockhash(block.number-1));
        uint8 amountOfSuccess = 0;
        for (uint8 i = 0; i < amount; i++) {
            if (factor%2 == 0 && state.femalePopulation < EACH_MAX_POPULATION) {
                _safeMint(_msgSender(), state.femalePopulation);
                state.femalePopulation++;
                amountOfSuccess++;
            }
            else if (factor%2 == 1 && state.malePopulation < EACH_MAX_POPULATION) {
                _safeMint(_msgSender(), EACH_MAX_POPULATION + state.malePopulation);
                state.malePopulation++;
                amountOfSuccess++;
            }
            factor >>= 1;
        }
        if (amountOfSuccess < amount) {
            Address.sendValue(payable(_msgSender()), (amount-amountOfSuccess)*APE_BIRTH_COST);
        }
    }

    ///@dev Owner reservation
    function reserve(uint8 amount, address to, bool female) external onlyOwner {
        if (female) {
            for (uint8 i = 0; i < amount; i++) {
                _safeMint(to, state.femalePopulation);
                state.femalePopulation++;                
            }
        }
        else {
            for (uint8 i = 0; i < amount; i++) {
                _safeMint(to, EACH_MAX_POPULATION + state.malePopulation);
                state.malePopulation++;               
            }
        }
    }

    ///@notice Set offset ID to shuffle
    function reveal() external {
        require(
            block.timestamp >= REVEAL_TIMESTAMP,
            "can't reveal now"
        );
        require(
            state.offsetId == 0,
            "already revealed"
        );
        state.offsetId = uint16(uint160(_msgSender()) ^ uint256(blockhash(block.number-1)))%EACH_MAX_POPULATION;
    }

    ///@notice Customized tokeURI
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(
            _exists(tokenId),
            "nonexistent ape"
        );
        uint256 mappingId;
        // female case
        if (tokenId < EACH_MAX_POPULATION) {
            mappingId = (tokenId + state.offsetId)%EACH_MAX_POPULATION;
        }
        // male case
        else {
            mappingId = (tokenId - EACH_MAX_POPULATION + state.offsetId)%EACH_MAX_POPULATION + EACH_MAX_POPULATION;
        }
        return string(abi.encodePacked(BASE_URI, mappingId.toString()));
    }
}
