import React from "react";
import { Card, Avatar } from "antd";
const { Meta } = Card;

const IndividualTokenDetail = () => {
	return (
		<div>
			<Card className="individualToken" bordered="true">
				<Meta
					avatar={
						<Avatar
							size={60}
							src="https://i.pinimg.com/564x/46/a5/17/46a517509ba998c1db49f2f77fac63fa.jpg"
						/>
					}
					title="Mahendra Singh Dhoni"
					description="0.0034"
				/>
				<span
					style={{
						position: "absolute",
						right: "10px",
						bottom: "5px",
						fontSize: "10px",
						color: "#55bd6c",
					}}
				>
					5.4%&uarr;
				</span>
			</Card>
		</div>
	);
};

export default IndividualTokenDetail;
