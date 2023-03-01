import React from 'react';
import type { NextPage } from 'next';
import { Heading } from 'src/theme';
import Head from 'src/general/components/Head';

const Users: NextPage = () => {
  return (
    <React.Fragment>
      <Head subtitle="Users" />
      <Heading>Users Pages</Heading>
    </React.Fragment>
  );
};

export default Users;
