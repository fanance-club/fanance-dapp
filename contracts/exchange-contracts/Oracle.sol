pragma solidity =0.5.16;

import "../_supportingContracts/AggregatorV3Interface.sol";
import "../_supportingContracts/Ownable.sol";
import "../FANC-token-contracts/FANCTokenICO.sol";

contract Oracle is Ownable {
    address public FANCTokenAddress;
    address payable public FANCTokenICOAddress;
    address public FANCExchangeAddress; // import FANCExchange contract and change FANCExchangeAddress to be exchange type instead of address
    AggregatorV3Interface public priceFeedContract;
    enum OracleType {ICO, EXCHANGE, EXTERNAL}
    OracleType public currentOracleType;

    event FANCTokenAddressSet(address FANCTokenAddress);

    constructor(
        address _FANCTokenAddress,
        address payable _FANCTokenICOAddress,
        address _FANCExchangeAddress,
        AggregatorV3Interface _priceFeedContract
    ) public {
        currentOracleType = OracleType.ICO;
        FANCTokenAddress = _FANCTokenAddress;
        FANCTokenICOAddress = _FANCTokenICOAddress;
        FANCExchangeAddress = _FANCExchangeAddress;
        priceFeedContract = _priceFeedContract;
    }

    function changeCustomOracleStatus(string memory _oracleType)
        public
        onlyOwner
    {
        if (keccak256(bytes(_oracleType)) == keccak256(bytes("ICO"))) {
            currentOracleType = OracleType.ICO;
        }
        if (keccak256(bytes(_oracleType)) == keccak256(bytes("EXCHANGE"))) {
            currentOracleType = OracleType.EXCHANGE;
        }
        if (keccak256(bytes(_oracleType)) == keccak256(bytes("EXTERNAL"))) {
            currentOracleType = OracleType.EXTERNAL;
        }
    }

    function setContractAddresses(
        address _FANCTokenAddress,
        address payable _FANCTokenICOAddress,
        address _FANCExchangeAddress,
        AggregatorV3Interface _priceFeedContract
    ) public onlyOwner {
        FANCTokenAddress = _FANCTokenAddress;
        FANCTokenICOAddress = _FANCTokenICOAddress;
        FANCExchangeAddress = _FANCExchangeAddress;
        priceFeedContract = _priceFeedContract;
    }

    /**
     * Returns the latest price
     */
    function getAssetPrice() public view returns (uint256) {
        if (currentOracleType == OracleType.ICO) {
            // Get latest price from FANC Exchange
            return FANCTokenICO(FANCTokenICOAddress).getLatestPrice();
            // return 1; // remove this when exchange implementation is done
        } else if (currentOracleType == OracleType.EXCHANGE) {
            return 1;
        } else if (currentOracleType == OracleType.EXTERNAL) {
            require(
                priceFeedContract != AggregatorV3Interface(address(0)),
                "Price Feed contract cannot be 0x00 address"
            );
            // Get price from Chainlink

            // (
            //     uint80 roundID,
            //     int price,
            //     uint startedAt,
            //     uint timeStamp,
            //     uint80 answeredInRound
            // ) = priceFeedContract.latestRoundData();
            // // If the round is not complete yet, timestamp is 0
            // require(timeStamp > 0, "Round not complete");
            // if(price >0) {
            //     // Magnify the result based on decimals
            //     return (uint256(price));
            // }
            // else {
            //     return 0;
            // }
            return 1;
        }
    }

    function() external payable {
        require(
            msg.sender.send(msg.value),
            "Fallback function initiated but refund failed"
        );
    }
}
