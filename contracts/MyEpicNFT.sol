// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import {Base64} from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage, VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // Is request fulfilled
        bool exists; // Does request exist
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; // requestId mapped => RequestStatus

    VRFCoordinatorV2Interface COORDINATOR;

    // Tracks tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // Sub ID
    uint64 s_subscriptionId;

    // Past requests ID
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Goerli coordinator
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

    // The gas lane to use, which specifies the maximum gas price to bump to
    bytes32 keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    // Retrieve 1 random value
    uint32 numWords = 1;

    uint256 public s_randomWords;

    uint256 newItemId;

    string[] colorNames = [
        "black",
        "blue",
        "green",
        "orange",
        "purple",
        "red",
        "white",
        "yellow"
    ];

    string[] colors = [
        "https://ipfs.io/ipfs/Qmdv9QsZ44okLofT6Aa5RF2TAXrKRsvNn1sk7hk2bFe31u?filename=black.png",
        "https://ipfs.io/ipfs/QmWB89r9dndX4A6kWEBNmTmRQKR62s9BweNUecRA3wHoev?filename=blue.png",
        "https://ipfs.io/ipfs/QmQg29DyNsdW4UNxhavewDy59TW9kFEUaRGq1LQL59veXS?filename=green.png",
        "https://ipfs.io/ipfs/QmP9KcvjdWMRKrCPzUML1sb8G4wGftz1S5Di7mLXdXoPGm?filename=orange.png",
        "https://ipfs.io/ipfs/QmeVXUPGrJndXTaX9RA3HG34AUbrVUiCXqiG9VJgUPUjfc?filename=purple.png",
        "https://ipfs.io/ipfs/QmX2oAgXLHzFT5PUByCvs9m1Sb4X9xXynpRGAHMzzRLrhL?filename=red.png",
        "https://ipfs.io/ipfs/QmPvtCGugMhnbtzh4GtTdC71EhmGb1EC7rVJf7sk6hEXoM?filename=white.png",
        "https://ipfs.io/ipfs/QmfHUQFp9St2HTaSrmqq7UaAyWqcTHyZ4PWPdLHYbf86xT?filename=yellow.png"
    ];

    // Pass NFT name and symbol
    constructor(uint64 subscriptionId)
        ERC721("SquareNFT", "SQUARE")
        VRFConsumerBaseV2(0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(
            0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D
        );

        s_subscriptionId = subscriptionId;

        console.log("This is my NFT contract");
    }

    // Assumes subscription is funded sufficiently
    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });

        requestIds.push(requestId);

        lastRequestId = requestId;

        emit RequestSent(requestId, numWords);

        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");

        s_requests[_requestId].fulfilled = true;

        s_requests[_requestId].randomWords = _randomWords;

        s_randomWords = _randomWords[0] % (colors.length - 1);

        emit RequestFulfilled(_requestId, _randomWords);
    }

    // Gets user's NFT
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        newItemId = _tokenIds.current();

        string memory name = colorNames[s_randomWords];

        string memory image = colors[s_randomWords];

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        name,
                        '", "description": "A highly acclaimed collection of squares.",',
                        '"image": "',
                        image,
                        '"}'
                    )
                )
            )
        );

        string memory tokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(tokenUri);
        console.log("--------------------\n");

        // Mint NFT to sender
        _safeMint(msg.sender, newItemId);

        // Sets NFT data
        _setTokenURI(newItemId, tokenUri);

        // Increment counter for when the next NFT is minted
        _tokenIds.increment();

        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
    }

    function getRequestStatus(uint256 _requestId)
        external
        view
        returns (bool fulfilled, uint256[] memory randomWords)
    {
        require(s_requests[_requestId].exists, "request not found");

        RequestStatus memory request = s_requests[_requestId];

        return (request.fulfilled, request.randomWords);
    }

    function getItemId() public view returns (uint256) {
        return newItemId;
    }

    function getItemName() public view returns (string memory) {
        return colorNames[s_randomWords];
    }

    function getItemColor() public view returns (string memory) {
        return colors[s_randomWords];
    }
}
