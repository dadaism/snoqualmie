import { path } from './utils';

export const users = (params = {}) => {
  return path(['users'], params);
};

export const collections = (params = {}) => {
  return path(['collections'], params);
};

export const drops = (params = {}) => {
  return path(['drops'], params);
};

export const sellers = (params = {}) => {
  return path(['sellers'], params);
};
