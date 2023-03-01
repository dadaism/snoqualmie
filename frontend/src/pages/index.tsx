import React from 'react';
import type { NextPage } from 'next';
import Head from 'src/general/components/Head';
import { Heading } from 'src/theme';

const Home: NextPage = () => {
  return (
    <React.Fragment>
      <Head title="Welcome to Snoqualmie" />
      <Heading>Welcome to Snoqualmie</Heading>
    </React.Fragment>
  );
};

export default Home;
