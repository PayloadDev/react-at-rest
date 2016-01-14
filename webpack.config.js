var path = require('path');
var webpack = require('webpack');

/******** DEVELOPMENT *********/
module.exports = {
  entry: [
    'modules/index' // JS
  ],
  // devtool: 'cheap-module-source-map',
  output: {
    path: path.join(__dirname, 'dist'),
    pathinfo: true,
    filename: 'index.js',
    library: 'AtRest',
    libraryTarget: 'umd'
  },
  externals: [
    {
      react: {
        root: 'React',
        commonjs2: 'react',
        commonjs: 'react',
        amd: 'react'
      }
    },
    {
      lodash: {
        root: '_',
        commonjs2: 'lodash',
        commonjs: 'lodash',
        amd: 'lodash'
      }
    }
  ],
  resolveLoader: {
    modulesDirectories: ['node_modules']
  },
  resolve: {
    extensions: ['', '.js', '.cjsx', '.coffee', '.js.coffee', '.js.cjsx'],
    modulesDirectories: [
      'node_modules'
    ],
    root: [
      __dirname,
      path.resolve(__dirname, "node_modules")
    ]
  },
  module: {
    loaders: [
      { test: /\.cjsx$/, loaders: ['coffee', 'cjsx']},
      { test: /\.coffee$/, loader: 'coffee' }
    ]
  }
};
