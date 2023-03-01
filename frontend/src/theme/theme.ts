// eslint-disable-next-line no-restricted-imports
import { extendTheme, ThemeOverride } from '@chakra-ui/react';
// eslint-disable-next-line no-restricted-imports
import type { ThemeConfig } from '@chakra-ui/react';

const config: ThemeConfig = {
  initialColorMode: 'dark',
  useSystemColorMode: false,
};
const themeOverride: ThemeOverride = {
  config,
  colors: {
    header: {
      gradientStart: '#9382FF',
      gradientEnd: '#249F5D',
    },
    searchBar: {
      border: '#76DEB8',
    },
  },
};

export default extendTheme(themeOverride);
