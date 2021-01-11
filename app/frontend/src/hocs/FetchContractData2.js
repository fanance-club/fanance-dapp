import React, { useState, useEffect } from "react";

export default function FetchContractData2(props) {
	const [buyOrderDetailsArray, setBuyOrderDetailsArray] = useState([]);
	const [sellOrderDetailsArray, setSellOrderDetailsArray] = useState([]);
	useEffect(() => {
		let buyOrdersArray = [];
		for (let i = 0; i < props.buyCount; i++) {
			let tempBuyOrderDetails =
				props.drizzleState.contracts.CelebrityExchange.buyOrders[
					props.buyOrders[i]
				];
			tempBuyOrderDetails = tempBuyOrderDetails && tempBuyOrderDetails.value;
			buyOrdersArray.push(tempBuyOrderDetails);
		}
		setBuyOrderDetailsArray(buyOrdersArray);

		let tempSellOrdersArray = [];
		for (let i = 0; i < props.sellCount; i++) {
			let tempSellOrderDetails =
				props.drizzleState.contracts.CelebrityExchange.sellOrders[
					props.sellOrders[i]
				];
			tempSellOrderDetails = tempSellOrderDetails && tempSellOrderDetails.value;
			tempSellOrdersArray.push(tempSellOrderDetails);
		}
		setSellOrderDetailsArray(tempSellOrdersArray);
		props.handleSellOrders(tempSellOrdersArray);
		props.handleBuyOrders(buyOrdersArray);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [
		props.drizzleState.contracts.CelebrityExchange.buyOrders,
		props.drizzleState.contracts.CelebrityExchange.sellOrders,
		props.sellOrders,
		props.sellCount,
		props.buyOrders,
		props.buyCount,
	]);

	return <span></span>;
}
