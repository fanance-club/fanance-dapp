import React, { useState, useEffect } from "react";
import SellOrderDetails from "./SellOrderDetails";

export default function SellOrderBook(props) {
	const [sellOrders, setSellOrders] = useState([{ id: 0 }]);
	const [sellOrderCountValue, setSellOrderCountValue] = useState(0);
	useEffect(() => {
		let count =
			props.drizzleState.contracts.CelebrityExchange.sellOrderCount[
				props.sellOrderCount
			];
		let tempSellOrders = [];
		for (let i = 0; i < (count && count.value); i++) {
			let sellOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"sellOrders"
			].cacheCall(i);
			tempSellOrders.push(sellOrder);
		}
		setSellOrders(tempSellOrders);
		setSellOrderCountValue(count && count.value);
	}, [
		props.drizzleState.contracts.CelebrityExchange.sellOrderCount,
		props.drizzle.contracts.CelebrityExchange,
		props.sellOrderCount,
	]);
	return (
		<React.Fragment>
			<SellOrderDetails
				drizzle={props.drizzle}
				drizzleState={props.drizzleState}
				orders={sellOrders}
				count={sellOrderCountValue}
				handleSellOrders={props.handleSellOrders}
			/>
		</React.Fragment>
	);
}
