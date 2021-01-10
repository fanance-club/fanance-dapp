import React, { useState, useEffect } from "react";

export default function SingleSellOrder(props) {
	const [sellOrderDetailsArray, setSellOrderDetailsArray] = useState([]);
	useEffect(() => {
		let tempSellOrdersArray = [];
		for (let i = 0; i < props.count; i++) {
			let tempSellOrderDetails =
				props.drizzleState.contracts.CelebrityExchange.sellOrders[
					props.orders[i]
				];
			tempSellOrderDetails = tempSellOrderDetails && tempSellOrderDetails.value;
			tempSellOrdersArray.push(tempSellOrderDetails);
		}
		setSellOrderDetailsArray(tempSellOrdersArray);

		props.handleSellOrders(tempSellOrdersArray);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [
		props.drizzleState.contracts.CelebrityExchange.sellOrders,
		props.orders,
		props.count,
	]);
	return (
		<React.Fragment>
			{typeof sellOrderDetailsArray[0] != "undefined"
				? sellOrderDetailsArray
						.filter((a) =>
							typeof a != "undefined" ? a.status == 0 || a.status == 1 : null
						)
						.sort((a, b) => a.sellPrice - b.sellPrice)
						.map((order, index) => {
							return (
								<tr key={index}>
									<td style={{ color: "#f1432f" }}>
										{typeof order != "undefined"
											? order.sellPrice / 10 ** 18
											: null}
									</td>
									<td>
										{typeof order != "undefined"
											? order.tokensLeftToSell / 10 ** 18
											: null}
									</td>
								</tr>
							);
						})
				: null}
		</React.Fragment>
	);
}
