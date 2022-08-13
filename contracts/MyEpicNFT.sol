// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;

    // Tracks tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Sub ID
    uint64 s_subscriptionId;

    // Rinkeby coordinator
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // The gas lane to use, which specifies the maximum gas price to bump to
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    uint32 callbackGasLimit = 100000;

    uint16 minimumRequestConfirmations = 3;

    // Retrieve 1 random value
    uint32 numWords = 1;

    uint256 public s_randomWords;

    uint256 public s_requestId;

    address s_owner;

    string[] colorNames = [
        "black",
        "red",
        "blue",
        "yellow",
        "purple",
        "green",
        "orange"
    ];

    string[] colors = [
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='black' /></svg>",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='red' /></svg",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='blue' /></svg",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='yellow' /></svg",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='purple' /></svg",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='green' /></svg",
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 100%'><rect width='100%' height='100%' fill='orange' /></svg"
    ];

    // Pass NFT name and symbol
    constructor(uint64 subscriptionId)
        ERC721("SquareNFT", "SQUARE")
        VRFConsumerBaseV2(vrfCoordinator)
    {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);

        s_owner = msg.sender;

        s_subscriptionId = subscriptionId;

        console.log("This is my NFT contract");
    }

    // Assumes subscription is funded sufficiently
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            minimumRequestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords[0] % colors.length;

        makeAnEpicNFT();
    }

    // Gets user's NFT
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        colorNames[s_randomWords],
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        colors[s_randomWords],
                        '"}'
                    )
                )
            )
        );

        console.log("json: ", json);

        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Mint NFT to sender
        _safeMint(msg.sender, newItemId);

        // Sets NFT data
        _setTokenURI(newItemId, finalTokenUri);

        // Increment counter for when the next NFT is minted
        _tokenIds.increment();

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }
}
