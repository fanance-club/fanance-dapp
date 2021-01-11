import React, { useState, useEffect } from "react";
import { Card, Input, Button, Form } from "antd";

const layout = {
	labelCol: { span: 0 },
	wrapperCol: { offset: 2, span: 20 },
};

export default function PlaceOrders(props) {
	const [stackId, setStackId] = useState(null);
	const [buyFocused, setBuyFocus] = useState(true);
	useEffect(() => {
		setBuyFocus(buyFocused);
	}, [buyFocused]);
	const changeStatus = (e) => {
		setBuyFocus(e.target.value == "BUY" ? true : false);
	};

	const submitOrder = async (e) => {
		const _price = document.getElementById("price").value;
		const _amount = document.getElementById("amount").value;
		const _total = document.getElementById("total").value;
		const { drizzle, drizzleState } = props;
		const contract = drizzle.contracts.CelebrityExchange;
		// get the transaction states from the drizzle state
		// let drizzle know we want to call the `set` method with `value`
		if (buyFocused) {
			const buyStackId = await contract.methods.placeBuyOrder.cacheSend(
				"0xDD1BcCD8da45D24823a85B5841Aa9861Cc8df301",
				drizzle.web3.utils.toWei(_amount),
				drizzle.web3.utils.toWei(_total),
				drizzle.web3.utils.toWei(_total) / 100,
				false,
				{
					from: drizzleState.accounts[0],
				}
			);
			setStackId(buyStackId);
		} else {
			const sellStackId = await contract.methods.placeSellOrder.cacheSend(
				"0xDD1BcCD8da45D24823a85B5841Aa9861Cc8df301",
				drizzle.web3.utils.toWei(_amount),
				drizzle.web3.utils.toWei(_total),
				drizzle.web3.utils.toWei(_total) / 100,
				false,
				{
					from: drizzleState.accounts[0],
				}
			);
			setStackId(sellStackId);
		}
	};
	const getTxStatus = () => {
		const { transactions, transactionStack } = props.drizzleState;
		// get the transaction hash using our saved `stackId`
		if (transactionStack[stackId]) {
			const txHash = transactionStack[stackId];

			return transactions[txHash] && transactions[txHash].status;
		}
	};

	return (
		<section>
			{/* buy order seperate component, sell order seperate, load dynamically */}
			<div
				style={{ position: "absolute", top: "5px", zIndex: "5", left: "5px" }}
			>
				<input
					type="radio"
					id="BUY"
					name="buyFocus"
					value="BUY"
					onChange={(value) => changeStatus(value)}
					checked={buyFocused}
				/>
				<label
					htmlFor="BUY"
					style={{
						borderTop: `${
							buyFocused ? "5px solid #55bd6c" : "5px solid #424242"
						}`,
					}}
				>
					BUY
				</label>
				<input
					type="radio"
					id="SELL"
					name="buyFocus"
					value="SELL"
					onChange={(value) => changeStatus(value)}
					checked={!buyFocused}
				/>
				<label
					htmlFor="SELL"
					style={{
						borderTop: `${
							!buyFocused ? "5px solid #f1432f" : "5px solid #424242"
						}`,
					}}
				>
					SELL
				</label>
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
						<Form.Item
							name="price"
							id="price"
							label="PRICE"
							rules={[{ required: true }]}
						>
							<Input autoComplete="off" addonBefore="PRICE" suffix="ETH" />
						</Form.Item>
						<Form.Item
							name="amount"
							label="AMOUNT"
							id="price"
							rules={[{ required: true }]}
						>
							<Input autoComplete="off" addonBefore="AMOUNT" suffix="TOKENS" />
						</Form.Item>
						<Form.Item
							name="total"
							label="TOTAL"
							id="total"
							rules={[{ required: true }]}
						>
							<Input autoComplete="off" addonBefore="TOTAL" suffix="ETH" />
						</Form.Item>

						<Button
							type="primary"
							htmlType="submit"
							onClick={() => submitOrder()}
							style={{
								backgroundColor: `${buyFocused ? "#55bd6c" : "#f1432f"}`,
								border: "0px",
								color: "white",
								width: "50%",
							}}
						>
							{buyFocused ? `BUY ${props.symbol}` : `SELL ${props.symbol}`}
						</Button>
					</Form>
					<div>{getTxStatus()}</div>
				</div>
			</Card>
		</section>
	);
}
