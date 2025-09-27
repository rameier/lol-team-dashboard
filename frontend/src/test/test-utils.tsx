import { cleanup, render } from '@testing-library/react';
import type { RenderOptions } from '@testing-library/react';
import { afterEach } from 'vitest';

// Cleanup after each test case (e.g. clearing jsdom)
afterEach(() => {
  cleanup();
});

// Custom render function with providers if needed
const customRender = (ui: React.ReactElement, options?: RenderOptions) =>
  render(ui, {
    // wrap provider(s) here if needed
    wrapper: ({ children }) => children,
    ...options,
  });

export * from '@testing-library/react';
export { customRender as render };
