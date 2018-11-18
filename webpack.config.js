module.exports = {
  devServer: {
    contentBase: './dist'
  },
  module: {
    rules: [{
      test: /\.glsl$/,
      use: [
        {
          loader: 'glsl-shader-loader',
          options: {}
        }
      ]
    }]
  }
}
