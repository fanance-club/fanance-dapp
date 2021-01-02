import React, { Component } from "react";
import { Layout, Menu } from "antd";
const { Header, Content, Footer } = Layout;

const HigherOrderComponent = (WrappedComponent) => {
	return class Layout extends Component {
		render() {
			return (
				<React.Fragment>
					<Layout>
						<Header
							style={{
								position: "",
								zIndex: 1,
								width: "100%",
								height: "50px",
							}}
						>
							<Menu theme="dark" mode="horizontal" defaultSelectedKeys={["2"]}>
								<Menu.Item key="1">nav 1</Menu.Item>
								<Menu.Item key="2">nav 2</Menu.Item>
								<Menu.Item key="3">nav 3</Menu.Item>
							</Menu>
						</Header>
						<Content>
							<WrappedComponent />
						</Content>
						<Footer></Footer>
					</Layout>
				</React.Fragment>
			);
		}
	};
};

export default HigherOrderComponent;
