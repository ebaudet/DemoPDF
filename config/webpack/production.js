process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

// Webpacker 5's compression plugins use an OpenSSL hash removed by modern Node.
environment.plugins.delete('Compression')
environment.plugins.delete('Compression Brotli')

module.exports = environment.toWebpackConfig()
