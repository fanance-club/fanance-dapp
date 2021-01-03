import React from "react";
import { Card, Row, Col } from "antd";

const OrderBook = () => {
	return (
		<div className="">
			<Card className="orderBook">
				<Row>
					<Col span="12">
						<p
							style={{
								textAlign: "center",
								color: "white",
								fontSize: "12",
							}}
						>
							Open Buy Orders
						</p>
						<table style={{ width: "95%", textAlign: "right" }}>
							<tr>
								<th>Volume</th>
								<th>Buy Price</th>
							</tr>
							<tr>
								<td>1000</td>
								<td style={{ color: "#55bd6c" }}>0.0034</td>
							</tr>
							<tr>
								<td>500</td>
								<td style={{ color: "#55bd6c" }}>0.0032</td>
							</tr>
						</table>
					</Col>
					<Col span="12">
						<p
							style={{
								textAlign: "center",
								color: "white",
								fontSize: "12",
							}}
						>
							Open Sell Orders
						</p>
						<table style={{ width: "100%" }}>
							<tr>
								<th>Sell Price</th>
								<th>Volume</th>
							</tr>
							<tr>
								<td style={{ color: "#f1432f" }}>0.0035</td>
								<td>1200</td>
							</tr>
							<tr>
								<td style={{ color: "#f1432f" }}>0.0040</td>
								<td>120</td>
							</tr>
						</table>
					</Col>
				</Row>
			</Card>
		</div>
	);
};

export default OrderBook;
