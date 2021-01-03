import React from "react";
import { Card } from "antd";

import IndividualTokenDetail from "./IndividualTokenDetail";

const { Meta } = Card;
const TokensList = () => {
	return (
		<div>
			<Card className="tokensList">
				<Meta title="Other Celebrities" />
				<IndividualTokenDetail />
			</Card>
		</div>
	);
};

export default TokensList;
