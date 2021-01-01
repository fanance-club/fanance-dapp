pragma solidity =0.5.16;
import "../_supportingContracts/SafeMath.sol";
import "../_supportingContracts/Ownable.sol";
import "../celebrity-contracts/CelebrityERC20Token.sol";
import "../celebrity-contracts/CelebrityERC721Token.sol";
import "../_supportingContracts/MaticWETH.sol";
import "../FANC-token-contracts/FANCTOKEN.sol";
import "./Oracle.sol";

contract CelebrityExchange is Ownable {
    using SafeMath for uint256;
    uint256 public feePercent;
    uint256 public allocationToNFTOwner;
    address public WETHERADDRESS; //store Ether in tokens mapping with blank address
    address public FANCTOKENAddress; //store FANC Tokens in tokens mapping with FANC Token address
    address payable public ORACLEADDRESS;
    address public CelebrityOwnerTokenAddress;
    mapping(address => mapping(address => uint256))
        public tokensAndEtherInExchange;
    mapping(address => uint256) public feeCollectedInEther;
    mapping(address => uint256) public feeCollectedInFANC;
    mapping(uint256 => _BuyOrder) public buyOrders;
    mapping(uint256 => _SellOrder) public sellOrders;
    uint256 public buyOrderCount;
    uint256 public sellOrderCount;
    uint8 private sellPriceSpread;
    mapping(address => uint256) public latestPrice;
    mapping(address => uint256) public currentHighestSellOrderPrice;
    uint256[3] internal highestThreeBuyOrderQuantities;
    uint256[3] internal highestThreeBuyOrderPrices;
    mapping(address => uint256) private initialSellOrder;
    uint256 public minWithdrawalInEtherAllowed;

    constructor(
        uint256 _feePercent,
        address _FANCTokenAddress,
        address _WETHERAddress,
        address _CelebrityOwnerTokenAddress,
        address payable _oracleAddress,
        uint256 _allocationToNFTOwner,
        uint8 _sellPriceSpread,
        uint256 _minWithdrawalInEtherAllowed // Protocol multiplies the argument by 10**10
    ) public {
        feePercent = _feePercent;
        allocationToNFTOwner = _allocationToNFTOwner;
        FANCTOKENAddress = _FANCTokenAddress;
        WETHERADDRESS = _WETHERAddress;
        ORACLEADDRESS = _oracleAddress;
        CelebrityOwnerTokenAddress = _CelebrityOwnerTokenAddress;
        sellPriceSpread = _sellPriceSpread;
        minWithdrawalInEtherAllowed = _minWithdrawalInEtherAllowed * (10**10);
    }

    function() external {
        revert();
    }

    event BuyOrderPlaced(
        uint256 id,
        address user,
        address celebrityToken,
        uint256 tokenBuy,
        uint256 amountSend,
        uint256 feesInEther,
        uint256 feesInFANC,
        uint256 price,
        uint256 timestamp
    );
    event SellOrderPlaced(
        uint256 id,
        address user,
        address celebrityToken,
        uint256 tokenSell,
        uint256 amountReceive,
        uint256 price,
        uint256 timestamp
    );
    event InitialSellOrderPlaced(
        uint256 id,
        address user,
        address celebrityToken,
        uint256 tokenSell,
        uint256 amountReceive,
        uint256 price,
        uint256 timestamp
    );
    event InitialSellOrderUpdated(
        address celebrityToken,
        uint256 tokenSell,
        uint256 amountReceive,
        uint256 price,
        uint256 timestamp
    );
    event BuyOrderCancelled(
        uint256 id,
        address user,
        address celebrityToken,
        uint256 timestamp
    );
    event SellOrderCancelled(
        uint256 id,
        address user,
        address celebrityToken,
        uint256 timestamp
    );
    event BuyOrderPartiallyFilled(
        uint256 id,
        address executor,
        uint256 numberOfTokens,
        uint256 price,
        uint256 tokensLeftToBuy,
        uint256 etherAmountLeft,
        uint256 timestamp
    );
    event SellOrderPartiallyFilled(
        uint256 id,
        address executor,
        uint256 numberOfTokens,
        uint256 price,
        uint256 tokensLeftToSell,
        uint256 etherAmountLeft,
        uint256 timestamp
    );
    event BuyOrderFilled(
        uint256 id,
        address executor,
        uint256 numberOfTokens,
        uint256 price,
        uint256 timestamp
    );
    event SellOrderFilled(
        uint256 id,
        address executor,
        uint256 numberOfTokens,
        uint256 price,
        uint256 timestamp
    );

    enum OrderStatus {OPEN, PARTIALLYFILLED, FILLED, CANCELLED}
    //a way to model Order - Struct
    struct _OrderFills {
        address user;
        uint256 tokensFilled;
        uint256 amount;
        uint256 timestamp;
    }
    mapping(uint256 => _OrderFills[]) public buyOrderExecutedTrades;
    mapping(uint256 => _OrderFills[]) public sellOrderExecutedTrades;
    struct _BuyOrder {
        uint256 id;
        address user;
        address celebrityToken;
        uint256 tokenBuy;
        uint256 amountSend;
        uint256 buyPrice;
        uint256 tokensLeftToBuy;
        uint256 etherAmountLeft;
        uint256 feeAllocatedAsEther;
        uint256 feeAllocatedAsFANC;
        bool isFeePaidUsingFANC;
        uint256 currentFeePercent;
        uint256 timestamp;
        OrderStatus status;
    }
    struct _SellOrder {
        uint256 id;
        address payable user;
        address celebrityToken;
        uint256 tokenSell;
        uint256 amountReceive;
        uint256 sellPrice;
        uint256 tokensLeftToSell;
        uint256 etherAmountLeft;
        uint256 feeAllocatedAsEther;
        uint256 feeAllocatedAsFANC;
        bool isFeePaidUsingFANC;
        uint256 currentFeePercent;
        uint256 timestamp;
        OrderStatus status;
    }

    function changeTokenAddress(
        address _FANCTokenAddress,
        address _WETHERAddress,
        address payable _oracleAddress,
        address _CelebrityOwnerTokenAddress
    ) public onlyOwner {
        FANCTOKENAddress = _FANCTokenAddress;
        WETHERADDRESS = _WETHERAddress;
        ORACLEADDRESS = _oracleAddress;
        CelebrityOwnerTokenAddress = _CelebrityOwnerTokenAddress;
    }

    function changeFeePercent(
        uint256 _feePercent,
        uint256 _allocationToNFTOwner,
        uint8 _sellPriceSpread,
        uint256 _minWithdrawalInEtherAllowed10Power6 // Protocol multiplies the argument by 10**10
    ) public onlyOwner {
        feePercent = _feePercent;
        allocationToNFTOwner = _allocationToNFTOwner;
        sellPriceSpread = _sellPriceSpread;
        minWithdrawalInEtherAllowed =
            _minWithdrawalInEtherAllowed10Power6 *
            (10**10);
    }

    function placeBuyOrder(
        address _celebrityToken,
        uint256 _tokenBuy,
        uint256 _amountSend,
        uint256 _fees,
        bool _usingFANCTokenForFees
    ) public {
        require(
            CelebrityToken(_celebrityToken)
                .isTradingAllowedOnCelebrityExchange(),
            "Trading of this Celebrity asset not allowed"
        );
        uint256 askPrice = _amountSend.mul(10**18).div(_tokenBuy);
        uint256 tempFeeAsEther = 0;
        uint256 tempFeeAsFANC = 0;
        if (_usingFANCTokenForFees) {
            uint256 FANCTokenPriceInEther =
                Oracle(ORACLEADDRESS).getAssetPrice();
            require(
                _fees ==
                    _amountSend
                        .mul(feePercent)
                        .mul(FANCTokenPriceInEther)
                        .div(2)
                        .div(10**36), // Due to multiplication by 10**18 twice in feepercent and fantokenprice
                "Incorrect fee entered"
            );
            _getFANCFrom(msg.sender, _fees);
            _getEtherFrom(msg.sender, _amountSend);
            tempFeeAsFANC = _fees;
        } else {
            require(
                _fees == (_amountSend.mul(feePercent).div(10**18)),
                "Incorrect fee entered"
            );
            _getEtherFrom(msg.sender, _amountSend.add(_fees));
            tempFeeAsEther = _fees;
        }
        buyOrders[buyOrderCount] = _BuyOrder(
            buyOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenBuy,
            _amountSend,
            askPrice,
            _tokenBuy,
            _amountSend,
            tempFeeAsEther,
            tempFeeAsFANC,
            _usingFANCTokenForFees,
            feePercent,
            block.timestamp,
            OrderStatus.OPEN
        );

        tokensAndEtherInExchange[WETHERADDRESS][
            msg.sender
        ] = tokensAndEtherInExchange[WETHERADDRESS][msg.sender].add(
            _amountSend
        );
        emit BuyOrderPlaced(
            buyOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenBuy,
            _amountSend,
            tempFeeAsEther,
            tempFeeAsFANC,
            askPrice,
            block.timestamp
        );
        buyOrderCount = buyOrderCount.add(1);
        // _updateInitialSellOrderOnBuyOrderChange(
        // 	_celebrityToken,
        // 	askPrice,
        // 	_tokenBuy
        // );
    }

    // function _updateInitialSellOrderOnSellOrderChange(
    // 	address _celebrityToken,
    // 	uint256 bidPrice
    // ) internal {
    // 	if (
    // 		bidPrice > currentHighestSellOrderPrice[_celebrityToken] &&
    // 		bidPrice <=
    // 		currentHighestSellOrderPrice[_celebrityToken].add(
    // 			(
    // 				currentHighestSellOrderPrice[_celebrityToken]
    // 					.mul(sellPriceSpread)
    // 					.div(100 * 10**18)
    // 			)
    // 		)
    // 	) {
    // 		// update existing admin order
    // 		// update price and quantity
    // 		currentHighestSellOrderPrice[_celebrityToken] = bidPrice;

    // 		uint256 updatedPrice = bidPrice;
    // 		uint256 newEtherToBeSent =
    // 			sellOrders[initialSellOrder[_celebrityToken]]
    // 				.tokensLeftToSell
    // 				.mul(10**18)
    // 				.div(updatedPrice);
    // 		sellOrders[initialSellOrder[_celebrityToken]].amountReceive = sellOrders[
    // 			initialSellOrder[_celebrityToken]
    // 		]
    // 			.amountReceive
    // 			.add(newEtherToBeSent);
    // 		sellOrders[initialSellOrder[_celebrityToken]]
    // 			.etherAmountLeft = sellOrders[initialSellOrder[_celebrityToken]]
    // 			.etherAmountLeft
    // 			.add(newEtherToBeSent);
    // 	}
    // }

    // function _updateInitialSellOrderOnBuyOrderChange(
    // 	address _celebrityToken,
    // 	uint256 askPrice,
    // 	uint256 _tokenBuy
    // ) internal {
    // 	if (askPrice >= highestThreeBuyOrderPrices[0]) {
    // 		highestThreeBuyOrderPrices[2] = highestThreeBuyOrderPrices[1];
    // 		highestThreeBuyOrderPrices[1] = highestThreeBuyOrderPrices[0];
    // 		highestThreeBuyOrderPrices[0] = askPrice;
    // 		// update equivalent quantity
    // 		highestThreeBuyOrderQuantities[2] = highestThreeBuyOrderQuantities[1];
    // 		highestThreeBuyOrderQuantities[1] = highestThreeBuyOrderQuantities[0];
    // 		highestThreeBuyOrderQuantities[0] = _tokenBuy;
    // 	} else if (askPrice >= highestThreeBuyOrderPrices[1]) {
    // 		highestThreeBuyOrderPrices[2] = highestThreeBuyOrderPrices[1];
    // 		highestThreeBuyOrderPrices[1] = askPrice;
    // 		// update equivalent quantity
    // 		highestThreeBuyOrderQuantities[2] = highestThreeBuyOrderQuantities[1];
    // 		highestThreeBuyOrderQuantities[1] = _tokenBuy;
    // 	} else if (askPrice >= highestThreeBuyOrderPrices[2]) {
    // 		highestThreeBuyOrderPrices[2] = askPrice;
    // 		highestThreeBuyOrderQuantities[2] = _tokenBuy;
    // 	}
    // 	if (askPrice >= highestThreeBuyOrderPrices[2]) {
    // 		uint256 newBuyQuantity =
    // 			highestThreeBuyOrderQuantities[0]
    // 				.add(highestThreeBuyOrderQuantities[1])
    // 				.add(highestThreeBuyOrderQuantities[2]);
    // 		if (
    // 			sellOrders[initialSellOrder[_celebrityToken]].tokensLeftToSell <
    // 			newBuyQuantity
    // 		) {
    // 			uint256 newSellQuantity =
    // 				newBuyQuantity.sub(
    // 					sellOrders[initialSellOrder[_celebrityToken]].tokensLeftToSell
    // 				);
    // 			sellOrders[initialSellOrder[_celebrityToken]].tokenSell = sellOrders[
    // 				initialSellOrder[_celebrityToken]
    // 			]
    // 				.tokenSell
    // 				.add(newSellQuantity);
    // 			sellOrders[initialSellOrder[_celebrityToken]]
    // 				.tokensLeftToSell = sellOrders[initialSellOrder[_celebrityToken]]
    // 				.tokensLeftToSell
    // 				.add(newSellQuantity);
    // 			uint256 currentPrice =
    // 				sellOrders[initialSellOrder[_celebrityToken]].sellPrice;
    // 			uint256 newEtherToBeSent =
    // 				newSellQuantity.mul(10**18).div(currentPrice);
    // 			sellOrders[initialSellOrder[_celebrityToken]]
    // 				.amountReceive = sellOrders[initialSellOrder[_celebrityToken]]
    // 				.amountReceive
    // 				.add(newEtherToBeSent);
    // 			sellOrders[initialSellOrder[_celebrityToken]]
    // 				.etherAmountLeft = sellOrders[initialSellOrder[_celebrityToken]]
    // 				.etherAmountLeft
    // 				.add(newEtherToBeSent);
    // 		}
    // 	}
    // }

    function placeSellOrder(
        address _celebrityToken,
        uint256 _tokenSell,
        uint256 _amountReceive,
        uint256 _fees,
        bool _usingFANCTokenForFees
    ) public {
        require(
            CelebrityToken(_celebrityToken).balanceOf(msg.sender) >= _tokenSell,
            "Not enough token balance to place order"
        );
        require(
            CelebrityToken(_celebrityToken)
                .isTradingAllowedOnCelebrityExchange(),
            "Trading of this Celebrity asset not allowed"
        );
        uint256 bidPrice = _amountReceive.mul(10**18).div(_tokenSell);
        uint256 tempFeeAsEther = 0;
        uint256 tempFeeAsFANC = 0;
        if (_usingFANCTokenForFees) {
            uint256 FANCTokenPriceInEther =
                Oracle(ORACLEADDRESS).getAssetPrice();
            require(
                _fees ==
                    _amountReceive
                        .mul(feePercent)
                        .mul(FANCTokenPriceInEther)
                        .div(2)
                        .div(10**36), // Due to multiplication by 10**18 twice in feepercent and fantokenprice
                "Incorrect fee entered"
            );
            _getFANCFrom(msg.sender, _fees);
            tempFeeAsFANC = _fees;
        } else {
            require(
                _fees == (_amountReceive.mul(feePercent).div(10**18)),
                "Incorrect fee entered"
            );
            _getEtherFrom(msg.sender, _amountReceive);
            tempFeeAsEther = _fees;
        }
        _getTokenFrom(_celebrityToken, msg.sender, _tokenSell);
        sellOrders[sellOrderCount] = _SellOrder(
            sellOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenSell,
            _amountReceive,
            bidPrice,
            _tokenSell,
            _amountReceive,
            tempFeeAsEther,
            tempFeeAsFANC,
            _usingFANCTokenForFees,
            feePercent,
            block.timestamp,
            OrderStatus.OPEN
        );
        tokensAndEtherInExchange[_celebrityToken][
            msg.sender
        ] = tokensAndEtherInExchange[_celebrityToken][msg.sender].add(
            _tokenSell
        );
        emit SellOrderPlaced(
            sellOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenSell,
            _amountReceive,
            bidPrice,
            block.timestamp
        );
        sellOrderCount = sellOrderCount.add(1);
        // _updateInitialSellOrderOnSellOrderChange(_celebrityToken, bidPrice);
    }

    function fillBuyOrder(
        uint256 _buyOrderId,
        uint256 _tokensFilled,
        uint256 _fees,
        bool _usingFANCTokenForFees
    ) public {
        require(
            msg.sender != buyOrders[_buyOrderId].user,
            "Same user cannot place and fill the order"
        );
        require(
            _buyOrderId >= 0 && _buyOrderId < buyOrderCount,
            "Order does not exist"
        );
        require(
            buyOrders[_buyOrderId].status != OrderStatus.FILLED &&
                buyOrders[_buyOrderId].status != OrderStatus.CANCELLED,
            "Order has been Filled or Cancelled"
        );
        require(
            _tokensFilled > 0 &&
                _tokensFilled <= buyOrders[_buyOrderId].tokensLeftToBuy,
            "Not enough tokens left in the order to execute"
        );
        // get fees
        uint256 tempFeeAsEther = 0;
        uint256 tempFeeAsFANC = 0;
        uint256 tradeAmount =
            _tokensFilled.mul(buyOrders[_buyOrderId].buyPrice).div(10**18);
        if (_usingFANCTokenForFees) {
            uint256 FANCTokenPriceInEther =
                Oracle(ORACLEADDRESS).getAssetPrice();
            require(
                _fees ==
                    tradeAmount
                        .mul(feePercent)
                        .mul(FANCTokenPriceInEther)
                        .div(2)
                        .div(10**36), // Due to multiplication by 10**18 twice in feepercent and fantokenprice
                "Incorrect fee entered"
            );
            _getFANCFrom(msg.sender, _fees);
            tempFeeAsFANC = _fees;
        } else {
            require(
                _fees == (tradeAmount.mul(feePercent).div(10**18)),
                "Incorrect fee entered"
            );
            _getEtherFrom(msg.sender, _fees);
            tempFeeAsEther = _fees;
        }
        // send token from sender to buyer
        _transferTokenFromTo(
            buyOrders[_buyOrderId].celebrityToken,
            msg.sender,
            buyOrders[_buyOrderId].user,
            _tokensFilled
        );
        // send ether to sender
        _sendEtherTo(msg.sender, tradeAmount);

        _calculateAndAllocateFeesForBuyOrderFill(
            _buyOrderId,
            _tokensFilled,
            tempFeeAsFANC,
            tempFeeAsEther
        );
        buyOrders[_buyOrderId].tokensLeftToBuy = buyOrders[_buyOrderId]
            .tokensLeftToBuy
            .sub(_tokensFilled);
        buyOrders[_buyOrderId].etherAmountLeft = buyOrders[_buyOrderId]
            .etherAmountLeft
            .sub(tradeAmount);
        tokensAndEtherInExchange[WETHERADDRESS][
            buyOrders[_buyOrderId].user
        ] = tokensAndEtherInExchange[WETHERADDRESS][buyOrders[_buyOrderId].user]
            .sub(tradeAmount);
        if (buyOrders[_buyOrderId].tokensLeftToBuy != 0) {
            buyOrders[_buyOrderId].status = OrderStatus.PARTIALLYFILLED;
            emit BuyOrderPartiallyFilled(
                buyOrders[_buyOrderId].id,
                msg.sender,
                _tokensFilled,
                buyOrders[_buyOrderId].buyPrice,
                buyOrders[_buyOrderId].tokensLeftToBuy,
                buyOrders[_buyOrderId].etherAmountLeft,
                block.timestamp
            );
        } else {
            buyOrders[_buyOrderId].status = OrderStatus.FILLED;
            emit BuyOrderFilled(
                buyOrders[_buyOrderId].id,
                msg.sender,
                _tokensFilled,
                buyOrders[_buyOrderId].buyPrice,
                block.timestamp
            );
        }
        latestPrice[buyOrders[_buyOrderId].celebrityToken] = buyOrders[
            _buyOrderId
        ]
            .buyPrice;
        buyOrderExecutedTrades[_buyOrderId].push(
            _OrderFills(msg.sender, _tokensFilled, tradeAmount, block.timestamp)
        );
    }

    function fillSellOrder(
        uint256 _sellOrderId,
        uint256 _tokensFilled,
        uint256 _fees,
        bool _usingFANCTokenForFees
    ) public {
        // send ether from sender to seller
        // send token to sender
        // get fees
        require(
            msg.sender != sellOrders[_sellOrderId].user,
            "Same user cannot place and fill the order"
        );
        require(
            _sellOrderId >= 0 && _sellOrderId < sellOrderCount,
            "Order does not exist"
        );
        require(
            sellOrders[_sellOrderId].status != OrderStatus.FILLED &&
                sellOrders[_sellOrderId].status != OrderStatus.CANCELLED,
            "Order has been Filled or Cancelled"
        );
        require(
            _tokensFilled > 0 &&
                _tokensFilled <= sellOrders[_sellOrderId].tokensLeftToSell,
            "Not enough tokens left in the order to execute"
        );
        // get fees
        uint256 tempFeeAsEther = 0;
        uint256 tempFeeAsFANC = 0;
        uint256 tradeAmount =
            _tokensFilled.mul(sellOrders[_sellOrderId].sellPrice).div(10**18);
        if (_usingFANCTokenForFees) {
            uint256 FANCTokenPriceInEther =
                Oracle(ORACLEADDRESS).getAssetPrice();
            require(
                _fees ==
                    tradeAmount
                        .mul(feePercent)
                        .mul(FANCTokenPriceInEther)
                        .div(2)
                        .div(10**36), // Due to multiplication by 10**18 twice in feepercent and fantokenprice
                "Incorrect fee entered"
            );
            _getFANCFrom(msg.sender, _fees);
            tempFeeAsFANC = _fees;
        } else {
            require(
                _fees == (tradeAmount.mul(feePercent).div(10**18)),
                "Incorrect fee entered"
            );
            _getEtherFrom(msg.sender, _fees);
            tempFeeAsEther = _fees;
        }
        // send ether from sender to seller
        _transferEtherFromTo(
            msg.sender,
            sellOrders[_sellOrderId].user,
            tradeAmount
        );
        // send token to sender
        _sendTokenTo(
            sellOrders[_sellOrderId].celebrityToken,
            msg.sender,
            _tokensFilled
        );

        _calculateAndAllocateFeesForSellOrderFill(
            _sellOrderId,
            _tokensFilled,
            tempFeeAsFANC,
            tempFeeAsEther
        );
        sellOrders[_sellOrderId].tokensLeftToSell = sellOrders[_sellOrderId]
            .tokensLeftToSell
            .sub(_tokensFilled);
        sellOrders[_sellOrderId].etherAmountLeft = sellOrders[_sellOrderId]
            .etherAmountLeft
            .sub(tradeAmount);
        tokensAndEtherInExchange[sellOrders[_sellOrderId].celebrityToken][
            sellOrders[_sellOrderId].user
        ] = tokensAndEtherInExchange[sellOrders[_sellOrderId].celebrityToken][
            sellOrders[_sellOrderId].user
        ]
            .sub(tradeAmount);
        if (sellOrders[_sellOrderId].tokensLeftToSell != 0) {
            sellOrders[_sellOrderId].status = OrderStatus.PARTIALLYFILLED;
            emit SellOrderPartiallyFilled(
                sellOrders[_sellOrderId].id,
                msg.sender,
                _tokensFilled,
                sellOrders[_sellOrderId].sellPrice,
                sellOrders[_sellOrderId].tokensLeftToSell,
                sellOrders[_sellOrderId].etherAmountLeft,
                block.timestamp
            );
        } else {
            sellOrders[_sellOrderId].status = OrderStatus.FILLED;
            emit SellOrderFilled(
                sellOrders[_sellOrderId].id,
                msg.sender,
                _tokensFilled,
                sellOrders[_sellOrderId].sellPrice,
                block.timestamp
            );
        }
        latestPrice[sellOrders[_sellOrderId].celebrityToken] = sellOrders[
            _sellOrderId
        ]
            .sellPrice;
        sellOrderExecutedTrades[_sellOrderId].push(
            _OrderFills(msg.sender, _tokensFilled, tradeAmount, block.timestamp)
        );
    }

    function cancelBuyOrder(uint256 _buyOrderId) public {
        require(
            msg.sender == buyOrders[_buyOrderId].user,
            "Only the user who placed the order can cancel it"
        );
        uint256 etherToRefund =
            buyOrders[_buyOrderId].etherAmountLeft +
                buyOrders[_buyOrderId].feeAllocatedAsEther;
        _sendEtherTo(buyOrders[_buyOrderId].user, etherToRefund);
        uint256 FANCToRefund = buyOrders[_buyOrderId].feeAllocatedAsFANC;
        _sendFANCTo(buyOrders[_buyOrderId].user, FANCToRefund);
        tokensAndEtherInExchange[WETHERADDRESS][
            buyOrders[_buyOrderId].user
        ] = tokensAndEtherInExchange[WETHERADDRESS][buyOrders[_buyOrderId].user]
            .sub(buyOrders[_buyOrderId].etherAmountLeft);
        buyOrders[_buyOrderId].status = OrderStatus.CANCELLED;
        emit BuyOrderCancelled(
            _buyOrderId,
            buyOrders[_buyOrderId].user,
            buyOrders[_buyOrderId].celebrityToken,
            block.timestamp
        );
    }

    function cancelSellOrder(uint256 _sellOrderId) public {
        require(
            msg.sender == sellOrders[_sellOrderId].user,
            "Only the user who placed the order can cancel it"
        );
        uint256 etherToRefund = sellOrders[_sellOrderId].feeAllocatedAsEther;
        _sendEtherTo(sellOrders[_sellOrderId].user, etherToRefund);
        uint256 tokenToRefund = sellOrders[_sellOrderId].tokensLeftToSell;
        _sendTokenTo(
            sellOrders[_sellOrderId].celebrityToken,
            sellOrders[_sellOrderId].user,
            tokenToRefund
        );
        uint256 FANCToRefund = sellOrders[_sellOrderId].feeAllocatedAsFANC;
        _sendFANCTo(sellOrders[_sellOrderId].user, FANCToRefund);
        tokensAndEtherInExchange[sellOrders[_sellOrderId].celebrityToken][
            sellOrders[_sellOrderId].user
        ] = tokensAndEtherInExchange[sellOrders[_sellOrderId].celebrityToken][
            sellOrders[_sellOrderId].user
        ]
            .sub(sellOrders[_sellOrderId].etherAmountLeft);
        sellOrders[_sellOrderId].status = OrderStatus.CANCELLED;
        emit SellOrderCancelled(
            _sellOrderId,
            sellOrders[_sellOrderId].user,
            sellOrders[_sellOrderId].celebrityToken,
            block.timestamp
        );
    }

    function placeInitialSellOrder(
        address _celebrityToken,
        uint256 _tokenSell,
        uint256 _amountReceive
    ) public onlyOwner {
        require(
            CelebrityToken(_celebrityToken).balanceOf(msg.sender) >= _tokenSell,
            "Not enough token balance to place order"
        );
        require(
            !CelebrityToken(_celebrityToken)
                .isTradingAllowedOnCelebrityExchange(),
            "Initial Sell order cannot be placed when token already traded in exchange"
        );
        CelebrityToken(_celebrityToken)
            .toggeleAllowTradingOnCelebrityExchange();

        uint256 bidPrice = _amountReceive.mul(10**18).div(_tokenSell);

        _getTokenFrom(_celebrityToken, msg.sender, _tokenSell);
        sellOrders[sellOrderCount] = _SellOrder(
            sellOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenSell,
            _amountReceive,
            bidPrice,
            _tokenSell,
            _amountReceive,
            0,
            0,
            false,
            feePercent,
            block.timestamp,
            OrderStatus.OPEN
        );
        initialSellOrder[_celebrityToken] = sellOrderCount;
        tokensAndEtherInExchange[_celebrityToken][
            msg.sender
        ] = tokensAndEtherInExchange[_celebrityToken][msg.sender].add(
            _tokenSell
        );
        emit InitialSellOrderPlaced(
            sellOrderCount,
            msg.sender,
            _celebrityToken,
            _tokenSell,
            _amountReceive,
            bidPrice,
            block.timestamp
        );
        sellOrderCount = sellOrderCount.add(1);
        currentHighestSellOrderPrice[_celebrityToken] = bidPrice;
    }

    function updateInitialSellOrder(
        address _celebrityToken,
        uint256 _tokenSell,
        uint256 _amountReceive
    ) public onlyOwner {
        require(
            CelebrityToken(_celebrityToken).balanceOf(msg.sender) >= _tokenSell,
            "Not enough token balance to place order"
        );
        require(
            !CelebrityToken(_celebrityToken)
                .isTradingAllowedOnCelebrityExchange(),
            "Initial Sell order cannot be placed when token already traded in exchange"
        );

        uint256 bidPrice = _amountReceive.mul(10**18).div(_tokenSell);

        _getTokenFrom(
            _celebrityToken,
            msg.sender,
            _tokenSell.sub(
                sellOrders[initialSellOrder[_celebrityToken]].tokensLeftToSell
            )
        );
        sellOrders[initialSellOrder[_celebrityToken]].tokenSell = _tokenSell;
        sellOrders[initialSellOrder[_celebrityToken]]
            .amountReceive = _amountReceive;
        sellOrders[initialSellOrder[_celebrityToken]].sellPrice = bidPrice;
        sellOrders[initialSellOrder[_celebrityToken]]
            .tokensLeftToSell = _tokenSell;
        sellOrders[initialSellOrder[_celebrityToken]]
            .etherAmountLeft = _amountReceive;
        sellOrders[initialSellOrder[_celebrityToken]].timestamp = block
            .timestamp;
        tokensAndEtherInExchange[_celebrityToken][
            msg.sender
        ] = tokensAndEtherInExchange[_celebrityToken][msg.sender].add(
            _tokenSell.sub(
                sellOrders[initialSellOrder[_celebrityToken]].tokensLeftToSell
            )
        );
        emit InitialSellOrderUpdated(
            _celebrityToken,
            _tokenSell,
            _amountReceive,
            bidPrice,
            block.timestamp
        );
        if (currentHighestSellOrderPrice[_celebrityToken] < bidPrice) {
            currentHighestSellOrderPrice[_celebrityToken] = bidPrice;
        }
    }

    function _transferEtherFromTo(
        address from,
        address to,
        uint256 _amount
    ) internal {
        require(
            WETHToken(WETHERADDRESS).allowance(from, address(this)) >= _amount,
            "Not enough allocation in Matic WETH token"
        );
        WETHToken(WETHERADDRESS).transferFrom(from, to, _amount);
    }

    function _transferTokenFromTo(
        address _celebrityToken,
        address from,
        address to,
        uint256 _amount
    ) internal {
        CelebrityToken(_celebrityToken).transferFrom(from, to, _amount);
    }

    function _getEtherFrom(address from, uint256 _amount) internal {
        require(
            WETHToken(WETHERADDRESS).allowance(from, address(this)) >= _amount,
            "Not enough allocation in Matic WETH token"
        );
        WETHToken(WETHERADDRESS).transferFrom(from, address(this), _amount);
    }

    function _getTokenFrom(
        address _celebrityToken,
        address from,
        uint256 _amount
    ) internal {
        CelebrityToken(_celebrityToken).transferFrom(
            from,
            address(this),
            _amount
        );
    }

    function _getFANCFrom(address from, uint256 _amount) internal {
        FANCTOKEN(FANCTOKENAddress).transferFrom(from, address(this), _amount);
    }

    function _sendFANCTo(address to, uint256 _amount) internal {
        require(_amount >= 0);
        FANCTOKEN(FANCTOKENAddress).transfer(to, _amount);
    }

    function _sendEtherTo(address to, uint256 _amount) internal {
        WETHToken(WETHERADDRESS).transfer(to, _amount);
    }

    function _sendTokenTo(
        address _celebrityToken,
        address to,
        uint256 _amount
    ) internal {
        CelebrityToken(_celebrityToken).transfer(to, _amount);
    }

    function _calculateAndAllocateFeesForBuyOrderFill(
        uint256 _buyOrderId,
        uint256 _tokensFilled,
        uint256 _feesInFANC,
        uint256 _feesInEther
    ) internal {
        //buyer
        // reduce feesallocated in the struct
        // reduce feesallocated in global mapping
        // add fees to the feescollected gloabl mapping - both owner and nftowner
        uint256 proportionOfTokensSold =
            _tokensFilled.div(buyOrders[_buyOrderId].tokensLeftToBuy);
        uint256 etherFees =
            buyOrders[_buyOrderId].feeAllocatedAsEther.mul(
                proportionOfTokensSold
            );
        uint256 FANCFees =
            buyOrders[_buyOrderId].feeAllocatedAsFANC.mul(
                proportionOfTokensSold
            );
        address NFTOwner =
            CelebrityOwnerToken(CelebrityOwnerTokenAddress).ownerOf(
                CelebrityToken(buyOrders[_buyOrderId].celebrityToken).id()
            );
        uint256 feeAllocationToNFTOwnerFANC =
            FANCFees.mul(allocationToNFTOwner).div(10**18);
        uint256 feeAllocationToNFTOwnerEther =
            etherFees.mul(allocationToNFTOwner).div(10**18);
        if (buyOrders[_buyOrderId].isFeePaidUsingFANC) {
            // add buyer side fees and sender side fees both to the feesCollected mapping
            feeCollectedInFANC[owner()] = feeCollectedInFANC[owner()].add(
                FANCFees.sub(feeAllocationToNFTOwnerFANC)
            );
            feeCollectedInFANC[NFTOwner] = feeCollectedInFANC[NFTOwner].add(
                feeAllocationToNFTOwnerFANC
            );
            buyOrders[_buyOrderId].feeAllocatedAsFANC = buyOrders[_buyOrderId]
                .feeAllocatedAsFANC
                .sub(FANCFees);
        } else {
            feeCollectedInEther[owner()] = feeCollectedInEther[owner()].add(
                etherFees.sub(feeAllocationToNFTOwnerEther)
            );
            feeCollectedInEther[NFTOwner] = feeCollectedInEther[NFTOwner].add(
                feeAllocationToNFTOwnerEther
            );
            buyOrders[_buyOrderId].feeAllocatedAsEther = buyOrders[_buyOrderId]
                .feeAllocatedAsEther
                .sub(etherFees);
        }

        // seller
        // add fees to the feescollected gloabl mapping - both owner and nftowner
        uint256 sellerFeeAllocationToNFTOwnerFANC =
            _feesInFANC.mul(allocationToNFTOwner).div(10**18);
        uint256 sellerDeeAllocationToNFTOwnerEther =
            _feesInEther.mul(allocationToNFTOwner).div(10**18);
        feeCollectedInFANC[owner()] = feeCollectedInFANC[owner()].add(
            _feesInFANC.sub(sellerFeeAllocationToNFTOwnerFANC)
        );
        feeCollectedInFANC[NFTOwner] = feeCollectedInFANC[NFTOwner].add(
            sellerFeeAllocationToNFTOwnerFANC
        );
        feeCollectedInEther[owner()] = feeCollectedInEther[owner()].add(
            _feesInEther.sub(sellerDeeAllocationToNFTOwnerEther)
        );
        feeCollectedInEther[NFTOwner] = feeCollectedInEther[NFTOwner].add(
            sellerDeeAllocationToNFTOwnerEther
        );
    }

    function _calculateAndAllocateFeesForSellOrderFill(
        uint256 _sellOrderId,
        uint256 _tokensFilled,
        uint256 _feesInFANC,
        uint256 _feesInEther
    ) internal {
        //buyer
        // reduce feesallocated in the struct
        // reduce feesallocated in global mapping
        // add fees to the feescollected gloabl mapping - both owner and nftowner
        uint256 proportionOfTokensSold =
            _tokensFilled.div(sellOrders[_sellOrderId].tokensLeftToSell);
        uint256 etherFees =
            sellOrders[_sellOrderId].feeAllocatedAsEther.mul(
                proportionOfTokensSold
            );
        uint256 FANCFees =
            sellOrders[_sellOrderId].feeAllocatedAsFANC.mul(
                proportionOfTokensSold
            );
        address NFTOwner =
            CelebrityOwnerToken(CelebrityOwnerTokenAddress).ownerOf(
                CelebrityToken(sellOrders[_sellOrderId].celebrityToken).id()
            );
        uint256 feeAllocationToNFTOwnerFANC =
            FANCFees.mul(allocationToNFTOwner).div(10**18);
        uint256 feeAllocationToNFTOwnerEther =
            etherFees.mul(allocationToNFTOwner).div(10**18);
        if (sellOrders[_sellOrderId].isFeePaidUsingFANC) {
            // add buyer side fees and sender side fees both to the feesCollected mapping
            feeCollectedInFANC[owner()] = feeCollectedInFANC[owner()].add(
                FANCFees.sub(feeAllocationToNFTOwnerFANC)
            );
            feeCollectedInFANC[NFTOwner] = feeCollectedInFANC[NFTOwner].add(
                feeAllocationToNFTOwnerFANC
            );
            sellOrders[_sellOrderId].feeAllocatedAsFANC = sellOrders[
                _sellOrderId
            ]
                .feeAllocatedAsFANC
                .sub(FANCFees);
        } else {
            feeCollectedInEther[owner()] = feeCollectedInEther[owner()].add(
                etherFees.sub(feeAllocationToNFTOwnerEther)
            );
            feeCollectedInEther[NFTOwner] = feeCollectedInEther[NFTOwner].add(
                feeAllocationToNFTOwnerEther
            );
            sellOrders[_sellOrderId].feeAllocatedAsEther = sellOrders[
                _sellOrderId
            ]
                .feeAllocatedAsEther
                .sub(etherFees);
        }

        // seller
        // add fees to the feescollected gloabl mapping - both owner and nftowner
        uint256 sellerFeeAllocationToNFTOwnerFANC =
            _feesInFANC.mul(allocationToNFTOwner).div(10**18);
        uint256 sellerDeeAllocationToNFTOwnerEther =
            _feesInEther.mul(allocationToNFTOwner).div(10**18);
        feeCollectedInFANC[owner()] = feeCollectedInFANC[owner()].add(
            _feesInFANC.sub(sellerFeeAllocationToNFTOwnerFANC)
        );
        feeCollectedInFANC[NFTOwner] = feeCollectedInFANC[NFTOwner].add(
            sellerFeeAllocationToNFTOwnerFANC
        );
        feeCollectedInEther[owner()] = feeCollectedInEther[owner()].add(
            _feesInEther.sub(sellerDeeAllocationToNFTOwnerEther)
        );
        feeCollectedInEther[NFTOwner] = feeCollectedInEther[NFTOwner].add(
            sellerDeeAllocationToNFTOwnerEther
        );
    }

    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
    {
        return tokensAndEtherInExchange[_token][_user];
    }

    function withdrawEther(uint256 _amount) public onlyOwner {
        require(
            tokensAndEtherInExchange[WETHERADDRESS][owner()] >= _amount,
            "Not enough funds in the protocol"
        );
        tokensAndEtherInExchange[WETHERADDRESS][
            owner()
        ] = tokensAndEtherInExchange[WETHERADDRESS][owner()].sub(_amount);
        WETHToken(WETHERADDRESS).transfer(owner(), _amount);
    }

    function withdrawFANC(uint256 _amount) public onlyOwner {
        require(
            tokensAndEtherInExchange[FANCTOKENAddress][owner()] >= _amount,
            "Not enough funds in the protocol"
        );
        tokensAndEtherInExchange[FANCTOKENAddress][
            owner()
        ] = tokensAndEtherInExchange[FANCTOKENAddress][owner()].sub(_amount);
        FANCTOKEN(FANCTOKENAddress).transfer(owner(), _amount);
    }

    function withdrawEtherFees(uint256 _amount) public {
        require(
            feeCollectedInEther[msg.sender] >= _amount,
            "Not enough funds in the protocol"
        );
        require(
            _amount >= minWithdrawalInEtherAllowed,
            "Amount less than min withdrawal limit"
        );
        feeCollectedInEther[msg.sender] = feeCollectedInEther[msg.sender].sub(
            _amount
        );
        WETHToken(WETHERADDRESS).transfer(msg.sender, _amount);
    }

    function withdrawFANCFees(uint256 _amount) public {
        require(
            feeCollectedInFANC[msg.sender] >= _amount,
            "Not enough funds in the protocol"
        );
        require(
            _amount >=
                minWithdrawalInEtherAllowed
                    .mul(Oracle(ORACLEADDRESS).getAssetPrice())
                    .div(10**18),
            "Amount less than min withdrawal limit"
        );
        feeCollectedInFANC[msg.sender] = feeCollectedInFANC[msg.sender].sub(
            _amount
        );
        FANCTOKEN(FANCTOKENAddress).transfer(msg.sender, _amount);
    }
}
