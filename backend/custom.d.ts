// custom.d.ts

import 'express';

declare module 'express-serve-static-core' {
  interface Request {
    userId?: number; // Ensure this is the type you're using
  }
}