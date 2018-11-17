module.exports = {
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
