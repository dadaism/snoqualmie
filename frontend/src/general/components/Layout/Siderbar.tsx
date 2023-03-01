import { Flex, useColorModeValue, FlexProps, Link, Icon } from 'src/theme';
import { ReactText } from 'react';
import {
  HiOutlineUserGroup as UserGroup,
  HiOutlineFolderOpen as FolderOpen,
  HiOutlineCalendar as Calendar,
  HiOutlineCash as Cash,
} from 'react-icons/hi';
import { IconType } from 'react-icons';
import { users, collections, drops, sellers } from 'src/modules/routes';
import { useRouter } from 'next/router';

interface LinkItemProps {
  name: string;
  url: string;
  icon: IconType;
}

const LinkItems: Array<LinkItemProps> = [
  { name: 'Users', icon: UserGroup, url: users() },
  { name: 'Collections', icon: FolderOpen, url: collections() },
  { name: 'Drops', icon: Calendar, url: drops() },
  { name: 'Sellers', icon: Cash, url: sellers() },
];

interface NavItemProps extends FlexProps {
  children: ReactText;
  icon: IconType;
  url: string;
}

const NavItem = ({ children, icon, url, ...rest }: NavItemProps) => {
  return (
    <Link
      href={url}
      style={{ textDecoration: 'none' }}
      _focus={{ boxShadow: 'none' }}
    >
      <Flex
        align="center"
        borderRadius="lg"
        role="group"
        cursor="pointer"
        h={10}
        pl={2}
        my={3}
        {...rest}
      >
        {icon && <Icon mr="2" boxSize={6} as={icon} />}
        {children}
      </Flex>
    </Link>
  );
};

export const SidebarContent = () => {
  const router = useRouter();
  return (
    <Flex
      transition="3s ease"
      borderRight="1px"
      borderRightColor={useColorModeValue('gray.200', 'gray.700')}
      display="block"
      w="3xs"
      px={2}
      h="full"
      pt={9}
    >
      {LinkItems.map((link) => {
        const isOnPath = router.pathname.startsWith(link.url);
        return (
          <NavItem
            key={link.name}
            icon={link.icon}
            url={link.url}
            background={isOnPath ? 'gray.700' : ''}
          >
            {link.name}
          </NavItem>
        );
      })}
    </Flex>
  );
};
