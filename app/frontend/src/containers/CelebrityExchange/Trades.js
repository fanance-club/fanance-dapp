import React from "react";
import { Card } from "antd";

const Trades = () => {
	return (
		<div>
			<Card className="trades">
				<p
					style={{
						textAlign: "center",
						color: "white",
						fontSize: "12",
					}}
				>
					Trades
				</p>
				<table style={{ width: "100%", textAlign: "center" }}>
					<tr>
						<th>Price</th>
						<th>Volume</th>
						<th>Time (in UTC)</th>
					</tr>
					<tr>
						<td style={{ color: "#55bd6c" }}>0.0032</td>
						<td>1200</td>
						<td>21.18.30</td>
					</tr>
					<tr>
						<td style={{ color: "#f1432f" }}>0.0029</td>
						<td>950</td>
						<td>21.17.14</td>
					</tr>
					<tr>
						<td style={{ color: "#55bd6c" }}>0.0035</td>
						<td>120</td>
						<td>21.14.03</td>
					</tr>
				</table>
			</Card>
		</div>
	);
};

export default Trades;
