pragma solidity =0.5.16;

import "../_supportingContracts/SafeMath.sol";
import "../_supportingContracts/Ownable.sol";
import "../_supportingContracts/MaticWETH.sol";
import "./FANCTOKEN.sol";

contract FANCTokenICO is Ownable {
    using SafeMath for uint256;

    address public ICOTreasury;
    address public WETHTokenAddress;

    //token price in wei
    uint256 public tokenPrice;

    uint256 public ICORound;
    uint256 public raisedAmountTotal;
    uint256 public raisedAmountInCurrentRound;
    uint256 public numberOfInvestorsInCurrentRound;

    uint256 public maxInvestment;
    uint256 public minInvestment;

    struct investment {
        uint256 amount;
        uint256 tokens;
        bool existingInvestor;
    }
    address[] private investors;
    mapping(address => investment) public investmentOf;

    FANCTOKEN public token;

    enum State {notStarted, running, ended, halted}
    State public icoState;

    event InvestmentReceived(
        uint256 ICORound,
        address investor,
        uint256 value,
        uint256 tokens
    );
    event ICORoundStarted(
        uint256 tokenPrice,
        uint256 blockNumber,
        uint256 minInvestment,
        uint256 maxInvestment
    );
    event ICORoundEnded(
        uint256 tokenPrice,
        uint256 blockNumber,
        uint256 raisedAmountInCurrentRound,
        uint256 raisedAmountTotal,
        uint256 numberOfInvestors
    );
    event Failure(
        string contractName,
        string operation,
        string error,
        string info,
        address user,
        uint256 blockNumber
    );

    constructor(
        FANCTOKEN _token,
        address _WETHTokenAddress,
        address _ICOTreasury
    ) public {
        icoState = State.notStarted;
        ICORound = 0;
        numberOfInvestorsInCurrentRound = 0;
        raisedAmountInCurrentRound = 0;
        raisedAmountTotal = 0;
        maxInvestment = 0;
        minInvestment = 0;
        WETHTokenAddress = _WETHTokenAddress;
        token = _token;
        ICOTreasury = _ICOTreasury;
    }

    modifier isNotTradedOnExchange() {
        require(
            !token.tradedOnFANCExchange(),
            "FANC Token is traded on exchange"
        );
        _;
    }

    //emergency stop
    function halt() public onlyOwner {
        icoState = State.halted;
    }

    //restart
    function unhalt() public onlyOwner {
        icoState = State.running;
    }

    //returns ico state
    function getCurrentState() public view returns (State) {
        return icoState;
    }

    // start round
    function startNextRound(
        uint256 _tokenPrice,
        uint256 _minInvestment,
        uint256 _maxInvestment
    ) public onlyOwner isNotTradedOnExchange {
        require(icoState != State.running, "Existing round is still running");
        tokenPrice = _tokenPrice;
        icoState = State.running;
        ICORound = ICORound.add(1);
        minInvestment = _minInvestment;
        maxInvestment = _maxInvestment;
        emit ICORoundStarted(
            tokenPrice,
            block.number,
            maxInvestment,
            minInvestment
        );
    }

    // end round
    function endCurrentRound() public onlyOwner isNotTradedOnExchange {
        require(icoState == State.running, "ICO not actively running");
        icoState = State.ended;
        emit ICORoundEnded(
            tokenPrice,
            block.number,
            raisedAmountInCurrentRound,
            raisedAmountTotal,
            numberOfInvestorsInCurrentRound
        );
        numberOfInvestorsInCurrentRound = 0;
        raisedAmountInCurrentRound = 0;
    }

    function invest(uint256 _amount)
        public
        isNotTradedOnExchange
        returns (bool)
    {
        //invest only in running
        icoState = getCurrentState();
        require(icoState == State.running, "ICO not actively running");

        require(
            _amount >= minInvestment || _amount <= maxInvestment,
            "Investment out of min and max range"
        );

        uint256 tokens = (_amount.mul(10**token.decimals())).div(tokenPrice);

        raisedAmountTotal = raisedAmountTotal.add(_amount);
        raisedAmountInCurrentRound = raisedAmountInCurrentRound.add(_amount);

        //add tokens to investor balance from founder balance
        token.transferFrom(token.owner(), msg.sender, tokens);

        require(
            WETHToken(WETHTokenAddress).balanceOf(msg.sender) >= _amount,
            "Not enough balance in WETH contract for this transaction"
        );
        require(
            WETHToken(WETHTokenAddress).allowance(msg.sender, address(this)) >=
                _amount,
            "Not enough allowance in WETH contract for this exchange"
        );
        WETHToken(WETHTokenAddress).transferFrom(
            msg.sender,
            ICOTreasury,
            _amount
        );

        numberOfInvestorsInCurrentRound = numberOfInvestorsInCurrentRound.add(
            1
        );
        investment memory tempInvestment = investmentOf[msg.sender];
        tempInvestment.amount = tempInvestment.amount.add(_amount);
        tempInvestment.tokens = tempInvestment.tokens.add(tokens);
        if (!investmentOf[msg.sender].existingInvestor) {
            investors.push(msg.sender);
        }
        tempInvestment.existingInvestor = true;
        investmentOf[msg.sender] = tempInvestment;

        //emit event
        emit InvestmentReceived(ICORound, msg.sender, _amount, tokens);

        return true;
    }

    function refundAll() public onlyOwner {
        for (uint256 i = 0; i < investors.length; i++) {
            WETHToken(WETHTokenAddress).transfer(
                investors[i],
                investmentOf[investors[i]].amount
            );
        }
    }

    function investmentDetails(uint256 index)
        public
        view
        onlyOwner
        returns (uint256 amount, uint256 tokens)
    {
        return (
            investmentOf[investors[index]].amount,
            investmentOf[investors[index]].tokens
        );
    }

    function getAllInvestors()
        public
        view
        onlyOwner
        returns (address[] memory investorsList)
    {
        return investors;
    }

    function() external payable {
        revert();
    }

    function changeAddresses(
        FANCTOKEN _token,
        address _WETHTokenAddress,
        address _ICOTreasury
    ) public onlyOwner {
        token = _token;
        WETHTokenAddress = _WETHTokenAddress;
        ICOTreasury = _ICOTreasury;
    }

    function investAsAdmin(uint256 _amount)
        public
        onlyOwner
        isNotTradedOnExchange
    {
        WETHToken(WETHTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }

    function getLatestPrice() public view returns (uint256) {
        return tokenPrice;
    }

    function getNumberOfInvestors() public view returns (uint256) {
        return investors.length;
    }
}
