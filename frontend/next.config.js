/** @type {import('next').NextConfig} */
const ESLintPlugin = require('eslint-webpack-plugin');
const nextConfig = {
  reactStrictMode: true,
  webpack: (config, { dev, isServer }) => {
    if (dev) {
      // Add the Case Sensitive Paths plugin
      const CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
      config.plugins.push(new CaseSensitivePathsPlugin());

      config.plugins.push(
        new ESLintPlugin({
          emitError: false,
          failOnError: false,
        }),
      );
    }
    return config;
  },
};

module.exports = nextConfig;
