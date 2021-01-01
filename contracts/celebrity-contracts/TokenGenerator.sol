pragma solidity =0.5.16;
//SPDX-License-Identifier: MIT
import "../_supportingContracts/Ownable.sol";
import "./CelebrityERC20Token.sol";
import "./CelebrityERC721Token.sol";
import "../_supportingContracts/SafeMath.sol";

contract TokenGenerator is Ownable {
    using SafeMath for uint256;
    uint256 public counter;
    uint256 public defaultSupply;
    mapping(uint256 => address) private celebrity;
    address[] public celebrities;
    CelebrityOwnerToken public CelebrityNFTToken;
    address[3] public CelebrityExchangeAddressReserveAndFounder;
    uint8[3] public percentageAllocationToCreatorReserveAndFounder;

    constructor(
        CelebrityOwnerToken _ERC721TokenAddress,
        address _CelebrityExchangeAddress,
        address _reserve,
        address _founder,
        uint8 _percentageAllocationToCreator,
        uint8 _percentageAllocationToReserve,
        uint8 _percentageAllocationToFounder
    ) public {
        CelebrityNFTToken = _ERC721TokenAddress;
        counter = 1;
        celebrities.push(address(0)); // To make sure celebrities array gets filled from 1 and not 0
        defaultSupply = 1000000 * (10**18);
        CelebrityExchangeAddressReserveAndFounder[
            0
        ] = _CelebrityExchangeAddress;
        CelebrityExchangeAddressReserveAndFounder[1] = _reserve;
        CelebrityExchangeAddressReserveAndFounder[2] = _founder;
        percentageAllocationToCreatorReserveAndFounder[
            0
        ] = _percentageAllocationToCreator;
        percentageAllocationToCreatorReserveAndFounder[
            1
        ] = _percentageAllocationToReserve;
        percentageAllocationToCreatorReserveAndFounder[
            2
        ] = _percentageAllocationToFounder;
    }

    function setDetails(
        CelebrityOwnerToken _ERC721TokenAddress,
        address _CelebrityExchangeAddress,
        address _reserve,
        address _founder,
        uint8 _percentageAllocationToCreator,
        uint8 _percentageAllocationToReserve,
        uint8 _percentageAllocationToFounder
    ) public onlyOwner {
        CelebrityNFTToken = _ERC721TokenAddress;
        CelebrityExchangeAddressReserveAndFounder[
            0
        ] = _CelebrityExchangeAddress;
        CelebrityExchangeAddressReserveAndFounder[1] = _reserve;
        CelebrityExchangeAddressReserveAndFounder[2] = _founder;
        percentageAllocationToCreatorReserveAndFounder[
            0
        ] = _percentageAllocationToCreator;
        percentageAllocationToCreatorReserveAndFounder[
            1
        ] = _percentageAllocationToReserve;
        percentageAllocationToCreatorReserveAndFounder[
            2
        ] = _percentageAllocationToFounder;
    }

    struct CelebrityDetails {
        uint256 celebrityId;
        address tokenAddress;
        address requester;
        string vertical;
        string category;
        string celebrityName;
        string country;
        string DOB;
        string symbol;
    }
    CelebrityDetails[] public celebrityCreationRequests;

    event celebrityTokenRequestGenerated(uint256 id, address creator);

    function requestCelebrityCreation(
        string memory _vertical,
        string memory _category,
        string memory _celebrityName,
        string memory _country,
        string memory _DOB,
        string memory _symbol
    ) public {
        require(
            keccak256(bytes(_vertical)) != keccak256(bytes("")) &&
                keccak256(bytes(_category)) != keccak256(bytes("")) &&
                keccak256(bytes(_celebrityName)) != keccak256(bytes("")) &&
                keccak256(bytes(_country)) != keccak256(bytes("")) &&
                keccak256(bytes(_DOB)) != keccak256(bytes("")) &&
                keccak256(bytes(_symbol)) != keccak256(bytes("")),
            "Check the inputs"
        );
        CelebrityDetails memory tempCelebrity =
            CelebrityDetails(
                0, // Will generate actual id if approved
                address(0), // Will generate actual address if approved
                msg.sender,
                _vertical,
                _category,
                _celebrityName,
                _country,
                _DOB,
                _symbol
            );
        celebrityCreationRequests.push(tempCelebrity);
        emit celebrityTokenRequestGenerated(
            celebrityCreationRequests.length.sub(1),
            msg.sender
        );
    }

    event celebrityTokenRequestApproved(
        uint256 id,
        uint256 celebrityID,
        address celebrityTokenAddress
    );
    event celebrityTokenRequestRejected(uint256 id, string reason);

    function approveRequest(uint256 _id) public onlyOwner {
        (address tokenAddress, uint256 _celebrityId) = generateToken(_id);
        celebrityCreationRequests[_id].celebrityId = _celebrityId;
        celebrityCreationRequests[_id].tokenAddress = tokenAddress;
        emit celebrityTokenRequestApproved(_id, _celebrityId, tokenAddress);
    }

    function changeDefaultSupply(uint256 _supplyInWholeNumber)
        public
        onlyOwner
    {
        defaultSupply = _supplyInWholeNumber * (10**18);
    }

    function rejectRequest(uint256 _id, string memory _reason)
        public
        onlyOwner
    {
        emit celebrityTokenRequestRejected(_id, _reason);
    }

    // provision for others to create tokens
    event celebrityTokenGenerated(
        uint256 id,
        address ERC20Address,
        address creator,
        string tokenName,
        string symbol,
        uint256 supply
    );

    function generateToken(uint256 _id) private returns (address, uint256) {
        CelebrityDetails memory tempCelebrity = celebrityCreationRequests[_id];
        string memory tokenName =
            string(
                abi.encodePacked(
                    tempCelebrity.vertical,
                    "-",
                    tempCelebrity.category,
                    "-",
                    tempCelebrity.celebrityName,
                    "-",
                    tempCelebrity.country,
                    "-",
                    tempCelebrity.DOB
                )
            );
        string memory FCSymbol =
            string(abi.encodePacked("FC-", tempCelebrity.symbol));
        address newCelebrity =
            address(
                new CelebrityToken(
                    counter,
                    tempCelebrity.vertical,
                    tempCelebrity.category,
                    tokenName,
                    FCSymbol,
                    defaultSupply,
                    owner(),
                    tempCelebrity.requester,
                    CelebrityExchangeAddressReserveAndFounder,
                    percentageAllocationToCreatorReserveAndFounder
                )
            );
        string memory tokenURI =
            string(
                abi.encodePacked(tokenName, "-0x", toAsciiString(newCelebrity))
            ); // 0x at the beginning gets truncated during conversion, so adding manually
        CelebrityNFTToken.mintUniqueTokenTo(
            tempCelebrity.requester,
            counter,
            tokenURI
        );
        celebrity[counter] = newCelebrity;
        celebrities.push(newCelebrity);
        emit celebrityTokenGenerated(
            counter,
            newCelebrity,
            tempCelebrity.requester,
            tokenName,
            FCSymbol,
            defaultSupply
        );
        counter = counter.add(1);
        return (newCelebrity, counter.sub(1));
    }

    function setCounter(uint256 _counter) public onlyOwner {
        counter = _counter;
    }

    function transferCelebrityNFTTokenOwnership(address newOwner)
        public
        onlyOwner
    {
        CelebrityNFTToken.transferOwnership(newOwner);
    }

    function getAllCelebrities() public view returns (address[] memory) {
        return celebrities;
    }

    // Below functions are to convert address to string => https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function toAsciiString(address x) private pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint256(x) / (2**(8 * (19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }

    function char(bytes1 b) private pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }
}
