pragma solidity =0.5.16;

import "../_supportingContracts/ERC721MetadataMintable.sol";
import "../_supportingContracts/Ownable.sol";

contract CelebrityOwnerToken is ERC721MetadataMintable, Ownable {
    string public name;
    string public symbol;

    constructor(string memory _name, string memory _symbol)
        public
        ERC721Metadata(_name, _symbol)
    {
        name = _name;
        symbol = _symbol;
    }

    /**
     * Custom accessor to create a unique token
     */
    function mintUniqueTokenTo(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) public onlyOwner {
        mintWithTokenURI(_to, _tokenId, _tokenURI);
    }

    /**
     * Set Base URI for retrieving token details URL
     */
    function setBaseURI(string memory _baseURI) public onlyOwner {
        _setBaseURI(_baseURI);
    }
}
