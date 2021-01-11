import React, { useState, useEffect } from "react";
import FetchContractData2 from "./FetchContractData2";

export default function FetchContractData1(props) {
	const [buyOrders, setBuyOrders] = useState([{ id: 0 }]);
	const [buyOrderCountValue, setBuyOrderCountValue] = useState(0);
	const [sellOrders, setSellOrders] = useState([{ id: 0 }]);
	const [sellOrderCountValue, setSellOrderCountValue] = useState(0);
	useEffect(() => {
		let buyCount =
			props.drizzleState.contracts.CelebrityExchange.buyOrderCount[
				props.buyOrderCount
			];
		let tempBuyOrders = [];
		for (let i = 0; i < (buyCount && buyCount.value); i++) {
			let buyOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"buyOrders"
			].cacheCall(i);
			tempBuyOrders.push(buyOrder);
		}
		setBuyOrders(tempBuyOrders);
		setBuyOrderCountValue(buyCount && buyCount.value);
		let sellCount =
			props.drizzleState.contracts.CelebrityExchange.sellOrderCount[
				props.sellOrderCount
			];
		let tempSellOrders = [];
		for (let i = 0; i < (sellCount && sellCount.value); i++) {
			let sellOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"sellOrders"
			].cacheCall(i);
			tempSellOrders.push(sellOrder);
		}
		setSellOrders(tempSellOrders);
		setSellOrderCountValue(sellCount && sellCount.value);
	}, [
		props.drizzleState.contracts.CelebrityExchange.buyOrderCount,
		props.drizzle.contracts.CelebrityExchange,
		props.buyOrderCount,
		props.drizzleState.contracts.CelebrityExchange.sellOrderCount,
		props.sellOrderCount,
	]);
	return (
		<React.Fragment>
			<FetchContractData2
				drizzle={props.drizzle}
				drizzleState={props.drizzleState}
				buyOrders={buyOrders}
				buyCount={buyOrderCountValue}
				handleBuyOrders={props.handleBuyOrders}
				sellOrders={sellOrders}
				sellCount={sellOrderCountValue}
				handleSellOrders={props.handleSellOrders}
			/>
		</React.Fragment>
	);
}
