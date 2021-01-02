import React from "react";
import { Card, Tabs, Radio, Button } from "antd";

const { TabPane } = Tabs;

const PlaceOrders = () => {
	return (
		<div>
			{/* <Tabs defaultActiveKey="1" type="card">
					<TabPane tab="Card Tab 1" key="1">
						Content of card tab 1
					</TabPane>
					<TabPane tab="Card Tab 2" key="2">
						Content of card tab 2
					</TabPane>
				</Tabs> */}
			{/* <div
				style={{
					textAlign: "center",
					width: "100%",
					position: "absolute",
					top: "5px",
					zIndex: 5,
				}}
			>
				<Radio.Group defaultValue="a" buttonStyle="solid" size="large">
					<Radio.Button value="a">Hangzhou</Radio.Button>
					<Radio.Button value="b">Shanghai</Radio.Button>
				</Radio.Group>
			</div> */}
			<div
				style={{ position: "absolute", top: "5px", zIndex: "5", left: "5px" }}
			>
				<button type="button" className="buyButton">
					BUY
				</button>
				<button type="button" className="sellButton">
					SELL
				</button>
			</div>
			<Card className="placeOrders"></Card>
		</div>
	);
};

export default PlaceOrders;
