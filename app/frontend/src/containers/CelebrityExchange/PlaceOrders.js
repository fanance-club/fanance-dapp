import React from "react";
import { Card, Tabs, Input, Radio, Button, Form } from "antd";

const { TabPane } = Tabs;
const layout = {
	labelCol: { span: 8 },
	wrapperCol: { span: 14 },
};
const tailLayout = {
	wrapperCol: { offset: 8, span: 16 },
};

const PlaceOrders = () => {
	return (
		<section>
			{/* buy order seperate component, sell order seperate, load dynamically */}
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
			<Card className="placeOrders">
				<div
					style={{
						textAlign: "center",
						position: "absolute",
						top: "70px",
						width: "100%",
					}}
				>
					<Form {...layout} style={{ width: "100%" }}>
						<Form.Item name="note" label="PRICE" rules={[{ required: true }]}>
							<Input />
						</Form.Item>
						<Form.Item
							name="gender"
							label="AMOUNT"
							rules={[{ required: true }]}
						>
							<Input />
						</Form.Item>
						<Form.Item name="gender" label="TOTAL" rules={[{ required: true }]}>
							<Input />
						</Form.Item>

						<Button type="primary" htmlType="submit">
							Submit
						</Button>
					</Form>
				</div>
			</Card>
		</section>
	);
};

export default PlaceOrders;
