pragma solidity =0.5.16;

import "../_supportingContracts/IERC20.sol";
import "../_supportingContracts/SafeMath.sol";

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract CelebrityToken is IERC20 {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 private _totalSupply;
    uint256 private _totalCirculation;

    address public owner;
    address public creator;
    address public reserve;
    address public founder;
    uint8 private percentageAllocationToCreator;
    uint8 private percentageAllocationToReserve;
    uint8 private percentageAllocationToFounder;
    uint256 public id;
    string public vertical;
    string public category;
    bool private tradingAllowedOnCelebrityExchange;
    address public CelebrityExchangeAddress;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowed;

    event Failure(
        string contractName,
        string operation,
        string error,
        string info,
        address user,
        uint256 blockNumber
    );

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "ONLY CONTRACT OWNER CAN PERFORM OPERATION"
        );
        _;
    }

    /**
     * @dev Constructor to initialize the ERC-20 token
     * @param _name Name of the token
     * @param _symbol Symbol used for trading and wallet display purposes
     * @param _supply Total supply of the tokens
     */
    constructor(
        uint256 _id,
        string memory _vertical,
        string memory _category,
        string memory _name,
        string memory _symbol,
        uint256 _supply,
        address _owner,
        address _creator,
        address[3] memory CelebrityExchangeAddressReserveAndFounder,
        uint8[3] memory percentageAllocationToCreatorReserveAndFounder
    ) public {
        name = _name;
        symbol = _symbol;
        decimals = 18;
        _totalSupply = _supply;
        id = _id;
        owner = _owner;
        creator = _creator;
        founder = CelebrityExchangeAddressReserveAndFounder[2];
        reserve = CelebrityExchangeAddressReserveAndFounder[1];
        require(
            percentageAllocationToCreatorReserveAndFounder[0] <= 100 &&
                percentageAllocationToCreatorReserveAndFounder[1] <= 100 &&
                percentageAllocationToCreatorReserveAndFounder[2] <= 100,
            "Reserve and Creator allocations cannot be more than 100%"
        );
        percentageAllocationToCreator = percentageAllocationToCreatorReserveAndFounder[
            0
        ];
        percentageAllocationToReserve = percentageAllocationToCreatorReserveAndFounder[
            1
        ];
        percentageAllocationToFounder = percentageAllocationToCreatorReserveAndFounder[
            2
        ];
        // += just in case all 3 addresses or any 2 addresses are the same
        _balances[reserve] += _totalSupply
            .mul(percentageAllocationToReserve)
            .div(100);
        _balances[creator] += _totalSupply
            .mul(percentageAllocationToCreator)
            .div(100);
        _balances[founder] += _totalSupply
            .mul(percentageAllocationToFounder)
            .div(100);
        _balances[owner] += _totalSupply
            .mul(
            100 -
                (percentageAllocationToReserve) -
                (percentageAllocationToCreator)
        )
            .div(100);
        _totalCirculation = _balances[owner];
        vertical = _vertical;
        category = _category;
        CelebrityExchangeAddress = CelebrityExchangeAddressReserveAndFounder[0];
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Total number of tokens in circulation
     */
    function totalCirculation() public view returns (uint256) {
        return _totalCirculation;
    }

    function toggeleAllowTradingOnCelebrityExchange() public {
        require(
            msg.sender == owner || tx.origin == owner,
            "Only the owner or owner via exchange can change the status"
        );
        tradingAllowedOnCelebrityExchange = !tradingAllowedOnCelebrityExchange;
    }

    function isTradingAllowedOnCelebrityExchange() public view returns (bool) {
        return tradingAllowedOnCelebrityExchange;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param user The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address user) public view returns (uint256) {
        return _balances[user];
    }

    /**
     * @dev Function to check the amount of tokens that a user is allowed to a spender.
     * @param user address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address user, address spender)
        public
        view
        returns (uint256)
    {
        return _allowed[user][spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(_transfer(msg.sender, to, value), "Transaction Failed");
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(
            spender != address(0),
            "Spending delegation cannot be assigned to 0x00 address"
        );
        // approve() should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'increaseAllowance' and 'decreaseAllowance'
        require(
            value == 0 || (allowance(msg.sender, spender) == 0),
            "Call increaseAllowance() or decreaseAllowance() functions respectively"
        );
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        if (msg.sender != CelebrityExchangeAddress) {
            // Allow transfer to exchange even if not approved
            require(
                allowance(from, msg.sender) >= value,
                "Insufficient Allowance in token"
            );
            _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        }
        require(_transfer(from, to, value), "Transfer Failed");
        return true;
    }

    /**
     * @dev Increase the amount of tokens that a user allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        require(
            spender != address(0),
            "Spending delegation cannot be assigned to 0x00 address"
        );

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(
            addedValue
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that a user allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        require(
            spender != address(0),
            "Spending delegation cannot be assigned to 0x00 address"
        );

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(
            subtractedValue
        );
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        require(to != address(0), "Cannot transfer to 0x00 address");
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        if (from == owner) {
            _totalCirculation = _totalCirculation.sub(value);
        }
        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal onlyOwner {
        require(account != address(0), "Cannot mint to 0x00 address");
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal onlyOwner {
        require(account != address(0), "Cannot burn from 0x00 address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal onlyOwner {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
            value
        );
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }

    function changeExchangeAddress(address _CelebrityExchangeAddress)
        public
        onlyOwner
    {
        CelebrityExchangeAddress = _CelebrityExchangeAddress;
    }

    function updateTotalCirculation(uint256 _newTotalCirculation)
        public
        onlyOwner
    {
        require(
            _newTotalCirculation <= _balances[msg.sender],
            "Not enough tokens, consider minting"
        );
        _totalCirculation = _newTotalCirculation;
    }
}
