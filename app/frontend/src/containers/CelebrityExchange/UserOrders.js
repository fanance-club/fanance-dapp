import React from "react";
import { Card, Tabs, Radio, Button } from "antd";

const { TabPane } = Tabs;

const UserOrders = () => {
	return (
		<section>
			{/* buy order seperate component, sell order seperate, load dynamically */}
			<div
				style={{ position: "absolute", top: "5px", zIndex: "5", left: "5px" }}
			>
				<button type="button" className="openOrders">
					OPEN ORDERS
				</button>
				<button type="button" className="completedOrders">
					COMPLETED ORDERS
				</button>
			</div>
			<Card className="userOrders"></Card>
		</section>
	);
};

export default UserOrders;
