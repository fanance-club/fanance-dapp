import React, { useState, useEffect } from "react";

export default function BuyOrderBook(props) {
	return (
		<React.Fragment>
			{typeof props.buyOrders != "undefined"
				? props.buyOrders
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
