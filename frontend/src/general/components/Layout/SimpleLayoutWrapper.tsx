import { FC, ReactElement } from 'react';
import { Flex } from 'src/theme';
import SimpleHeader from './SimpleHeader';

type Props = {
  children: ReactElement;
};

export const SimpleLayoutWrapper: FC<Props> = ({ children }) => {
  return (
    <Flex height="100%" flexDirection="column">
      <SimpleHeader />
      <Flex justify="center" flexGrow={1} flexShrink={0} mt="20px">
        {children}
      </Flex>
    </Flex>
  );
};

export default SimpleLayoutWrapper;
