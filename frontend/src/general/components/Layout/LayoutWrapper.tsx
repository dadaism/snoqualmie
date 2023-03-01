import { FC, ReactElement } from 'react';
import { Flex } from 'src/theme';
import { Header } from './Header';
import { SidebarContent } from './Siderbar';

type Props = {
  children: ReactElement;
};

export const LayoutWrapper: FC<Props> = ({ children }) => {
  return (
    <Flex height="100%" flexDirection="column">
      <Flex>
        <Header />
      </Flex>
      <Flex h="100%" minH="95vh" flexGrow={1}>
        <Flex>
          <SidebarContent />
        </Flex>
        <Flex justify="center" flexGrow={1} flexShrink={0} mt="20px">
          {children}
        </Flex>
      </Flex>
    </Flex>
  );
};

export default LayoutWrapper;
