import React, { useState, useEffect } from "react";
import moment from "moment";
import { Card } from "antd";

export default function Trades(props) {
	return (
		<div>
			<Card className="trades" style={{ overflow: "hidden" }}>
				<p
					style={{
						textAlign: "center",
						color: "white",
						fontSize: "14px",
					}}
				>
					Trades
				</p>
				<div style={{ height: "100%", overflow: "hidden" }}>
					<table style={{ width: "100%", textAlign: "center" }}>
						<thead>
							<tr>
								<th>Price</th>
								<th>Volume</th>
								<th>Time</th>
							</tr>
						</thead>
						<tbody>
							{typeof props.completedTrades != "undefined"
								? props.completedTrades
										.sort(
											(trade1, trade2) => trade2.timestamp - trade1.timestamp
										)
										.map((trade, index, array) => {
											let date =
												typeof trade != "undefined"
													? new Date(trade.timestamp * 1000)
													: null;
											return typeof trade != "undefined" ? (
												<tr key={index}>
													<td
														style={{
															color:
																typeof trade.price != "undefined" &&
																typeof array[index + 1] != "undefined" &&
																trade.price < array[index + 1].price
																	? "#f1432f"
																	: "#55bd6c",
														}}
													>
														{typeof trade.price != "undefined" &&
														typeof array[index + 1] != "undefined" &&
														trade.price < array[index + 1].price ? (
															<span>&darr;</span>
														) : (
															<span>&uarr;</span>
														)}
														{trade.price / 10 ** 18}
													</td>
													<td>{trade.numberOfTokens / 10 ** 18}</td>
													<td>{moment(date).fromNow()}</td>
												</tr>
											) : null;
										})
								: null}
						</tbody>
					</table>
				</div>
			</Card>
		</div>
	);
}
