import React, { useState, useEffect } from "react";

export default function SellOrderBook(props) {
	return (
		<React.Fragment>
			{typeof props.sellOrders != "undefined"
				? props.sellOrders
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
