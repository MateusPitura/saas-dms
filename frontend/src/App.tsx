import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { ReactQueryDevtools } from "@tanstack/react-query-devtools";

import { RouterProvider } from "react-router-dom";
import ErrorBoundary from "./ErrorBoundary";
import Snackbar from "./design-system/Snackbar";
import { FilterProvider } from "./domains/global/contexts/FilterContext";
import { GlobalProvider } from "./domains/global/contexts/GlobalContext";
import { QueryKeys } from "./domains/global/types";
import { router } from "./router";

const queryClient = new QueryClient({ // 🌠 move to a file and use it instead of useQueryClient()
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: false,
      staleTime: 5 * 60 * 1000,
    },
  },
});

declare module "@tanstack/react-query" { // 🌠 move to a file with QueryClient
  interface Register {
    queryKey: [QueryKeys, ...ReadonlyArray<unknown>];
  }
}

export default function App() {
  return (
    <ErrorBoundary>
      <GlobalProvider>
        <FilterProvider>
          <QueryClientProvider client={queryClient}>
            <Snackbar />
            <RouterProvider router={router} />
            <ReactQueryDevtools />
          </QueryClientProvider>
        </FilterProvider>
      </GlobalProvider>
    </ErrorBoundary>
  );
}
