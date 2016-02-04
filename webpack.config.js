var path = require('path');
var webpack = require('webpack');
var webpackUMDExternal = require('webpack-umd-external');

/******** DEVELOPMENT *********/
module.exports = {
  entry: [
    __dirname+'/modules/index.js' // JS
  ],
  // devtool: 'cheap-module-source-map',
  output: {
    path: path.join(__dirname, 'lib'),
    filename: 'index.js',
    library: 'AtRest',
    libraryTarget: 'umd',
    umdNamedDefine: true
  },
  externals: webpackUMDExternal({
    'react': 'React'
  }),
  resolve: {
    extensions: ['', '.js', '.cjsx', '.coffee', '.js.coffee', '.js.cjsx']
  },
  module: {
    loaders: [
      { test: /\.cjsx$/, loaders: ['coffee', 'cjsx']},
      { test: /\.coffee$/, loader: 'coffee' }
    ]
  },
  plugins: [
    new webpack.optimize.OccurenceOrderPlugin(true)
  ]
};
