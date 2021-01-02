const CracoLessPlugin = require("craco-less");

module.exports = {
	plugins: [
		{
			plugin: CracoLessPlugin,
			options: {
				lessLoaderOptions: {
					lessOptions: {
						modifyVars: {
							"@primary-color": "#18FFFF",
							"@text-color": "black",
							"@btn-primary-color": "black",
							"@layout-header-height": "50px",
						},
						javascriptEnabled: true,
					},
				},
			},
		},
	],
};
