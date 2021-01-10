import React, { useState, useEffect } from "react";

export default function SingleBuyOrder(props) {
	const [buyOrderDetailsArray, setBuyOrderDetailsArray] = useState([]);
	useEffect(() => {
		let buyOrdersArray = [];
		for (let i = 0; i < props.count; i++) {
			let tempBuyOrderDetails =
				props.drizzleState.contracts.CelebrityExchange.buyOrders[
					props.orders[i]
				];
			tempBuyOrderDetails = tempBuyOrderDetails && tempBuyOrderDetails.value;
			buyOrdersArray.push(tempBuyOrderDetails);
		}
		setBuyOrderDetailsArray(buyOrdersArray);

		props.handleBuyOrders(buyOrdersArray);
		// eslint-disable-next-line react-hooks/exhaustive-deps
	}, [
		props.drizzleState.contracts.CelebrityExchange.buyOrders,
		props.orders,
		props.count,
	]);

	return (
		<React.Fragment>
			{typeof buyOrderDetailsArray[0] != "undefined"
				? buyOrderDetailsArray
						.filter((a) =>
							typeof a != "undefined" ? a.status == 0 || a.status == 1 : null
						)
						.sort((a, b) => b.buyPrice - a.buyPrice)
						.map((order, index) => {
							return (
								<tr key={index}>
									<td>
										{typeof order != "undefined"
											? order.tokensLeftToBuy / 10 ** 18
											: null}
									</td>
									<td style={{ color: "#55bd6c" }}>
										{typeof order != "undefined"
											? order.buyPrice / 10 ** 18
											: null}
									</td>
								</tr>
							);
						})
				: null}
		</React.Fragment>
	);
}
