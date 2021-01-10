import React, { useState, useEffect } from "react";
import BuyOrderDetails from "./BuyOrderDetails";

export default function BuyOrderBook(props) {
	const [buyOrders, setBuyOrders] = useState([{ id: 0 }]);
	const [buyOrderCountValue, setBuyOrderCountValue] = useState(0);
	useEffect(() => {
		let count =
			props.drizzleState.contracts.CelebrityExchange.buyOrderCount[
				props.buyOrderCount
			];
		let tempBuyOrders = [];
		for (let i = 0; i < (count && count.value); i++) {
			let buyOrder = props.drizzle.contracts.CelebrityExchange.methods[
				"buyOrders"
			].cacheCall(i);
			tempBuyOrders.push(buyOrder);
		}
		setBuyOrders(tempBuyOrders);
		setBuyOrderCountValue(count && count.value);
	}, [
		props.drizzleState.contracts.CelebrityExchange.buyOrderCount,
		props.drizzle.contracts.CelebrityExchange,
		props.buyOrderCount,
	]);
	return (
		<React.Fragment>
			<BuyOrderDetails
				drizzle={props.drizzle}
				drizzleState={props.drizzleState}
				orders={buyOrders}
				count={buyOrderCountValue}
				handleBuyOrders={props.handleBuyOrders}
			/>
		</React.Fragment>
	);
}
