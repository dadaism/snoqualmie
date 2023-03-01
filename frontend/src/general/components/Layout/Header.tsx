import {
  Flex,
  Box,
  Text,
  Avatar,
  InputGroup,
  InputLeftElement,
  Input,
  SearchIcon,
  Image,
} from 'src/theme';

export const Header = () => {
  return (
    <Flex
      align="center"
      justify="space-between"
      wrap="wrap"
      w="full"
      h={20}
      minW="container.sm"
      bgGradient="linear(to-r, header.gradientStart, header.gradientEnd)"
    >
      <Flex h="full">
        <Box w={16} h={12} ml={6}>
          <Image boxSize="full" alt="Logo" src="/static/images/logo.svg" />
        </Box>
        <Box py={8}>
          <Text fontWeight="bold" fontSize="xs" color="white">
            Snoqualmie
          </Text>
        </Box>
      </Flex>
      <Flex>
        <Box mr={6}>
          <InputGroup>
            <InputLeftElement pointerEvents="none">
              <SearchIcon color="white" />
            </InputLeftElement>
            <Input
              type="text"
              placeholder="Search Anything"
              borderRadius="3xl"
              borderColor="searchBar.border"
              bg="green.600"
              w="xs"
              color="white"
              _placeholder={{ color: 'white' }}
            />
          </InputGroup>
        </Box>
        <Box w={10} h={10} mr={6}>
          <Avatar size="full" src="/static/images/avatar.svg" />
        </Box>
      </Flex>
    </Flex>
  );
};
