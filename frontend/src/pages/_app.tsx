import type { AppProps } from 'next/app';
// eslint-disable-next-line no-restricted-imports
import { ChakraProvider } from '@chakra-ui/react';
import { SimpleLayoutWrapper } from 'src/general/components/Layout';
import { theme } from 'src/theme';

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <ChakraProvider theme={theme}>
      <SimpleLayoutWrapper>
        <Component {...pageProps} />
      </SimpleLayoutWrapper>
    </ChakraProvider>
  );
}

export default MyApp;
